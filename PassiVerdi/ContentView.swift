//
//  ContentView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # ContentView
 
 Vista principale dell'applicazione con navigation tab bar.
 
 ## Features:
 - Tab bar navigation tra le sezioni principali
 - Dashboard con statistiche
 - Profilo utente
 - Statistiche dettagliate
 - Badge e achievements
 
 ## Design:
 - Utilizza SwiftUI TabView
 - SF Symbols per le icone
 - Colori brand "Verde PassiVerdi"
 */
struct ContentView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var pointsManager: PointsManager
    
    // MARK: - State
    
    /// Tab attualmente selezionata
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)
            
            // Tab 2: Statistiche
            StatisticsView()
                .tabItem {
                    Label("Statistiche", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            // Tab 3: Badge
            BadgesView()
                .tabItem {
                    Label("Badge", systemImage: "star.fill")
                }
                .tag(2)
            
            // Tab 4: Profilo
            ProfileView()
                .tabItem {
                    Label("Profilo", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.green)
        .onAppear {
            // Avvia il tracking quando l'app diventa attiva
            startTracking()
        }
    }
    
    // MARK: - Private Methods
    
    /**
     Avvia il tracking di posizione e movimento
     */
    private func startTracking() {
        locationManager.startTracking()
        motionManager.startTracking()
        
        print("🌍 Tracking avviato")
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(MotionManager())
        .environmentObject(PointsManager())
}
