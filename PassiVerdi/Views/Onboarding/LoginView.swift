//
//  LoginView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Logo e titolo
                VStack(spacing: 15) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("PassiVerdi")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Accedi per iniziare il tuo viaggio sostenibile")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Form di login
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    Button(action: {
                        Task {
                            isLoading = true
                            await authManager.signInWithEmail(email: email, password: password)
                            isLoading = false
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Accedi")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.green)
                    .cornerRadius(10)
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                }
                .padding(.horizontal, 32)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("oppure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 32)
                
                // Sign in with Apple
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success:
                            authManager.signInWithApple()
                        case .failure(let error):
                            print("Sign in with Apple failed: \(error)")
                        }
                    }
                )
                .frame(height: 50)
                .padding(.horizontal, 32)
                .signInWithAppleButtonStyle(.black)
                
                Spacer()
                
                // Link registrazione
                Button(action: {
                    showSignUp = true
                }) {
                    HStack {
                        Text("Non hai un account?")
                            .foregroundColor(.secondary)
                        Text("Registrati")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
