//
//  Badge.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import SwiftUI

/**
 # Badge
 
 Modello che rappresenta un badge (achievement) nell'app.
 
 ## Tipologie:
 - Basati su distanza percorsa
 - Basati su punti accumulati
 - Basati su numero di attività
 - Basati su streak (giorni consecutivi)
 
 ## Features:
 - Sistema di progressione
 - Icone e colori personalizzati
 - Descrizioni motivazionali
 */
struct Badge: Identifiable, Codable {
    
    // MARK: - Properties
    
    /// ID univoco del badge
    var id: String
    
    /// Nome del badge
    var name: String
    
    /// Descrizione del badge
    var description: String
    
    /// Icona SF Symbol
    var iconName: String
    
    /// Categoria del badge
    var category: BadgeCategory
    
    /// Valore richiesto per ottenere il badge
    var requirement: Double
    
    /// Indica se il badge è stato ottenuto
    var isEarned: Bool = false
    
    /// Data in cui il badge è stato ottenuto
    var earnedDate: Date?
    
    /// Progressione verso il badge (0.0 - 1.0)
    var progress: Double = 0.0
    
    // MARK: - Computed Properties
    
    /// Colore del badge basato sulla categoria
    var color: Color {
        category.color
    }
    
    /// Percentuale di completamento (0-100)
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

// MARK: - BadgeCategory Enum

/**
 Categorie di badge disponibili
 */
enum BadgeCategory: String, Codable {
    case distance = "Distanza"
    case points = "Punti"
    case activities = "Attività"
    case streak = "Serie"
    case special = "Speciali"
    
    /// Colore associato alla categoria
    var color: Color {
        switch self {
        case .distance:
            return .blue
        case .points:
            return .green
        case .activities:
            return .orange
        case .streak:
            return .purple
        case .special:
            return .pink
        }
    }
    
    /// Icona della categoria
    var icon: String {
        switch self {
        case .distance:
            return "location.fill"
        case .points:
            return "star.fill"
        case .activities:
            return "figure.walk"
        case .streak:
            return "flame.fill"
        case .special:
            return "sparkles"
        }
    }
}

// MARK: - Predefined Badges

extension Badge {
    
    /**
     Lista di tutti i badge disponibili nell'app
     */
    static var allBadges: [Badge] {
        [
            // Badge Distanza
            Badge(
                id: "first-steps",
                name: "Primi Passi",
                description: "Percorri 1 km in modo sostenibile",
                iconName: "figure.walk",
                category: .distance,
                requirement: 1.0
            ),
            Badge(
                id: "eco-explorer",
                name: "Eco-Explorer",
                description: "Percorri 10 km in modo sostenibile",
                iconName: "map",
                category: .distance,
                requirement: 10.0
            ),
            Badge(
                id: "green-traveler",
                name: "Viaggiatore Verde",
                description: "Percorri 50 km in modo sostenibile",
                iconName: "airplane",
                category: .distance,
                requirement: 50.0
            ),
            Badge(
                id: "sustainability-champion",
                name: "Campione di Sostenibilità",
                description: "Percorri 100 km in modo sostenibile",
                iconName: "trophy.fill",
                category: .distance,
                requirement: 100.0
            ),
            
            // Badge Punti
            Badge(
                id: "green-starter",
                name: "Inizio Verde",
                description: "Accumula 100 punti verdi",
                iconName: "leaf.fill",
                category: .points,
                requirement: 100.0
            ),
            Badge(
                id: "eco-warrior",
                name: "Eco-Guerriero",
                description: "Accumula 500 punti verdi",
                iconName: "shield.fill",
                category: .points,
                requirement: 500.0
            ),
            Badge(
                id: "green-master",
                name: "Maestro Verde",
                description: "Accumula 1000 punti verdi",
                iconName: "crown.fill",
                category: .points,
                requirement: 1000.0
            ),
            
            // Badge Bicicletta
            Badge(
                id: "bike-beginner",
                name: "Ciclista Principiante",
                description: "Percorri 5 km in bicicletta",
                iconName: "bicycle",
                category: .activities,
                requirement: 5.0
            ),
            Badge(
                id: "bike-hero",
                name: "Eroe della Bicicletta",
                description: "Percorri 50 km in bicicletta",
                iconName: "bicycle.circle.fill",
                category: .activities,
                requirement: 50.0
            ),
            
            // Badge Streak
            Badge(
                id: "consistent-walker",
                name: "Camminatore Costante",
                description: "Completa attività per 7 giorni consecutivi",
                iconName: "flame.fill",
                category: .streak,
                requirement: 7.0
            ),
            Badge(
                id: "dedication-master",
                name: "Maestro della Dedizione",
                description: "Completa attività per 30 giorni consecutivi",
                iconName: "star.circle.fill",
                category: .streak,
                requirement: 30.0
            ),
            
            // Badge Speciali
            Badge(
                id: "early-adopter",
                name: "Early Adopter",
                description: "Benvenuto in PassiVerdi!",
                iconName: "person.badge.plus",
                category: .special,
                requirement: 1.0
            ),
            Badge(
                id: "co2-saver",
                name: "Salvatore di CO₂",
                description: "Risparmia 10 kg di CO₂",
                iconName: "cloud.fill",
                category: .special,
                requirement: 10.0
            )
        ]
    }
    
    /**
     Badge di esempio per preview
     */
    static var sample: Badge {
        var badge = Badge(
            id: "eco-explorer",
            name: "Eco-Explorer",
            description: "Percorri 10 km in modo sostenibile",
            iconName: "map",
            category: .distance,
            requirement: 10.0
        )
        badge.progress = 0.65
        return badge
    }
    
    /**
     Badge già ottenuto per preview
     */
    static var earnedSample: Badge {
        var badge = Badge(
            id: "bike-hero",
            name: "Eroe della Bicicletta",
            description: "Percorri 50 km in bicicletta",
            iconName: "bicycle.circle.fill",
            category: .activities,
            requirement: 50.0
        )
        badge.isEarned = true
        badge.earnedDate = Date().addingTimeInterval(-86400 * 5)
        badge.progress = 1.0
        return badge
    }
}
