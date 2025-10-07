//
//  MotionManager.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import CoreMotion
import Combine

/**
 # MotionManager
 
 Manager per la gestione dei sensori di movimento e rilevamento attività.
 
 ## Responsabilità:
 - Rilevamento tipo di attività (camminata, corsa, bici, auto)
 - Conteggio passi
 - Monitoraggio attività fisica
 - Integrazione con HealthKit per dati salute
 
 ## Tecnologie:
 - CoreMotion per sensori
 - CMMotionActivityManager per rilevamento attività
 - CMPedometer per conteggio passi
 */
class MotionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Tipo di attività corrente rilevata
    @Published var currentActivity: CMMotionActivity?
    
    /// Numero di passi nella sessione corrente
    @Published var stepCount: Int = 0
    
    /// Indica se il tracking è attivo
    @Published var isTracking: Bool = false
    
    /// Tipo di trasporto stimato
    @Published var estimatedTransport: TransportType = .unknown
    
    /// Distanza stimata dai passi (in km)
    @Published var pedometerDistance: Double = 0.0
    
    // MARK: - Private Properties
    
    /// Core Motion Activity Manager
    private let activityManager = CMMotionActivityManager()
    
    /// Pedometer per conteggio passi
    private let pedometer = CMPedometer()
    
    /// Data di inizio della sessione
    private var sessionStartDate: Date?
    
    // MARK: - Initialization
    
    init() {
        print("🏃 MotionManager inizializzato")
    }
    
    // MARK: - Permission Methods
    
    /**
     Richiede i permessi per l'accesso ai sensori di movimento
     */
    func requestPermissions() {
        // I permessi per CoreMotion vengono richiesti automaticamente al primo utilizzo
        // Verifichiamo solo la disponibilità
        if CMMotionActivityManager.isActivityAvailable() {
            print("✅ Motion Activity disponibile")
        } else {
            print("⚠️ Motion Activity non disponibile su questo dispositivo")
        }
        
        if CMPedometer.isStepCountingAvailable() {
            print("✅ Step Counting disponibile")
        } else {
            print("⚠️ Step Counting non disponibile su questo dispositivo")
        }
    }
    
    // MARK: - Tracking Methods
    
    /**
     Avvia il tracking del movimento
     */
    func startTracking() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("❌ Activity tracking non disponibile")
            return
        }
        
        sessionStartDate = Date()
        isTracking = true
        
        // Avvia il tracking dell'attività
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            self.currentActivity = activity
            self.updateEstimatedTransport(from: activity)
            
            print("📊 Attività rilevata: \(self.activityDescription(activity))")
        }
        
        // Avvia il conteggio passi
        startPedometerTracking()
        
        print("✅ Motion tracking avviato")
    }
    
    /**
     Ferma il tracking del movimento
     */
    func stopTracking() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        isTracking = false
        
        print("⏸️ Motion tracking fermato")
    }
    
    /**
     Resetta la sessione corrente
     */
    func resetSession() {
        stepCount = 0
        pedometerDistance = 0.0
        currentActivity = nil
        estimatedTransport = .unknown
        sessionStartDate = nil
        
        print("🔄 Sessione motion resettata")
    }
    
    // MARK: - Private Methods
    
    /**
     Avvia il tracking del pedometro
     */
    private func startPedometerTracking() {
        guard CMPedometer.isStepCountingAvailable(),
              let startDate = sessionStartDate else {
            return
        }
        
        pedometer.startUpdates(from: startDate) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Errore pedometer: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self.stepCount = data.numberOfSteps.intValue
                    
                    if let distance = data.distance {
                        // Converti in km
                        self.pedometerDistance = distance.doubleValue / 1000.0
                    }
                    
                    print("👣 Passi: \(self.stepCount) - Distanza: \(self.pedometerDistance) km")
                }
            }
        }
    }
    
    /**
     Aggiorna il tipo di trasporto stimato basandosi sull'attività
     */
    private func updateEstimatedTransport(from activity: CMMotionActivity) {
        if activity.walking {
            estimatedTransport = .walking
        } else if activity.cycling {
            estimatedTransport = .cycling
        } else if activity.automotive {
            // Potrebbe essere auto o trasporto pubblico
            // Serve Location speed per distinguere
            estimatedTransport = .car
        } else if activity.stationary {
            estimatedTransport = .unknown
        } else {
            estimatedTransport = .unknown
        }
    }
    
    /**
     Genera una descrizione testuale dell'attività
     */
    private func activityDescription(_ activity: CMMotionActivity) -> String {
        var descriptions: [String] = []
        
        if activity.walking {
            descriptions.append("Camminata")
        }
        if activity.running {
            descriptions.append("Corsa")
        }
        if activity.cycling {
            descriptions.append("Bicicletta")
        }
        if activity.automotive {
            descriptions.append("Veicolo")
        }
        if activity.stationary {
            descriptions.append("Fermo")
        }
        
        if descriptions.isEmpty {
            return "Sconosciuto"
        }
        
        return descriptions.joined(separator: ", ")
    }
    
    /**
     Ottiene i dati storici del pedometro
     */
    func queryHistoricalData(from: Date, to: Date, completion: @escaping (Int, Double) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else {
            completion(0, 0.0)
            return
        }
        
        pedometer.queryPedometerData(from: from, to: to) { data, error in
            if let error = error {
                print("❌ Errore query pedometer: \(error.localizedDescription)")
                completion(0, 0.0)
                return
            }
            
            if let data = data {
                let steps = data.numberOfSteps.intValue
                let distance = (data.distance?.doubleValue ?? 0.0) / 1000.0
                
                DispatchQueue.main.async {
                    completion(steps, distance)
                }
            } else {
                completion(0, 0.0)
            }
        }
    }
    
    /**
     Calcola le calorie bruciate approssimative
     
     - Parameters:
        - steps: Numero di passi
        - weight: Peso della persona in kg (default 70)
     - Returns: Calorie bruciate (approssimative)
     */
    func estimateCalories(steps: Int, weight: Double = 70.0) -> Double {
        // Formula approssimativa: 0.04 * peso * numero di passi / 1000
        return 0.04 * weight * Double(steps) / 1000.0
    }
}

// MARK: - Helper Methods

extension MotionManager {
    
    /**
     Verifica se il dispositivo supporta tutte le features necessarie
     */
    static func checkDeviceCapabilities() -> (activity: Bool, pedometer: Bool) {
        return (
            activity: CMMotionActivityManager.isActivityAvailable(),
            pedometer: CMPedometer.isStepCountingAvailable()
        )
    }
    
    /**
     Restituisce una descrizione delle capabilities del dispositivo
     */
    static func capabilitiesDescription() -> String {
        let capabilities = checkDeviceCapabilities()
        var description = "Capabilities:\n"
        description += "- Activity: \(capabilities.activity ? "✅" : "❌")\n"
        description += "- Pedometer: \(capabilities.pedometer ? "✅" : "❌")"
        return description
    }
}
