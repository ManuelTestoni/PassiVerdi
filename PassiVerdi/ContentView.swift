//
//  ContentView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(UserManager())
        .environmentObject(TrackingManager())
        .environmentObject(PointsManager())
}
