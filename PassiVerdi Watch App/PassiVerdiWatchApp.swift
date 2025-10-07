//
//  PassiVerdiWatchApp.swift
//  PassiVerdi Watch App
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # PassiVerdiWatchApp
 
 Entry point per l'applicazione Apple Watch.
 
 ## Features:
 - Visualizzazione punti e statistiche
 - Widget complicazioni
 - Sincronizzazione con iPhone
 */
@main
struct PassiVerdiWatchApp: App {
    
    // MARK: - State Objects
    
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(watchConnectivity)
                .onAppear {
                    setupWatch()
                }
        }
    }
    
    // MARK: - Setup
    
    /**
     Configura l'app Watch all'avvio
     */
    private func setupWatch() {
        watchConnectivity.activate()
        print("⌚ PassiVerdi Watch App inizializzata")
    }
}
