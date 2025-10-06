//
//  DashboardView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con punti
                    PointsHeaderView()
                    
                    // Statistiche principali
                    StatisticsCardsView()
                    
                    // Grafico attività settimanale
                    WeeklyActivityChartView()
                    
                    // Attività recenti
                    RecentActivitiesView()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct PointsHeaderView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Punti Verdi")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(userManager.currentUser?.totalPoints ?? 0)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.green)
            
            Text("Continua così! 🌱")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct StatisticsCardsView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                StatCard(
                    icon: "figure.walk",
                    title: "Km percorsi",
                    value: String(format: "%.1f", userManager.currentUser?.totalKilometers ?? 0),
                    color: .blue
                )
                
                StatCard(
                    icon: "cloud.sun.fill",
                    title: "CO₂ risparmiata",
                    value: String(format: "%.1f kg", userManager.currentUser?.totalCO2Saved ?? 0),
                    color: .green
                )
            }
            
            HStack(spacing: 15) {
                StatCard(
                    icon: "calendar",
                    title: "Attività oggi",
                    value: "\(userManager.getTodayActivities().count)",
                    color: .orange
                )
                
                StatCard(
                    icon: "medal.fill",
                    title: "Badge sbloccati",
                    value: "\(userManager.currentUser?.badges.count ?? 0)",
                    color: .purple
                )
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct WeeklyActivityChartView: View {
    @EnvironmentObject var userManager: UserManager
    
    var weeklyData: [(String, Double)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(String, Double)] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayActivities = userManager.activities.filter {
                    calendar.isDate($0.startTime, inSameDayAs: date)
                }
                let totalKm = dayActivities.reduce(0.0) { $0 + $1.distance }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                let dayName = formatter.string(from: date)
                
                data.append((dayName, totalKm))
            }
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Attività settimanale")
                .font(.headline)
            
            Chart {
                ForEach(weeklyData, id: \.0) { day, km in
                    BarMark(
                        x: .value("Giorno", day),
                        y: .value("Km", km)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .cornerRadius(5)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct RecentActivitiesView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Attività recenti")
                .font(.headline)
            
            if userManager.activities.isEmpty {
                EmptyStateView(
                    icon: "figure.walk.circle",
                    title: "Nessuna attività",
                    description: "Inizia a tracciare i tuoi spostamenti sostenibili"
                )
            } else {
                ForEach(userManager.activities.prefix(5)) { activity in
                    ActivityRowView(activity: activity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct ActivityRowView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: activity.transportType.iconName)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.transportType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(activity.formattedDistance)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(activity.pointsEarned) pt")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(activity.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserManager())
}
