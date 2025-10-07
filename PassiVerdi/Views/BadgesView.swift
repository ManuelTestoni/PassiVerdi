//
//  BadgesView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # BadgesView
 
 Vista per visualizzare tutti i badge disponibili e quelli ottenuti.
 
 ## Features:
 - Griglia di tutti i badge
 - Filtro per categoria
 - Progressione verso badge non ottenuti
 - Dettaglio badge con data di sblocco
 */
struct BadgesView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var pointsManager: PointsManager
    
    // MARK: - State
    
    @State private var selectedCategory: BadgeCategory?
    @State private var showOnlyEarned = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistiche badge
                    badgeStats
                    
                    // Filtri
                    filterSection
                    
                    // Griglia badge
                    badgeGrid
                }
                .padding()
            }
            .navigationTitle("Badge")
        }
    }
    
    // MARK: - Components
    
    /// Statistiche badge ottenuti
    private var badgeStats: some View {
        let earnedCount = pointsManager.badges.filter { $0.isEarned }.count
        let totalCount = pointsManager.badges.count
        let progress = Double(earnedCount) / Double(totalCount)
        
        return VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Badge Ottenuti")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(earnedCount) / \(totalCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Percentuale circolare
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Barra progresso
            ProgressView(value: progress)
                .tint(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Sezione filtri
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Toggle mostra solo ottenuti
            Toggle("Solo badge ottenuti", isOn: $showOnlyEarned)
                .padding(.horizontal)
            
            // Filtro per categoria
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryButton(
                        category: nil,
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach([BadgeCategory.distance, .points, .activities, .streak, .special], id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Griglia di badge
    private var badgeGrid: some View {
        let filteredBadges = getFilteredBadges()
        
        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            ForEach(filteredBadges) { badge in
                BadgeCard(badge: badge)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private struct CategoryButton: View {
        let category: BadgeCategory?
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: category?.icon ?? "square.grid.2x2")
                        .font(.caption)
                    
                    Text(category?.rawValue ?? "Tutti")
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? category?.color ?? .blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
            }
        }
    }
    
    private struct BadgeCard: View {
        let badge: Badge
        
        var body: some View {
            VStack(spacing: 12) {
                // Icona badge
                ZStack {
                    Circle()
                        .fill(
                            badge.isEarned
                                ? LinearGradient(
                                    colors: [badge.color, badge.color.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(badge.isEarned ? .white : .gray)
                    
                    // Lucchetto se non ottenuto
                    if !badge.isEarned {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .offset(x: 28, y: -28)
                    }
                }
                
                // Nome badge
                Text(badge.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Descrizione
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                if badge.isEarned {
                    // Data ottenimento
                    if let earnedDate = badge.earnedDate {
                        Text("Ottenuto il \(earnedDate, format: .dateTime.day().month())")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                } else {
                    // Progressione
                    VStack(spacing: 4) {
                        ProgressView(value: badge.progress)
                            .tint(badge.color)
                        
                        Text("\(badge.progressPercentage)%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .opacity(badge.isEarned ? 1.0 : 0.6)
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     Filtra i badge in base ai criteri selezionati
     */
    private func getFilteredBadges() -> [Badge] {
        var filtered = pointsManager.badges
        
        // Filtra per categoria
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filtra solo ottenuti
        if showOnlyEarned {
            filtered = filtered.filter { $0.isEarned }
        }
        
        // Ordina: ottenuti per primi, poi per progresso
        return filtered.sorted { badge1, badge2 in
            if badge1.isEarned != badge2.isEarned {
                return badge1.isEarned
            }
            return badge1.progress > badge2.progress
        }
    }
}

// MARK: - Preview

#Preview {
    BadgesView()
        .environmentObject(PointsManager())
}
