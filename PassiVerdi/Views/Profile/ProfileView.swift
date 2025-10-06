//
//  ProfileView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var userManager: UserManager
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    ProfileHeaderView()
                    
                    // Badges section
                    BadgesSectionView()
                    
                    // Statistics section
                    ProfileStatisticsView()
                    
                    // Settings and actions
                    SettingsSectionView(
                        showEditProfile: $showEditProfile,
                        showSettings: $showSettings
                    )
                }
                .padding()
            }
            .navigationTitle("Profilo")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text(userManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Name and city
            VStack(spacing: 5) {
                Text(userManager.currentUser?.name ?? "Utente")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(userManager.currentUser?.city ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Member since
            Text("Membro da \(memberSince)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: userManager.currentUser?.createdAt ?? Date())
    }
}

struct BadgesSectionView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Badge sbloccati")
                .font(.headline)
            
            if userManager.currentUser?.badges.isEmpty ?? true {
                EmptyStateView(
                    icon: "medal.fill",
                    title: "Nessun badge ancora",
                    description: "Completa attività e sfide per sbloccare badge"
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(userManager.currentUser?.badges ?? []) { badge in
                        BadgeItemView(badge: badge)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct BadgeItemView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.iconName)
                .font(.system(size: 35))
                .foregroundColor(.green)
            
            Text(badge.title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProfileStatisticsView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Le tue statistiche")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRowView(
                    icon: "leaf.fill",
                    title: "Punti totali",
                    value: "\(userManager.currentUser?.totalPoints ?? 0)",
                    color: .green
                )
                
                StatRowView(
                    icon: "figure.walk",
                    title: "Km percorsi",
                    value: String(format: "%.1f", userManager.currentUser?.totalKilometers ?? 0),
                    color: .blue
                )
                
                StatRowView(
                    icon: "cloud.sun.fill",
                    title: "CO₂ risparmiata",
                    value: String(format: "%.1f kg", userManager.currentUser?.totalCO2Saved ?? 0),
                    color: .orange
                )
                
                StatRowView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Attività totali",
                    value: "\(userManager.activities.count)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct StatRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsSectionView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var showEditProfile: Bool
    @Binding var showSettings: Bool
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                showEditProfile = true
            }) {
                SettingRowView(icon: "person.circle", title: "Modifica profilo", color: .blue)
            }
            
            Button(action: {
                // TODO: Open settings
            }) {
                SettingRowView(icon: "gear", title: "Impostazioni", color: .gray)
            }
            
            Button(action: {
                // TODO: Open help
            }) {
                SettingRowView(icon: "questionmark.circle", title: "Aiuto e supporto", color: .green)
            }
            
            Button(action: {
                // TODO: Open privacy
            }) {
                SettingRowView(icon: "hand.raised", title: "Privacy", color: .orange)
            }
            
            Divider()
                .padding(.vertical, 5)
            
            Button(action: {
                showLogoutAlert = true
            }) {
                SettingRowView(icon: "rectangle.portrait.and.arrow.right", title: "Esci", color: .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .alert("Conferma uscita", isPresented: $showLogoutAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Esci", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Sei sicuro di voler uscire?")
        }
    }
}

struct SettingRowView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(UserManager())
}
