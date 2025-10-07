//
//  Activity.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import CoreLocation

/**
 # Activity
 
 Modello che rappresenta un'attività di spostamento tracciata.
 
 ## Tipologie:
 - Walking (a piedi)
 - Cycling (bicicletta)
 - PublicTransport (trasporto pubblico)
 - Car (automobile - non sostenibile)
 - Unknown (non determinato)
 
 ## Calcoli:
 - Punti assegnati in base al tipo di trasporto
 - CO₂ risparmiata rispetto all'uso dell'auto
 */
struct Activity: Identifiable, Codable {
    
    // MARK: - Properties
    
    /// ID univoco dell'attività
    var id: UUID = UUID()
    
    /// Tipo di trasporto utilizzato
    var transportType: TransportType
    
    /// Distanza percorsa in km
    var distance: Double
    
    /// Data e ora di inizio attività
    var startDate: Date
    
    /// Data e ora di fine attività
    var endDate: Date
    
    /// Coordinate di inizio (opzionale)
    var startLocation: CLLocationCoordinate2D?
    
    /// Coordinate di fine (opzionale)
    var endLocation: CLLocationCoordinate2D?
    
    // MARK: - Computed Properties
    
    /// Durata dell'attività in minuti
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    /// Punti verdi guadagnati per questa attività
    var pointsEarned: Int {
        transportType.pointsPerKm * Int(distance)
    }
    
    /// CO₂ risparmiata rispetto all'uso dell'auto (in kg)
    var co2Saved: Double {
        // Emissioni medie auto: 120g CO₂/km
        // Emissioni mezzi pubblici: 40g CO₂/km
        let carEmissions = 0.12 // kg per km
        
        switch transportType {
        case .walking, .cycling:
            return distance * carEmissions
        case .publicTransport:
            return distance * (carEmissions - 0.04)
        case .car, .unknown:
            return 0.0
        }
    }
    
    /// Descrizione formattata della durata
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

// MARK: - TransportType Enum

/**
 Enum che rappresenta i diversi tipi di trasporto
 */
enum TransportType: String, Codable, CaseIterable {
    case walking = "A piedi"
    case cycling = "Bicicletta"
    case publicTransport = "Trasporto pubblico"
    case car = "Auto"
    case unknown = "Sconosciuto"
    
    /// Icona SF Symbol associata
    var icon: String {
        switch self {
        case .walking:
            return "figure.walk"
        case .cycling:
            return "bicycle"
        case .publicTransport:
            return "bus.fill"
        case .car:
            return "car.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    /// Punti verdi assegnati per km
    var pointsPerKm: Int {
        switch self {
        case .walking:
            return 10
        case .cycling:
            return 8
        case .publicTransport:
            return 5
        case .car:
            return 0
        case .unknown:
            return 0
        }
    }
    
    /// Colore associato al tipo di trasporto
    var color: String {
        switch self {
        case .walking:
            return "green"
        case .cycling:
            return "blue"
        case .publicTransport:
            return "orange"
        case .car:
            return "red"
        case .unknown:
            return "gray"
        }
    }
}

// MARK: - Sample Data

extension Activity {
    
    /// Attività di esempio per preview
    static var samples: [Activity] {
        [
            Activity(
                transportType: .walking,
                distance: 2.5,
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date().addingTimeInterval(-2700)
            ),
            Activity(
                transportType: .cycling,
                distance: 5.2,
                startDate: Date().addingTimeInterval(-7200),
                endDate: Date().addingTimeInterval(-6300)
            ),
            Activity(
                transportType: .publicTransport,
                distance: 12.0,
                startDate: Date().addingTimeInterval(-86400),
                endDate: Date().addingTimeInterval(-84600)
            )
        ]
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
