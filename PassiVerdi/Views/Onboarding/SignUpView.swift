//
//  SignUpView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var city = ""
    @State private var age = ""
    @State private var selectedGender: User.Gender = .preferNotToSay
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Crea il tuo account")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Unisciti alla community verde")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 15) {
                    TextField("Nome completo", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                    
                    SecureField("Conferma password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                    
                    TextField("Città", text: $city)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.addressCity)
                    
                    TextField("Età (opzionale)", text: $age)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Picker("Genere", selection: $selectedGender) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.green)
                }
                .padding(.horizontal, 32)
                
                // Pulsante registrazione
                Button(action: {
                    validateAndSignUp()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Registrati")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isFormValid ? Color.green : Color.gray)
                .cornerRadius(10)
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 32)
                
                // Terms
                Text("Registrandoti accetti i Termini di Servizio e la Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 30)
        }
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !city.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    func validateAndSignUp() {
        guard password == confirmPassword else {
            errorMessage = "Le password non coincidono"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "La password deve contenere almeno 6 caratteri"
            showError = true
            return
        }
        
        Task {
            isLoading = true
            await authManager.signUp(email: email, password: password, name: name, city: city)
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthenticationManager())
    }
}
