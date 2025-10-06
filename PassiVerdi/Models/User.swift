//
//  User.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: UUID = UUID()
    var email: String
    var name: String
    var age: Int?
    var gender: Gender?
    var city: String
    var profileImageURL: String?
    var createdAt: Date = Date()
    
    // Statistiche utente
    var totalPoints: Int = 0
    var totalKilometers: Double = 0.0
    var totalCO2Saved: Double = 0.0
    var badges: [Badge] = []
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Uomo"
        case female = "Donna"
        case other = "Altro"
        case preferNotToSay = "Preferisco non dirlo"
    }
}
