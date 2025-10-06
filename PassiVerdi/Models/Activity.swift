//
//  Activity.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation
import CoreLocation

struct Activity: Identifiable, Codable {
    var id: UUID = UUID()
    var transportType: TransportType
    var distance: Double // in kilometers
    var duration: TimeInterval // in seconds
    var startTime: Date
    var endTime: Date
    var route: [CLLocationCoordinate2D]?
    var co2Saved: Double // in kg
    var pointsEarned: Int
    
    var formattedDistance: String {
        String(format: "%.2f km", distance)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minuti"
        }
    }
}

enum TransportType: String, Codable, CaseIterable {
    case walking = "A piedi"
    case cycling = "Bicicletta"
    case publicTransport = "Mezzi pubblici"
    case car = "Auto"
    case carpool = "Carpooling"
    
    var iconName: String {
        switch self {
        case .walking:
            return "figure.walk"
        case .cycling:
            return "bicycle"
        case .publicTransport:
            return "bus.fill"
        case .car:
            return "car.fill"
        case .carpool:
            return "person.3.fill"
        }
    }
    
    var color: String {
        switch self {
        case .walking, .cycling:
            return "green"
        case .publicTransport, .carpool:
            return "yellow"
        case .car:
            return "red"
        }
    }
    
    // CO2 emessa per km (in grammi)
    var co2PerKm: Double {
        switch self {
        case .walking, .cycling:
            return 0
        case .publicTransport:
            return 68
        case .carpool:
            return 85
        case .car:
            return 170
        }
    }
    
    // Punti guadagnati per km
    var pointsPerKm: Int {
        switch self {
        case .walking:
            return 15
        case .cycling:
            return 12
        case .publicTransport:
            return 8
        case .carpool:
            return 5
        case .car:
            return 0
        }
    }
}

// Extension per rendere CLLocationCoordinate2D codificabile
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
