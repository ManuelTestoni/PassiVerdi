//
//  ProfileView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # ProfileView
 
 Vista del profilo utente con informazioni e impostazioni.
 
 ## Features:
 - Informazioni profilo
 - Statistiche globali
 - Impostazioni app
 - Sincronizzazione iCloud
 */
struct ProfileView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var motionManager: MotionManager
    
    // MARK: - State
    
    @State private var userProfile: UserProfile?
    @State private var showEditProfile = false
    @State private var showResetAlert = false
    @State private var isTrackingEnabled = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header profilo
                    profileHeader
                    
                    // Statistiche globali
                    globalStats
                    
                    // Impostazioni
                    settingsSection
                    
                    // Info app
                    appInfoSection
                }
                .padding()
            }
            .navigationTitle("Profilo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(profile: $userProfile)
            }
            .alert("Reset Dati", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Sei sicuro di voler resettare tutti i dati? Questa azione è irreversibile.")
            }
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    // MARK: - Components
    
    /// Header con avatar e info base
    private var profileHeader: some View {
        VStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(userProfile?.fullName.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Nome e città
            VStack(spacing: 5) {
                Text(userProfile?.fullName ?? "Utente")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(userProfile?.city ?? "")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // Livello e punti
            HStack(spacing: 30) {
                VStack {
                    Text("Livello")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(pointsManager.currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("Punti")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(pointsManager.totalPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(pointsManager.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Statistiche globali
    private var globalStats: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistiche Totali")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatItem(
                    icon: "figure.walk",
                    title: "Attività",
                    value: "\(pointsManager.activities.count)",
                    color: .purple
                )
                
                StatItem(
                    icon: "location.fill",
                    title: "Distanza",
                    value: String(format: "%.1f km", totalDistance),
                    color: .blue
                )
                
                StatItem(
                    icon: "leaf.fill",
                    title: "CO₂ risparmiata",
                    value: String(format: "%.1f kg", totalCO2),
                    color: .orange
                )
                
                StatItem(
                    icon: "star.fill",
                    title: "Badge",
                    value: "\(earnedBadgesCount)",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Sezione impostazioni
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Impostazioni")
                .font(.headline)
            
            VStack(spacing: 0) {
                // Tracking automatico
                Toggle(isOn: $isTrackingEnabled) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tracking Automatico")
                                .font(.body)
                            Text("Rileva automaticamente i tuoi spostamenti")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .onChange(of: isTrackingEnabled) { _, newValue in
                    if newValue {
                        locationManager.startTracking()
                        motionManager.startTracking()
                    } else {
                        locationManager.stopTracking()
                        motionManager.stopTracking()
                    }
                }
                
                Divider()
                    .padding(.leading, 45)
                
                // Sincronizzazione iCloud
                Button {
                    syncWithiCloud()
                } label: {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sincronizza con iCloud")
                                .font(.body)
                            
                            if cloudKitManager.isSyncing {
                                HStack(spacing: 5) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                    Text("Sincronizzazione...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else if cloudKitManager.isAvailable {
                                Text("Ultima sincronizzazione: ora")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("iCloud non disponibile")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .disabled(cloudKitManager.isSyncing)
                
                Divider()
                    .padding(.leading, 45)
                
                // Reset dati
                Button {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reset Dati")
                                .font(.body)
                                .foregroundColor(.red)
                            Text("Elimina tutti i dati dell'app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    /// Info app
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Info App")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoRow(label: "Versione", value: "1.0.0")
                InfoRow(label: "Build", value: "1")
                InfoRow(label: "Dispositivo", value: deviceModel)
                InfoRow(label: "iOS", value: iosVersion)
            }
            
            // Link utili
            VStack(spacing: 10) {
                Button {
                    // TODO: Apri privacy policy
                } label: {
                    Text("Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button {
                    // TODO: Apri termini di servizio
                } label: {
                    Text("Termini di Servizio")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper Views
    
    private struct StatItem: View {
        let icon: String
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private struct InfoRow: View {
        let label: String
        let value: String
        
        var body: some View {
            HStack {
                Text(label)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalDistance: Double {
        pointsManager.activities.reduce(0.0) { $0 + $1.distance }
    }
    
    private var totalCO2: Double {
        pointsManager.activities.reduce(0.0) { $0 + $1.co2Saved }
    }
    
    private var earnedBadgesCount: Int {
        pointsManager.badges.filter { $0.isEarned }.count
    }
    
    private var deviceModel: String {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
        return modelCode
        #endif
    }
    
    private var iosVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    // MARK: - Actions
    
    /**
     Carica il profilo utente
     */
    private func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }
    
    /**
     Sincronizza i dati con iCloud
     */
    private func syncWithiCloud() {
        guard let profile = userProfile else { return }
        
        Task {
            do {
                try await cloudKitManager.saveUserProfile(profile)
                print("✅ Sincronizzazione completata")
            } catch {
                print("❌ Errore sincronizzazione: \(error)")
            }
        }
    }
    
    /**
     Resetta tutti i dati dell'app
     */
    private func resetAllData() {
        // Reset UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Reset managers
        pointsManager.activities.removeAll()
        pointsManager.totalPoints = 0
        pointsManager.currentLevel = 1
        pointsManager.currentStreak = 0
        
        locationManager.resetSession()
        motionManager.resetSession()
        
        print("🔄 Dati resettati")
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Binding var profile: UserProfile?
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var city = ""
    @State private var age = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informazioni Personali") {
                    TextField("Nome completo", text: $fullName)
                    TextField("Città", text: $city)
                    TextField("Età", text: $age)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                fullName = profile?.fullName ?? ""
                city = profile?.city ?? ""
                if let profileAge = profile?.age {
                    age = "\(profileAge)"
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = profile ?? UserProfile(fullName: fullName, city: city)
        updatedProfile.fullName = fullName
        updatedProfile.city = city
        if let ageInt = Int(age) {
            updatedProfile.age = ageInt
        }
        
        profile = updatedProfile
        
        // Salva su UserDefaults
        if let encoded = try? JSONEncoder().encode(updatedProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
        
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(PointsManager())
        .environmentObject(CloudKitManager())
        .environmentObject(LocationManager())
        .environmentObject(MotionManager())
}
