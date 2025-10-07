//
//  StatisticsView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI
import Charts

/**
 # StatisticsView
 
 Vista dettagliata con statistiche e analisi approfondite.
 
 ## Features:
 - Statistiche per periodo
 - Breakdown per tipo di trasporto
 - Trend e comparazioni
 - Impatto ambientale dettagliato
 */
struct StatisticsView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var pointsManager: PointsManager
    
    // MARK: - State
    
    @State private var selectedPeriod: StatsPeriod = .month
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Picker periodo
                    periodPicker
                    
                    // Statistiche principali
                    mainStats
                    
                    // Breakdown per trasporto
                    transportBreakdown
                    
                    // Impatto ambientale
                    environmentalImpact
                    
                    // Comparazioni
                    comparisons
                }
                .padding()
            }
            .navigationTitle("Statistiche")
        }
    }
    
    // MARK: - Components
    
    /// Picker per selezionare il periodo
    private var periodPicker: some View {
        Picker("Periodo", selection: $selectedPeriod) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    /// Statistiche principali
    private var mainStats: some View {
        let stats = pointsManager.getStats(for: selectedPeriod)
        
        return VStack(spacing: 15) {
            Text("Panoramica \(selectedPeriod.rawValue)")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatBox(
                    title: "Attività",
                    value: "\(stats.totalActivities)",
                    icon: "figure.walk",
                    color: .purple
                )
                
                StatBox(
                    title: "Punti",
                    value: "\(stats.totalPoints)",
                    icon: "star.fill",
                    color: .green
                )
                
                StatBox(
                    title: "Distanza",
                    value: String(format: "%.1f km", stats.totalDistance),
                    icon: "location.fill",
                    color: .blue
                )
                
                StatBox(
                    title: "CO₂ risparmiata",
                    value: String(format: "%.1f kg", stats.totalCO2Saved),
                    icon: "leaf.fill",
                    color: .orange
                )
            }
        }
    }
    
    /// Breakdown per tipo di trasporto
    private var transportBreakdown: some View {
        let stats = pointsManager.getStats(for: selectedPeriod)
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Per Tipo di Trasporto")
                .font(.title2)
                .fontWeight(.bold)
            
            if stats.totalActivities > 0 {
                ForEach(Array(stats.byTransportType.keys.sorted(by: { type1, type2 in
                    let dist1 = stats.byTransportType[type1]?.reduce(0.0) { $0 + $1.distance } ?? 0
                    let dist2 = stats.byTransportType[type2]?.reduce(0.0) { $0 + $1.distance } ?? 0
                    return dist1 > dist2
                })), id: \.self) { type in
                    if let activities = stats.byTransportType[type], !activities.isEmpty {
                        TransportTypeRow(
                            type: type,
                            activities: activities
                        )
                    }
                }
            } else {
                emptyStateView
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Impatto ambientale dettagliato
    private var environmentalImpact: some View {
        let stats = pointsManager.getStats(for: selectedPeriod)
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Impatto Ambientale")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ImpactRow(
                    icon: "leaf.fill",
                    title: "CO₂ risparmiata",
                    value: String(format: "%.2f kg", stats.totalCO2Saved),
                    description: "Equivalente a \(Int(stats.totalCO2Saved / 0.5)) alberi piantati"
                )
                
                ImpactRow(
                    icon: "fuelpump.fill",
                    title: "Benzina risparmiata",
                    value: String(format: "%.2f L", stats.totalDistance * 0.06),
                    description: "Basato su consumo medio 6L/100km"
                )
                
                ImpactRow(
                    icon: "dollarsign.circle.fill",
                    title: "Denaro risparmiato",
                    value: String(format: "%.2f €", stats.totalDistance * 0.15),
                    description: "Costo stimato carburante + parcheggio"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Comparazioni e insights
    private var comparisons: some View {
        let stats = pointsManager.getStats(for: selectedPeriod)
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Lo Sapevi?")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if stats.totalDistance > 0 {
                    InsightCard(
                        icon: "globe.europe.africa.fill",
                        text: "Hai percorso l'equivalente di attraversare \(Int(stats.totalDistance / 42.195)) maratone!",
                        color: .blue
                    )
                }
                
                if stats.totalCO2Saved > 10 {
                    InsightCard(
                        icon: "tree.fill",
                        text: "La CO₂ che hai risparmiato corrisponde a \(Int(stats.totalCO2Saved / 21.77)) kg di ossigeno prodotto!",
                        color: .green
                    )
                }
                
                if stats.totalActivities > 20 {
                    InsightCard(
                        icon: "heart.fill",
                        text: "Con \(stats.totalActivities) attività, hai bruciato circa \(stats.totalActivities * 50) calorie!",
                        color: .red
                    )
                }
            }
        }
    }
    
    /// Vista quando non ci sono dati
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Nessun dato disponibile")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Inizia a registrare attività per vedere le statistiche")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Views
    
    private struct StatBox: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private struct TransportTypeRow: View {
        let type: TransportType
        let activities: [Activity]
        
        var body: some View {
            let totalDistance = activities.reduce(0.0) { $0 + $1.distance }
            let totalPoints = activities.reduce(0) { $0 + $1.pointsEarned }
            
            HStack(spacing: 15) {
                // Icona
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                    
                    Text("\(activities.count) attività")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Statistiche
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f km", totalDistance))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(totalPoints) punti")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        
        private var iconColor: Color {
            switch type {
            case .walking:
                return .green
            case .cycling:
                return .blue
            case .publicTransport:
                return .orange
            case .car:
                return .red
            case .unknown:
                return .gray
            }
        }
    }
    
    private struct ImpactRow: View {
        let icon: String
        let title: String
        let value: String
        let description: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private struct InsightCard: View {
        let icon: String
        let text: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview

#Preview {
    StatisticsView()
        .environmentObject(PointsManager())
}
