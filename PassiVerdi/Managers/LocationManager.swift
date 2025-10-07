//
//  LocationManager.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

/**
 # LocationManager
 
 Manager per la gestione della localizzazione GPS e tracking degli spostamenti.
 
 ## Responsabilità:
 - Richiesta permessi localizzazione
 - Tracking continuo della posizione
 - Calcolo distanze percorse
 - Rilevamento tipo di movimento (velocità)
 
 ## Features:
 - Modalità background per tracking continuo
 - Ottimizzazione batteria
 - Calcolo automatico km percorsi
 */
class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Posizione corrente dell'utente
    @Published var currentLocation: CLLocation?
    
    /// Stato dell'autorizzazione alla localizzazione
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Indica se il tracking è attivo
    @Published var isTracking: Bool = false
    
    /// Distanza totale percorsa nella sessione corrente (in km)
    @Published var sessionDistance: Double = 0.0
    
    /// Lista delle posizioni registrate nella sessione
    @Published var locationHistory: [CLLocation] = []
    
    // MARK: - Private Properties
    
    /// Core Location Manager
    private let locationManager = CLLocationManager()
    
    /// Ultima posizione registrata
    private var lastLocation: CLLocation?
    
    /// Timer per salvare i dati periodicamente
    private var saveTimer: Timer?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    /**
     Configura il CLLocationManager con le impostazioni ottimali
     */
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Aggiorna ogni 10 metri
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        
        print("📍 LocationManager configurato")
    }
    
    // MARK: - Permission Methods
    
    /**
     Richiede i permessi per la localizzazione
     */
    func requestPermissions() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("📍 Richiesta permessi localizzazione")
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            print("📍 Richiesta permessi localizzazione always")
        default:
            break
        }
    }
    
    // MARK: - Tracking Methods
    
    /**
     Avvia il tracking della posizione
     */
    func startTracking() {
        guard authorizationStatus == .authorizedAlways || 
              authorizationStatus == .authorizedWhenInUse else {
            print("⚠️ Permessi localizzazione non concessi")
            requestPermissions()
            return
        }
        
        locationManager.startUpdatingLocation()
        isTracking = true
        
        // Avvia timer per salvare i dati ogni 5 minuti
        saveTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.saveSessionData()
        }
        
        print("✅ Tracking avviato")
    }
    
    /**
     Ferma il tracking della posizione
     */
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        saveTimer?.invalidate()
        saveTimer = nil
        
        saveSessionData()
        print("⏸️ Tracking fermato")
    }
    
    /**
     Resetta la sessione corrente
     */
    func resetSession() {
        sessionDistance = 0.0
        locationHistory.removeAll()
        lastLocation = nil
        print("🔄 Sessione resettata")
    }
    
    // MARK: - Private Methods
    
    /**
     Calcola la distanza tra due location
     */
    private func calculateDistance(from: CLLocation, to: CLLocation) -> Double {
        let distance = from.distance(from: to)
        return distance / 1000.0 // Converti in km
    }
    
    /**
     Salva i dati della sessione
     */
    private func saveSessionData() {
        // TODO: Implementare salvataggio su CoreData o CloudKit
        print("💾 Dati sessione salvati: \(sessionDistance) km")
    }
    
    /**
     Determina il tipo di trasporto basato sulla velocità
     */
    func estimateTransportType(speed: Double) -> TransportType {
        // Velocità in m/s
        // Camminata: 0.5 - 2.0 m/s (1.8 - 7.2 km/h)
        // Bicicletta: 2.0 - 8.0 m/s (7.2 - 28.8 km/h)
        // Auto: > 8.0 m/s (> 28.8 km/h)
        
        switch speed {
        case 0...2.0:
            return .walking
        case 2.0...8.0:
            return .cycling
        case 8.0...20.0:
            return .publicTransport
        default:
            return .car
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    /**
     Gestisce i cambiamenti di autorizzazione
     */
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Autorizzazione localizzazione concessa")
            if isTracking {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print("❌ Autorizzazione localizzazione negata")
            isTracking = false
        case .notDetermined:
            print("⏳ Autorizzazione localizzazione in attesa")
        @unknown default:
            break
        }
    }
    
    /**
     Gestisce gli aggiornamenti della posizione
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filtra le location con accuracy troppo bassa
        guard location.horizontalAccuracy < 50 else {
            print("⚠️ Accuracy troppo bassa: \(location.horizontalAccuracy)m")
            return
        }
        
        currentLocation = location
        locationHistory.append(location)
        
        // Calcola distanza se abbiamo una posizione precedente
        if let lastLoc = lastLocation {
            let distance = calculateDistance(from: lastLoc, to: location)
            
            // Ignora micro-spostamenti < 10 metri
            if distance > 0.01 {
                sessionDistance += distance
                print("🚶 Distanza aggiunta: \(distance) km - Totale: \(sessionDistance) km")
            }
        }
        
        lastLocation = location
        
        // Log della velocità per determinare il tipo di trasporto
        if location.speed >= 0 {
            let transportType = estimateTransportType(speed: location.speed)
            print("🚗 Velocità stimata: \(location.speed) m/s - Tipo: \(transportType.rawValue)")
        }
    }
    
    /**
     Gestisce gli errori di localizzazione
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Errore localizzazione: \(error.localizedDescription)")
    }
}
