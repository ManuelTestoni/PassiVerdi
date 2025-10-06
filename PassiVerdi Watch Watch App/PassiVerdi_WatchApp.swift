//
//  PassiVerdi_WatchApp.swift
//  PassiVerdi Watch Watch App
//
//  Created on 06/10/2025.
//

import SwiftUI

@main
struct PassiVerdi_Watch_Watch_AppApp: App {
    @StateObject private var watchConnectivity = WatchConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(watchConnectivity)
        }
    }
}
