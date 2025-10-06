//
//  WatchMainView.swift
//  PassiVerdi Watch Watch App
//
//  Created on 06/10/2025.
//

import SwiftUI

struct WatchMainView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    
    var body: some View {
        TabView {
            WatchDashboardView()
                .environmentObject(connectivity)
            
            WatchStatsView()
                .environmentObject(connectivity)
            
            WatchMotivationView()
                .environmentObject(connectivity)
        }
        .tabViewStyle(.page)
        .onAppear {
            connectivity.requestUpdate()
        }
    }
}

struct WatchDashboardView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            
            Text("\(connectivity.totalPoints)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("Punti Verdi")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                    Text(String(format: "%.1f km", connectivity.todayKm))
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "cloud.sun")
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f kg CO₂", connectivity.todayCO2))
                        .font(.caption)
                }
            }
        }
        .padding()
    }
}

struct WatchStatsView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Statistiche Oggi")
                    .font(.headline)
                    .padding(.top)
                
                StatCircle(
                    value: String(format: "%.1f", connectivity.todayKm),
                    unit: "km",
                    icon: "figure.walk",
                    color: .blue
                )
                
                StatCircle(
                    value: String(format: "%.1f", connectivity.todayCO2),
                    unit: "kg CO₂",
                    icon: "cloud.sun.fill",
                    color: .green
                )
                
                StatCircle(
                    value: "\(connectivity.totalPoints)",
                    unit: "punti",
                    icon: "leaf.fill",
                    color: .orange
                )
            }
            .padding()
        }
    }
}

struct StatCircle: View {
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(color, lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct WatchMotivationView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    
    let motivations = [
        "Ottimo lavoro! 🌱",
        "Continua così! 💚",
        "Sei un campione! 🏆",
        "Fantastico! 🌍",
        "Grande impatto! ⭐️"
    ]
    
    var randomMotivation: String {
        motivations.randomElement() ?? "Ottimo lavoro!"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text(randomMotivation)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if connectivity.todayCO2 > 0 {
                Text("Oggi hai risparmiato")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f kg", connectivity.todayCO2))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("di CO₂")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    WatchMainView()
        .environmentObject(WatchConnectivityManager())
}
