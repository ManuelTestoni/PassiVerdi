//
//  PassiVerdiApp.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI
import CloudKit

/**
 # PassiVerdiApp
 
 Entry point principale dell'applicazione PassiVerdi.
 
 ## Responsabilità:
 - Inizializzazione dell'app e dei managers principali
 - Setup della connettività con Apple Watch
 - Gestione dello stato di onboarding
 
 ## Note:
 - Utilizza `@StateObject` per i manager singleton
 - Sincronizzazione automatica con iCloud via CloudKit
 */
@main
struct PassiVerdiApp: App {
    
    // MARK: - State Objects
    
    /// Manager per la gestione della posizione e tracking GPS
    @StateObject private var locationManager = LocationManager()
    
    /// Manager per il rilevamento del movimento e tipo di trasporto
    @StateObject private var motionManager = MotionManager()
    
    /// Manager per la gestione dei punti e delle ricompense
    @StateObject private var pointsManager = PointsManager()
    
    /// Manager per la sincronizzazione con Apple Watch
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    /// Manager per la gestione dei dati su CloudKit
    @StateObject private var cloudKitManager = CloudKitManager()
    
    // MARK: - App State
    
    /// Indica se l'utente ha completato l'onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    // Vista principale dell'app
                    ContentView()
                        .environmentObject(locationManager)
                        .environmentObject(motionManager)
                        .environmentObject(pointsManager)
                        .environmentObject(watchConnectivity)
                        .environmentObject(cloudKitManager)
                } else {
                    // Vista di onboarding per nuovi utenti
                    OnboardingView(isComplete: $hasCompletedOnboarding)
                        .environmentObject(cloudKitManager)
                }
            }
            .onAppear {
                setupApp()
            }
        }
    }
    
    // MARK: - Setup Methods
    
    /**
     Configura l'applicazione all'avvio
     
     Inizializza:
     - Connettività con Apple Watch
     - Richiesta permessi location e motion
     - Sincronizzazione dati CloudKit
     */
    private func setupApp() {
        // Attiva la connessione con Apple Watch
        watchConnectivity.activate()
        
        // Richiedi i permessi necessari
        locationManager.requestPermissions()
        motionManager.requestPermissions()
        
        // Carica i dati dell'utente da CloudKit
        if hasCompletedOnboarding {
            Task {
                await cloudKitManager.fetchUserProfile()
            }
        }
        
        print("✅ PassiVerdi App inizializzata con successo")
    }
}
