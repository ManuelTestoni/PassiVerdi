//
//  Challenge.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation

struct Challenge: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var type: ChallengeType
    var targetValue: Int
    var currentValue: Int = 0
    var startDate: Date
    var endDate: Date
    var reward: Int // punti
    var isCompleted: Bool = false
    var iconName: String
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

enum ChallengeType: String, Codable {
    case daily = "Giornaliera"
    case weekly = "Settimanale"
    case monthly = "Mensile"
    case special = "Speciale"
}

// Sfide predefinite
extension Challenge {
    static let sampleChallenges: [Challenge] = [
        Challenge(
            title: "Bici al Lavoro",
            description: "Vai al lavoro in bici per 3 giorni",
            type: .weekly,
            targetValue: 3,
            currentValue: 1,
            startDate: Date(),
            endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
            reward: 100,
            iconName: "bicycle"
        ),
        Challenge(
            title: "10.000 Passi",
            description: "Cammina 10.000 passi oggi",
            type: .daily,
            targetValue: 10000,
            currentValue: 6543,
            startDate: Date(),
            endDate: Date().addingTimeInterval(24 * 60 * 60),
            reward: 50,
            iconName: "figure.walk"
        ),
        Challenge(
            title: "Settimana Verde",
            description: "7 giorni consecutivi senza auto",
            type: .weekly,
            targetValue: 7,
            currentValue: 3,
            startDate: Date(),
            endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
            reward: 200,
            iconName: "leaf.fill"
        )
    ]
}
