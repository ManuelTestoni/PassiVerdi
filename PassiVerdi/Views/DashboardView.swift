//
//  DashboardView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI
import Charts

/**
 # DashboardView
 
 Vista principale con panoramica delle statistiche e attività.
 
 ## Features:
 - Punti e livello corrente
 - Statistiche giornaliere
 - Ultime attività
 - Grafici e visualizzazioni
 */
struct DashboardView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var motionManager: MotionManager
    
    // MARK: - State
    
    @State private var selectedPeriod: StatsPeriod = .week
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con punti e livello
                    pointsHeader
                    
                    // Statistiche oggi
                    todayStatsSection
                    
                    // Grafico attività
                    activityChartSection
                    
                    // Ultime attività
                    recentActivitiesSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // Test: aggiungi attività di esempio
                            addSampleActivity()
                        } label: {
                            Label("Aggiungi attività test", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    // MARK: - Components
    
    /// Header con punti e livello
    private var pointsHeader: some View {
        VStack(spacing: 15) {
            // Punti totali
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Punti Verdi")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(pointsManager.totalPoints)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Livello
                VStack(spacing: 5) {
                    Text("Livello")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.green, .green.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        Text("\(pointsManager.currentLevel)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Barra progresso verso prossimo livello
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Prossimo livello")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(pointsManager.pointsToNextLevel) punti")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progressToNextLevel)
                    .tint(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Statistiche di oggi
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Oggi")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                // Punti oggi
                StatCard(
                    icon: "star.fill",
                    value: "\(pointsManager.todayPoints)",
                    label: "Punti",
                    color: .green
                )
                
                // Km oggi
                StatCard(
                    icon: "location.fill",
                    value: String(format: "%.1f", pointsManager.todayKilometers),
                    label: "km",
                    color: .blue
                )
                
                // CO₂ risparmiata
                StatCard(
                    icon: "leaf.fill",
                    value: String(format: "%.1f", pointsManager.todayCO2Saved),
                    label: "kg CO₂",
                    color: .orange
                )
            }
            
            // Streak
            if pointsManager.currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(pointsManager.currentStreak) giorni consecutivi!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    /// Grafico attività per periodo
    private var activityChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Attività")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Picker periodo
                Picker("Periodo", selection: $selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if #available(iOS 16.0, *) {
                activityChart
            } else {
                Text("Grafici disponibili da iOS 16")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Grafico delle attività
    @available(iOS 16.0, *)
    private var activityChart: some View {
        let stats = pointsManager.getStats(for: selectedPeriod)
        
        return VStack {
            if stats.totalActivities > 0 {
                Chart {
                    ForEach(Array(stats.byTransportType.keys), id: \.self) { type in
                        if let activities = stats.byTransportType[type] {
                            BarMark(
                                x: .value("Tipo", type.rawValue),
                                y: .value("Distanza", activities.reduce(0.0) { $0 + $1.distance })
                            )
                            .foregroundStyle(by: .value("Tipo", type.rawValue))
                        }
                    }
                }
                .frame(height: 200)
                .chartForegroundStyleScale([
                    TransportType.walking.rawValue: .green,
                    TransportType.cycling.rawValue: .blue,
                    TransportType.publicTransport.rawValue: .orange
                ])
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("Nessuna attività registrata")
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
    }
    
    /// Ultime attività
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Attività Recenti")
                .font(.title2)
                .fontWeight(.bold)
            
            if pointsManager.activities.isEmpty {
                emptyActivitiesView
            } else {
                ForEach(pointsManager.activities.prefix(5)) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
    
    /// Vista vuota quando non ci sono attività
    private var emptyActivitiesView: some View {
        VStack(spacing: 15) {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Nessuna attività ancora")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Inizia a muoverti in modo sostenibile per guadagnare punti!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Views
    
    private struct StatCard: View {
        let icon: String
        let value: String
        let label: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private struct ActivityRow: View {
        let activity: Activity
        
        var body: some View {
            HStack(spacing: 15) {
                // Icona tipo trasporto
                Image(systemName: activity.transportType.icon)
                    .font(.title2)
                    .foregroundColor(transportColor)
                    .frame(width: 40)
                
                // Info attività
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.transportType.rawValue)
                        .font(.headline)
                    
                    Text(activity.startDate, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Statistiche
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f km", activity.distance))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("+\(activity.pointsEarned) punti")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        
        private var transportColor: Color {
            switch activity.transportType {
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
    
    // MARK: - Computed Properties
    
    /// Progresso verso il prossimo livello (0.0 - 1.0)
    private var progressToNextLevel: Double {
        let pointsInCurrentLevel = pointsManager.totalPoints % 100
        return Double(pointsInCurrentLevel) / 100.0
    }
    
    // MARK: - Actions
    
    /**
     Aggiunge un'attività di esempio (per testing)
     */
    private func addSampleActivity() {
        let randomTypes: [TransportType] = [.walking, .cycling, .publicTransport]
        let randomType = randomTypes.randomElement() ?? .walking
        let randomDistance = Double.random(in: 1.0...10.0)
        
        let activity = Activity(
            transportType: randomType,
            distance: randomDistance,
            startDate: Date().addingTimeInterval(-3600),
            endDate: Date()
        )
        
        pointsManager.addActivity(activity)
        print("✅ Attività di test aggiunta: \(randomType.rawValue) - \(randomDistance) km")
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environmentObject(PointsManager())
        .environmentObject(LocationManager())
        .environmentObject(MotionManager())
}
