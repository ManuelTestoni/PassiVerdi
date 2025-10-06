//
//  ChallengesView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedFilter: ChallengeFilter = .all
    
    enum ChallengeFilter: String, CaseIterable {
        case all = "Tutte"
        case active = "Attive"
        case completed = "Completate"
    }
    
    var filteredChallenges: [Challenge] {
        switch selectedFilter {
        case .all:
            return userManager.challenges
        case .active:
            return userManager.challenges.filter { !$0.isCompleted }
        case .completed:
            return userManager.challenges.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter picker
                Picker("Filtro", selection: $selectedFilter) {
                    ForEach(ChallengeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(spacing: 15) {
                        if filteredChallenges.isEmpty {
                            EmptyStateView(
                                icon: "target",
                                title: "Nessuna sfida",
                                description: "Le sfide appariranno qui"
                            )
                            .padding(.top, 50)
                        } else {
                            ForEach(filteredChallenges) { challenge in
                                ChallengeCardView(challenge: challenge)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Sfide")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: challenge.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(challenge.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        if challenge.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(challenge.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(challengeTypeColor(challenge.type))
                        .cornerRadius(8)
                }
            }
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Progress bar
            if !challenge.isCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(challenge.currentValue) / \(challenge.targetValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(challenge.progressPercentage)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * challenge.progress)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            // Reward
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Ricompensa: \(challenge.reward) punti")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !challenge.isCompleted {
                    Text(timeRemaining(until: challenge.endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    func challengeTypeColor(_ type: ChallengeType) -> Color {
        switch type {
        case .daily:
            return .orange
        case .weekly:
            return .blue
        case .monthly:
            return .purple
        case .special:
            return .red
        }
    }
    
    func timeRemaining(until date: Date) -> String {
        let remaining = date.timeIntervalSince(Date())
        
        if remaining < 0 {
            return "Scaduta"
        }
        
        let days = Int(remaining) / 86400
        let hours = Int(remaining) / 3600 % 24
        
        if days > 0 {
            return "\(days)g \(hours)h rimanenti"
        } else if hours > 0 {
            return "\(hours)h rimanenti"
        } else {
            let minutes = Int(remaining) / 60
            return "\(minutes)m rimanenti"
        }
    }
}

#Preview {
    ChallengesView()
        .environmentObject(UserManager())
}
