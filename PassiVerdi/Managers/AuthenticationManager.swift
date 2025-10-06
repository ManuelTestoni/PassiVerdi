//
//  AuthenticationManager.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation
import AuthenticationServices

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserID: String?
    @Published var errorMessage: String?
    
    init() {
        // Controlla se esiste un utente già autenticato
        checkAuthenticationState()
    }
    
    func checkAuthenticationState() {
        // Controlla UserDefaults per sessione esistente
        if let userID = UserDefaults.standard.string(forKey: "currentUserID") {
            currentUserID = userID
            isAuthenticated = true
        }
    }
    
    func signInWithApple() {
        // TODO: Implementare Sign in with Apple
        // Per ora simuliamo il login
        let userID = UUID().uuidString
        currentUserID = userID
        UserDefaults.standard.set(userID, forKey: "currentUserID")
        isAuthenticated = true
    }
    
    func signInWithEmail(email: String, password: String) async {
        // TODO: Implementare autenticazione email/password con CloudKit
        // Per ora simuliamo il login
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let userID = UUID().uuidString
            currentUserID = userID
            UserDefaults.standard.set(userID, forKey: "currentUserID")
            isAuthenticated = true
        } catch {
            errorMessage = "Errore durante il login"
        }
    }
    
    func signUp(email: String, password: String, name: String, city: String) async {
        // TODO: Implementare registrazione con CloudKit
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let userID = UUID().uuidString
            currentUserID = userID
            UserDefaults.standard.set(userID, forKey: "currentUserID")
            isAuthenticated = true
        } catch {
            errorMessage = "Errore durante la registrazione"
        }
    }
    
    func signOut() {
        currentUserID = nil
        UserDefaults.standard.removeObject(forKey: "currentUserID")
        isAuthenticated = false
    }
}
