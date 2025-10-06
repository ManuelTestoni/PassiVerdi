//
//  PassiVerdiApp.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

@main
struct PassiVerdiApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var trackingManager = TrackingManager()
    @StateObject private var pointsManager = PointsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(userManager)
                .environmentObject(trackingManager)
                .environmentObject(pointsManager)
        }
    }
}
