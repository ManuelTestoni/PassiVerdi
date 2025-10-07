//
//  PointsManager.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import Combine

/**
 # PointsManager
 
 Manager per la gestione dei punti verdi e sistema di gamification.
 
 ## Responsabilità:
 - Calcolo e assegnazione punti
 - Gestione livelli utente
 - Verifica e sblocco badge
 - Sistema di streak (giorni consecutivi)
 - Notifiche achievements
 
 ## Algoritmo Punti:
 - A piedi: 10 punti/km
 - Bicicletta: 8 punti/km
 - Trasporto pubblico: 5 punti/km
 - Bonus streak: +10% per ogni 7 giorni consecutivi
 */
class PointsManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Punti totali accumulati
    @Published var totalPoints: Int = 0
    
    /// Livello corrente dell'utente
    @Published var currentLevel: Int = 1
    
    /// Punti necessari per il prossimo livello
    @Published var pointsToNextLevel: Int = 100
    
    /// Lista di tutte le attività registrate
    @Published var activities: [Activity] = []
    
    /// Lista di tutti i badge
    @Published var badges: [Badge] = Badge.allBadges
    
    /// Badge appena sbloccati (per notifiche)
    @Published var newlyUnlockedBadges: [Badge] = []
    
    /// Numero di giorni consecutivi con attività
    @Published var currentStreak: Int = 0
    
    /// Punti guadagnati oggi
    @Published var todayPoints: Int = 0
    
    /// Chilometri percorsi oggi
    @Published var todayKilometers: Double = 0.0
    
    /// CO₂ risparmiata oggi
    @Published var todayCO2Saved: Double = 0.0
    
    // MARK: - Private Properties
    
    /// UserDefaults per persistenza
    private let defaults = UserDefaults.standard
    
    /// Chiavi UserDefaults
    private enum Keys {
        static let totalPoints = "totalPoints"
        static let currentLevel = "currentLevel"
        static let activities = "activities"
        static let earnedBadgeIDs = "earnedBadgeIDs"
        static let currentStreak = "currentStreak"
        static let lastActivityDate = "lastActivityDate"
    }
    
    // MARK: - Initialization
    
    init() {
        loadData()
        updateBadgeProgress()
        calculateTodayStats()
        print("💎 PointsManager inizializzato")
    }
    
    // MARK: - Public Methods
    
    /**
     Aggiunge una nuova attività e calcola i punti
     
     - Parameter activity: L'attività da aggiungere
     */
    func addActivity(_ activity: Activity) {
        activities.append(activity)
        
        let points = activity.pointsEarned
        let bonusPoints = calculateStreakBonus(points: points)
        let totalActivityPoints = points + bonusPoints
        
        totalPoints += totalActivityPoints
        todayPoints += totalActivityPoints
        todayKilometers += activity.distance
        todayCO2Saved += activity.co2Saved
        
        // Aggiorna streak
        updateStreak()
        
        // Controlla livello
        checkLevelUp()
        
        // Controlla badge
        checkBadgeUnlocks()
        
        // Salva dati
        saveData()
        
        print("✅ Attività aggiunta: +\(totalActivityPoints) punti (base: \(points), bonus: \(bonusPoints))")
    }
    
    /**
     Calcola il bonus punti basato sullo streak
     
     - Parameter points: Punti base da moltiplicare
     - Returns: Punti bonus
     */
    private func calculateStreakBonus(points: Int) -> Int {
        let streakWeeks = currentStreak / 7
        let bonusPercentage = Double(streakWeeks) * 0.10 // +10% ogni 7 giorni
        return Int(Double(points) * bonusPercentage)
    }
    
    /**
     Aggiorna lo streak di giorni consecutivi
     */
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = defaults.object(forKey: Keys.lastActivityDate) as? Date {
            let lastActivityDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastActivityDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutivo
                currentStreak += 1
                print("🔥 Streak aumentato: \(currentStreak) giorni")
            } else if daysDifference > 1 {
                // Streak interrotto
                print("💔 Streak interrotto (era \(currentStreak) giorni)")
                currentStreak = 1
            }
            // Se daysDifference == 0, è lo stesso giorno, non fare nulla
        } else {
            // Prima attività ever
            currentStreak = 1
        }
        
        defaults.set(Date(), forKey: Keys.lastActivityDate)
    }
    
    /**
     Controlla se l'utente è passato di livello
     */
    private func checkLevelUp() {
        let newLevel = totalPoints / 100 + 1 // Ogni 100 punti = 1 livello
        
        if newLevel > currentLevel {
            currentLevel = newLevel
            print("🎉 LEVEL UP! Nuovo livello: \(currentLevel)")
            // TODO: Mostrare notifica/animazione level up
        }
        
        pointsToNextLevel = (currentLevel * 100) - totalPoints
    }
    
    /**
     Controlla se ci sono nuovi badge da sbloccare
     */
    private func checkBadgeUnlocks() {
        newlyUnlockedBadges.removeAll()
        
        let earnedIDs = Set(badges.filter { $0.isEarned }.map { $0.id })
        
        for index in badges.indices {
            guard !badges[index].isEarned else { continue }
            
            // Aggiorna progressione
            let progress = calculateBadgeProgress(badge: badges[index])
            badges[index].progress = progress
            
            // Controlla sblocco
            if progress >= 1.0 {
                badges[index].isEarned = true
                badges[index].earnedDate = Date()
                newlyUnlockedBadges.append(badges[index])
                
                print("🏆 BADGE SBLOCCATO: \(badges[index].name)")
            }
        }
        
        // Salva badge sbloccati
        let newEarnedIDs = badges.filter { $0.isEarned }.map { $0.id }
        defaults.set(newEarnedIDs, forKey: Keys.earnedBadgeIDs)
    }
    
    /**
     Calcola il progresso verso un badge specifico
     
     - Parameter badge: Il badge da controllare
     - Returns: Progresso da 0.0 a 1.0
     */
    private func calculateBadgeProgress(badge: Badge) -> Double {
        var currentValue: Double = 0.0
        
        switch badge.category {
        case .distance:
            currentValue = activities.reduce(0.0) { $0 + $1.distance }
        case .points:
            currentValue = Double(totalPoints)
        case .activities:
            // Badge specifici per tipo di attività (es. bici)
            if badge.id.contains("bike") {
                currentValue = activities
                    .filter { $0.transportType == .cycling }
                    .reduce(0.0) { $0 + $1.distance }
            }
        case .streak:
            currentValue = Double(currentStreak)
        case .special:
            // Badge speciali (es. CO₂ risparmiata)
            if badge.id == "co2-saver" {
                currentValue = activities.reduce(0.0) { $0 + $1.co2Saved }
            } else if badge.id == "early-adopter" {
                currentValue = 1.0 // Sempre sbloccato al primo login
            }
        }
        
        return min(currentValue / badge.requirement, 1.0)
    }
    
    /**
     Calcola le statistiche del giorno corrente
     */
    private func calculateTodayStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayActivities = activities.filter {
            calendar.isDate($0.startDate, inSameDayAs: today)
        }
        
        todayPoints = todayActivities.reduce(0) { $0 + $1.pointsEarned }
        todayKilometers = todayActivities.reduce(0.0) { $0 + $1.distance }
        todayCO2Saved = todayActivities.reduce(0.0) { $0 + $1.co2Saved }
    }
    
    /**
     Ottiene statistiche per un periodo specifico
     */
    func getStats(for period: StatsPeriod) -> ActivityStats {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            startDate = Date.distantPast
        }
        
        let filteredActivities = activities.filter { $0.startDate >= startDate }
        
        return ActivityStats(
            totalActivities: filteredActivities.count,
            totalPoints: filteredActivities.reduce(0) { $0 + $1.pointsEarned },
            totalDistance: filteredActivities.reduce(0.0) { $0 + $1.distance },
            totalCO2Saved: filteredActivities.reduce(0.0) { $0 + $1.co2Saved },
            byTransportType: Dictionary(grouping: filteredActivities) { $0.transportType }
        )
    }
    
    // MARK: - Data Persistence
    
    /**
     Carica i dati salvati
     */
    private func loadData() {
        totalPoints = defaults.integer(forKey: Keys.totalPoints)
        currentLevel = defaults.integer(forKey: Keys.currentLevel)
        if currentLevel == 0 { currentLevel = 1 }
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
        
        // Carica attività
        if let data = defaults.data(forKey: Keys.activities),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        }
        
        // Carica badge sbloccati
        if let earnedIDs = defaults.array(forKey: Keys.earnedBadgeIDs) as? [String] {
            for index in badges.indices {
                if earnedIDs.contains(badges[index].id) {
                    badges[index].isEarned = true
                }
            }
        }
        
        print("📂 Dati caricati: \(totalPoints) punti, \(activities.count) attività")
    }
    
    /**
     Salva i dati
     */
    private func saveData() {
        defaults.set(totalPoints, forKey: Keys.totalPoints)
        defaults.set(currentLevel, forKey: Keys.currentLevel)
        defaults.set(currentStreak, forKey: Keys.currentStreak)
        
        if let encoded = try? JSONEncoder().encode(activities) {
            defaults.set(encoded, forKey: Keys.activities)
        }
        
        print("💾 Dati salvati")
    }
    
    /**
     Aggiorna il progresso di tutti i badge
     */
    private func updateBadgeProgress() {
        for index in badges.indices {
            if !badges[index].isEarned {
                badges[index].progress = calculateBadgeProgress(badge: badges[index])
            }
        }
    }
}

// MARK: - Supporting Types

/**
 Periodi temporali per le statistiche
 */
enum StatsPeriod: String, CaseIterable {
    case today = "Oggi"
    case week = "7 giorni"
    case month = "30 giorni"
    case year = "Anno"
    case allTime = "Sempre"
}

/**
 Struttura per le statistiche aggregate
 */
struct ActivityStats {
    let totalActivities: Int
    let totalPoints: Int
    let totalDistance: Double
    let totalCO2Saved: Double
    let byTransportType: [TransportType: [Activity]]
}
