//
//  OnboardingView.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import SwiftUI

/**
 # OnboardingView
 
 Vista di benvenuto e registrazione per nuovi utenti.
 
 ## Features:
 - Raccolta informazioni base (nome, città)
 - Spiegazione funzionalità app
 - Richiesta permessi
 - Creazione profilo iniziale
 */
struct OnboardingView: View {
    
    // MARK: - Binding
    
    @Binding var isComplete: Bool
    
    // MARK: - Environment
    
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    // MARK: - State
    
    @State private var currentPage = 0
    @State private var fullName = ""
    @State private var city = ""
    @State private var age = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Pagina 1: Benvenuto
            welcomePage
                .tag(0)
            
            // Pagina 2: Come funziona
            howItWorksPage
                .tag(1)
            
            // Pagina 3: Registrazione
            registrationPage
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .alert("Attenzione", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Welcome Page
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Logo/Icona
            Image(systemName: "leaf.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("PassiVerdi")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Ogni passo conta.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "figure.walk", text: "Traccia i tuoi spostamenti sostenibili")
                FeatureRow(icon: "star.fill", text: "Guadagna punti verdi")
                FeatureRow(icon: "trophy.fill", text: "Sblocca badge e ricompense")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Monitora il tuo impatto ambientale")
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                withAnimation {
                    currentPage = 1
                }
            } label: {
                Text("Inizia")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - How It Works Page
    
    private var howItWorksPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Come Funziona")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 25) {
                StepView(
                    number: "1",
                    icon: "location.fill",
                    title: "Tracciamento Automatico",
                    description: "L'app rileva automaticamente i tuoi spostamenti usando GPS e sensori"
                )
                
                StepView(
                    number: "2",
                    icon: "bicycle",
                    title: "Riconoscimento Mezzo",
                    description: "Identifica se stai camminando, pedalando o usando i mezzi pubblici"
                )
                
                StepView(
                    number: "3",
                    icon: "leaf.fill",
                    title: "Punti Verdi",
                    description: "Guadagni punti per ogni km percorso in modo sostenibile"
                )
                
                StepView(
                    number: "4",
                    icon: "chart.bar.fill",
                    title: "Monitora l'Impatto",
                    description: "Visualizza quanta CO₂ hai risparmiato all'ambiente"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                withAnimation {
                    currentPage = 2
                }
            } label: {
                Text("Continua")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Registration Page
    
    private var registrationPage: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Crea il tuo Profilo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    // Nome completo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nome completo")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Mario Rossi", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Città
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Città")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Milano", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Età (opzionale)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Età (opzionale)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("25", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                }
                .padding(.horizontal, 30)
                
                // Info permessi
                VStack(spacing: 15) {
                    Text("Permessi Necessari")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    PermissionRow(icon: "location.fill", text: "Localizzazione - per tracciare gli spostamenti")
                    PermissionRow(icon: "figure.walk", text: "Movimento - per rilevare il tipo di trasporto")
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 30)
                
                // Pulsante completa
                Button {
                    completeOnboarding()
                } label: {
                    Text("Completa Registrazione")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(fullName.isEmpty || city.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(15)
                }
                .disabled(fullName.isEmpty || city.isEmpty)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private struct FeatureRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 30)
                
                Text(text)
                    .font(.body)
                
                Spacer()
            }
        }
    }
    
    private struct StepView: View {
        let number: String
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                // Numero step
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(number)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                // Contenuto
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(.green)
                        Text(title)
                            .font(.headline)
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private struct PermissionRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.green)
                    .frame(width: 25)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Actions
    
    /**
     Completa l'onboarding e crea il profilo
     */
    private func completeOnboarding() {
        // Validazione
        guard !fullName.isEmpty && !city.isEmpty else {
            alertMessage = "Per favore, compila tutti i campi obbligatori."
            showAlert = true
            return
        }
        
        // Crea il profilo
        var profile = UserProfile(
            fullName: fullName,
            city: city
        )
        
        if let ageInt = Int(age) {
            profile.age = ageInt
        }
        
        // Salva su CloudKit
        Task {
            do {
                try await cloudKitManager.saveUserProfile(profile)
                
                // Salva localmente
                if let encoded = try? JSONEncoder().encode(profile) {
                    UserDefaults.standard.set(encoded, forKey: "userProfile")
                }
                
                // Completa onboarding
                DispatchQueue.main.async {
                    isComplete = true
                }
                
                print("✅ Onboarding completato")
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Errore durante la registrazione. Riprova."
                    showAlert = true
                }
                print("❌ Errore salvataggio profilo: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isComplete: .constant(false))
        .environmentObject(CloudKitManager())
}
