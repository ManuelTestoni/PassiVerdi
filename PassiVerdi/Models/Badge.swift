//
//  Badge.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation

struct Badge: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var type: BadgeType
    var earnedDate: Date
    var isUnlocked: Bool = false
    
    var title: String {
        type.title
    }
    
    var description: String {
        type.description
    }
    
    var iconName: String {
        type.iconName
    }
}

enum BadgeType: String, Codable, CaseIterable {
    case ecoExplorer = "eco_explorer"
    case bikeHero = "bike_hero"
    case walkingMaster = "walking_master"
    case firstStep = "first_step"
    case weekWarrior = "week_warrior"
    case monthChampion = "month_champion"
    case co2Saver = "co2_saver"
    case publicTransportFan = "public_transport_fan"
    
    var title: String {
        switch self {
        case .ecoExplorer:
            return "Eco Explorer"
        case .bikeHero:
            return "Bike Hero"
        case .walkingMaster:
            return "Walking Master"
        case .firstStep:
            return "Primo Passo"
        case .weekWarrior:
            return "Guerriero Settimanale"
        case .monthChampion:
            return "Campione del Mese"
        case .co2Saver:
            return "Salvatore di CO₂"
        case .publicTransportFan:
            return "Fan dei Mezzi Pubblici"
        }
    }
    
    var description: String {
        switch self {
        case .ecoExplorer:
            return "Hai completato 50 km sostenibili"
        case .bikeHero:
            return "Hai percorso 100 km in bicicletta"
        case .walkingMaster:
            return "Hai camminato per 100 km"
        case .firstStep:
            return "Hai completato la tua prima attività"
        case .weekWarrior:
            return "7 giorni consecutivi di mobilità sostenibile"
        case .monthChampion:
            return "30 giorni di attività green"
        case .co2Saver:
            return "Hai risparmiato 100 kg di CO₂"
        case .publicTransportFan:
            return "50 viaggi con mezzi pubblici"
        }
    }
    
    var iconName: String {
        switch self {
        case .ecoExplorer:
            return "leaf.circle.fill"
        case .bikeHero:
            return "bicycle.circle.fill"
        case .walkingMaster:
            return "figure.walk.circle.fill"
        case .firstStep:
            return "star.circle.fill"
        case .weekWarrior:
            return "calendar.circle.fill"
        case .monthChampion:
            return "crown.fill"
        case .co2Saver:
            return "cloud.sun.fill"
        case .publicTransportFan:
            return "bus.fill"
        }
    }
    
    var requirement: Int {
        switch self {
        case .firstStep:
            return 1
        case .ecoExplorer:
            return 50
        case .bikeHero:
            return 100
        case .walkingMaster:
            return 100
        case .weekWarrior:
            return 7
        case .monthChampion:
            return 30
        case .co2Saver:
            return 100
        case .publicTransportFan:
            return 50
        }
    }
}
