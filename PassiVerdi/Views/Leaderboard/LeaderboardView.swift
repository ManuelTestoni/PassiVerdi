//
//  LeaderboardView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var pointsManager: PointsManager
    @State private var selectedScope: LeaderboardScope = .city
    
    enum LeaderboardScope: String, CaseIterable {
        case city = "Città"
        case region = "Regione"
        case national = "Nazionale"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scope picker
                Picker("Ambito", selection: $selectedScope) {
                    ForEach(LeaderboardScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(spacing: 15) {
                        // Top 3 podium
                        TopThreeView()
                        
                        // Rest of leaderboard
                        VStack(spacing: 10) {
                            ForEach(pointsManager.getLeaderboard().dropFirst(3)) { entry in
                                LeaderboardRowView(entry: entry)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Classifica")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct TopThreeView: View {
    @EnvironmentObject var pointsManager: PointsManager
    
    var topThree: [LeaderboardEntry] {
        Array(pointsManager.getLeaderboard().prefix(3))
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            // 2nd place
            if topThree.count > 1 {
                PodiumCard(entry: topThree[1], place: 2, height: 120)
            }
            
            // 1st place
            if topThree.count > 0 {
                PodiumCard(entry: topThree[0], place: 1, height: 160)
            }
            
            // 3rd place
            if topThree.count > 2 {
                PodiumCard(entry: topThree[2], place: 3, height: 100)
            }
        }
        .padding()
    }
}

struct PodiumCard: View {
    let entry: LeaderboardEntry
    let place: Int
    let height: CGFloat
    
    var medalColor: Color {
        switch place {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .gray
        }
    }
    
    var medalEmoji: String {
        switch place {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(medalEmoji)
                .font(.system(size: 40))
            
            Circle()
                .fill(medalColor.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("\(place)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(medalColor)
                )
            
            Text(entry.name)
                .font(.subheadline)
                .fontWeight(entry.isCurrentUser ? .bold : .regular)
                .foregroundColor(entry.isCurrentUser ? .green : .primary)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                Text("\(entry.points)")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(entry.isCurrentUser ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text("\(entry.rank)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // Avatar placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 45, height: 45)
                .overlay(
                    Text(entry.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(entry.isCurrentUser ? .bold : .regular)
                
                Text(entry.city)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("\(entry.points)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(entry.isCurrentUser ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(PointsManager())
}
