//
//  UserManager.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation

@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var activities: [Activity] = []
    @Published var challenges: [Challenge] = Challenge.sampleChallenges
    
    init() {
        loadUserData()
        loadActivities()
    }
    
    func loadUserData() {
        // TODO: Caricare dati utente da CloudKit/CoreData
        // Per ora creiamo un utente di esempio
        if currentUser == nil {
            currentUser = User(
                email: "esempio@passiverdi.it",
                name: "Utente Demo",
                age: 30,
                gender: .preferNotToSay,
                city: "Milano",
                totalPoints: 450,
                totalKilometers: 125.5,
                totalCO2Saved: 21.3,
                badges: []
            )
        }
    }
    
    func loadActivities() {
        // TODO: Caricare attività da CoreData
        // Per ora creiamo alcune attività di esempio
        if activities.isEmpty {
            activities = [
                Activity(
                    transportType: .cycling,
                    distance: 8.5,
                    duration: 1800,
                    startTime: Date().addingTimeInterval(-3600),
                    endTime: Date(),
                    co2Saved: 1.45,
                    pointsEarned: 102
                ),
                Activity(
                    transportType: .walking,
                    distance: 2.3,
                    duration: 1620,
                    startTime: Date().addingTimeInterval(-86400),
                    endTime: Date().addingTimeInterval(-84780),
                    co2Saved: 0.39,
                    pointsEarned: 35
                )
            ]
        }
    }
    
    func updateUserProfile(_ user: User) {
        currentUser = user
        // TODO: Salvare su CloudKit/CoreData
    }
    
    func addActivity(_ activity: Activity) {
        activities.insert(activity, at: 0)
        
        // Aggiorna le statistiche dell'utente
        if var user = currentUser {
            user.totalKilometers += activity.distance
            user.totalCO2Saved += activity.co2Saved
            user.totalPoints += activity.pointsEarned
            currentUser = user
        }
        
        // Aggiorna le sfide
        updateChallenges(with: activity)
        
        // TODO: Salvare su CoreData
    }
    
    private func updateChallenges(with activity: Activity) {
        for index in challenges.indices {
            // Logica semplificata per aggiornare le sfide
            if !challenges[index].isCompleted {
                challenges[index].currentValue += 1
                if challenges[index].currentValue >= challenges[index].targetValue {
                    challenges[index].isCompleted = true
                    // Assegna ricompensa
                    if var user = currentUser {
                        user.totalPoints += challenges[index].reward
                        currentUser = user
                    }
                }
            }
        }
    }
    
    func getTodayActivities() -> [Activity] {
        let calendar = Calendar.current
        return activities.filter { calendar.isDateInToday($0.startTime) }
    }
    
    func getWeekActivities() -> [Activity] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return activities.filter { $0.startTime >= weekAgo }
    }
}
