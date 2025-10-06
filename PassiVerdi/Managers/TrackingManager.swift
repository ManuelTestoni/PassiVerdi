//
//  TrackingManager.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation
import CoreLocation
import CoreMotion

@MainActor
class TrackingManager: NSObject, ObservableObject {
    @Published var isTracking = false
    @Published var currentTransportType: TransportType?
    @Published var currentDistance: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var trackingStartTime: Date?
    
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    private var locations: [CLLocation] = []
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
                self?.processMotionActivity(activity)
            }
        }
    }
    
    func startTracking() {
        guard !isTracking else { return }
        
        isTracking = true
        trackingStartTime = Date()
        currentDistance = 0.0
        locations.removeAll()
        
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() -> Activity? {
        guard isTracking else { return nil }
        
        isTracking = false
        locationManager.stopUpdatingLocation()
        
        guard let startTime = trackingStartTime,
              let transportType = currentTransportType,
              currentDistance > 0 else {
            return nil
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Calcola CO2 risparmiata (rispetto all'auto)
        let carCO2 = (TransportType.car.co2PerKm * currentDistance) / 1000.0
        let currentCO2 = (transportType.co2PerKm * currentDistance) / 1000.0
        let co2Saved = carCO2 - currentCO2
        
        // Calcola punti guadagnati
        let points = Int(currentDistance * Double(transportType.pointsPerKm))
        
        let activity = Activity(
            transportType: transportType,
            distance: currentDistance,
            duration: duration,
            startTime: startTime,
            endTime: endTime,
            co2Saved: co2Saved,
            pointsEarned: points
        )
        
        // Reset
        currentDistance = 0.0
        currentTransportType = nil
        trackingStartTime = nil
        locations.removeAll()
        
        return activity
    }
    
    private func processMotionActivity(_ activity: CMMotionActivity?) {
        guard let activity = activity else { return }
        
        if activity.walking {
            currentTransportType = .walking
        } else if activity.cycling {
            currentTransportType = .cycling
        } else if activity.automotive {
            // Qui dovresti distinguere tra auto, bus, carpooling
            // Per ora impostiamo car come default
            currentTransportType = .car
        }
    }
    
    private func classifyTransportType(speed: Double) -> TransportType {
        // Velocità in m/s
        // Classificazione basata su velocità media
        switch speed {
        case 0..<1.5:
            return .walking
        case 1.5..<6:
            return .cycling
        case 6..<12:
            return .publicTransport
        default:
            return .car
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension TrackingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        for location in locations {
            if let lastLoc = lastLocation {
                let distance = location.distance(from: lastLoc)
                currentDistance += distance / 1000.0 // Converti in km
            }
            
            lastLocation = location
            currentSpeed = location.speed
            
            // Se non abbiamo ancora determinato il tipo di trasporto
            if currentTransportType == nil && location.speed > 0 {
                currentTransportType = classifyTransportType(speed: location.speed)
            }
            
            self.locations.append(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorized")
        case .denied, .restricted:
            print("Location denied")
        case .notDetermined:
            requestPermissions()
        @unknown default:
            break
        }
    }
}
