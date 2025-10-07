//
//  WatchContentView.swift
//  PassiVerdi Watch App
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # WatchContentView
 
 Vista principale dell'app Apple Watch.
 
 ## Features:
 - Visualizzazione punti correnti
 - Statistiche giornaliere
 - Km percorsi oggi
 - CO₂ risparmiata
 - Sincronizzazione con iPhone
 */
struct WatchContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var watchConnectivity: WatchConnectivityManager
    
    // MARK: - State
    
    @State private var todayPoints: Int = 0
    @State private var todayKilometers: Double = 0.0
    @State private var todayCO2Saved: Double = 0.0
    @State private var totalPoints: Int = 0
    @State private var currentLevel: Int = 1
    @State private var userName: String = "Utente"
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            // Tab 1: Statistiche principali
            mainStatsView
            
            // Tab 2: Dettagli giorno
            todayDetailsView
            
            // Tab 3: Livello e punti
            levelView
        }
        .tabViewStyle(.page)
        .onAppear {
            requestSyncFromiPhone()
        }
        .onChange(of: watchConnectivity.lastMessage) { _, newMessage in
            handleReceivedData(newMessage)
        }
    }
    
    // MARK: - Views
    
    /// Vista statistiche principali
    private var mainStatsView: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Header
                VStack(spacing: 5) {
                    Image(systemName: "leaf.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("PassiVerdi")
                        .font(.headline)
                }
                .padding(.top)
                
                // Punti oggi
                VStack(spacing: 8) {
                    Text("Punti Oggi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(todayPoints)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.green)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("Punti Verdi")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
                
                // Stats compatte
                VStack(spacing: 10) {
                    StatRow(
                        icon: "location.fill",
                        label: "Distanza",
                        value: String(format: "%.1f km", todayKilometers),
                        color: .blue
                    )
                    
                    StatRow(
                        icon: "leaf.fill",
                        label: "CO₂ risparmiata",
                        value: String(format: "%.1f kg", todayCO2Saved),
                        color: .orange
                    )
                }
            }
            .padding()
        }
    }
    
    /// Vista dettagli giornata
    private var todayDetailsView: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Oggi")
                    .font(.headline)
                    .padding(.top)
                
                // Card km
                DetailCard(
                    icon: "figure.walk",
                    title: "Chilometri",
                    value: String(format: "%.2f", todayKilometers),
                    unit: "km",
                    color: .blue
                )
                
                // Card punti
                DetailCard(
                    icon: "star.fill",
                    title: "Punti",
                    value: "\(todayPoints)",
                    unit: "pt",
                    color: .green
                )
                
                // Card CO2
                DetailCard(
                    icon: "cloud.fill",
                    title: "CO₂",
                    value: String(format: "%.2f", todayCO2Saved),
                    unit: "kg",
                    color: .orange
                )
            }
            .padding()
        }
    }
    
    /// Vista livello e progresso
    private var levelView: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text(userName)
                    .font(.headline)
                    .padding(.top)
                
                // Livello
                VStack(spacing: 10) {
                    Text("Livello")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text("\(currentLevel)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
                
                // Punti totali
                VStack(spacing: 5) {
                    Text("Punti Totali")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Pulsante sync
                Button {
                    requestSyncFromiPhone()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sincronizza")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Views
    
    private struct StatRow: View {
        let icon: String
        let label: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
        }
    }
    
    private struct DetailCard: View {
        let icon: String
        let title: String
        let value: String
        let unit: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Data Handling
    
    /**
     Richiede la sincronizzazione dei dati dall'iPhone
     */
    private func requestSyncFromiPhone() {
        let message: [String: Any] = [
            "type": "requestSync",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        watchConnectivity.sendMessage(message) { reply in
            print("⌚ Risposta ricevuta dall'iPhone: \(reply)")
        } errorHandler: { error in
            print("⌚ Errore sync: \(error.localizedDescription)")
        }
    }
    
    /**
     Gestisce i dati ricevuti dall'iPhone
     */
    private func handleReceivedData(_ data: [String: Any]) {
        guard let type = data["type"] as? String else { return }
        
        switch type {
        case "userProfile":
            if let name = data["fullName"] as? String {
                userName = name
            }
            if let points = data["totalPoints"] as? Int {
                totalPoints = points
            }
            if let level = data["level"] as? Int {
                currentLevel = level
            }
            print("⌚ Profilo aggiornato")
            
        case "dailyStats":
            if let points = data["todayPoints"] as? Int {
                todayPoints = points
            }
            if let km = data["todayKilometers"] as? Double {
                todayKilometers = km
            }
            if let co2 = data["todayCO2Saved"] as? Double {
                todayCO2Saved = co2
            }
            print("⌚ Statistiche giornaliere aggiornate")
            
        case "newActivity":
            print("⌚ Nuova attività ricevuta")
            // Aggiorna le statistiche
            requestSyncFromiPhone()
            
        default:
            print("⌚ Tipo messaggio non gestito: \(type)")
        }
    }
}

// MARK: - Preview

#Preview {
    WatchContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
