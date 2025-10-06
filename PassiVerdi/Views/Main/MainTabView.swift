//
//  MainTabView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            TrackingView()
                .tabItem {
                    Label("Tracking", systemImage: "location.fill")
                }
                .tag(1)
            
            ChallengesView()
                .tabItem {
                    Label("Sfide", systemImage: "target")
                }
                .tag(2)
            
            LeaderboardView()
                .tabItem {
                    Label("Classifica", systemImage: "trophy.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profilo", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.green)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .environmentObject(UserManager())
        .environmentObject(TrackingManager())
        .environmentObject(PointsManager())
}
