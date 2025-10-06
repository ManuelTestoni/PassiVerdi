//
//  TrackingView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI
import MapKit

struct TrackingView: View {
    @EnvironmentObject var trackingManager: TrackingManager
    @EnvironmentObject var userManager: UserManager
    @State private var showManualEntry = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mappa (opzionale per MVP)
                Color(.systemGroupedBackground)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Stato tracking
                    if trackingManager.isTracking {
                        TrackingActiveView()
                    } else {
                        TrackingInactiveView()
                    }
                    
                    // Pulsante principale
                    Button(action: {
                        if trackingManager.isTracking {
                            stopTracking()
                        } else {
                            startTracking()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(trackingManager.isTracking ? Color.red : Color.green)
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            
                            VStack(spacing: 8) {
                                Image(systemName: trackingManager.isTracking ? "stop.fill" : "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                
                                Text(trackingManager.isTracking ? "Stop" : "Start")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Pulsante inserimento manuale
                    if !trackingManager.isTracking {
                        Button(action: {
                            showManualEntry = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Inserisci manualmente")
                            }
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Tracking")
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView()
            }
            .alert("Attività salvata!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("La tua attività è stata registrata con successo")
            }
        }
    }
    
    func startTracking() {
        trackingManager.requestPermissions()
        trackingManager.startTracking()
    }
    
    func stopTracking() {
        if let activity = trackingManager.stopTracking() {
            userManager.addActivity(activity)
            showSuccessAlert = true
        }
    }
}

struct TrackingActiveView: View {
    @EnvironmentObject var trackingManager: TrackingManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Timer
            if let startTime = trackingManager.trackingStartTime {
                Text(timeString(from: startTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            
            // Statistiche in tempo reale
            HStack(spacing: 40) {
                VStack {
                    Text(String(format: "%.2f", trackingManager.currentDistance))
                        .font(.title)
                        .fontWeight(.bold)
                    Text("km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    if let type = trackingManager.currentTransportType {
                        Image(systemName: type.iconName)
                            .font(.title)
                            .foregroundColor(.green)
                        Text(type.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ProgressView()
                        Text("Rilevamento...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
        }
    }
    
    func timeString(from startTime: Date) -> String {
        let elapsed = Date().timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct TrackingInactiveView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Pronto per iniziare?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Premi il pulsante per tracciare il tuo spostamento sostenibile")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    TrackingView()
        .environmentObject(TrackingManager())
        .environmentObject(UserManager())
}
