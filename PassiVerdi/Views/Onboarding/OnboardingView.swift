//
//  OnboardingView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentPage = 0
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            if showLogin {
                LoginView()
            } else {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "leaf.fill",
                        title: "Benvenuto in PassiVerdi",
                        description: "Trasforma i tuoi spostamenti in azioni concrete per l'ambiente",
                        accentColor: .green
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        imageName: "chart.line.uptrend.xyaxis",
                        title: "Traccia il tuo impatto",
                        description: "Monitora i tuoi spostamenti sostenibili e scopri quanta CO₂ risparmi ogni giorno",
                        accentColor: .blue
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        imageName: "trophy.fill",
                        title: "Guadagna ricompense",
                        description: "Accumula punti verdi e sblocca badge per le tue azioni eco-friendly",
                        accentColor: .orange
                    )
                    .tag(2)
                    
                    OnboardingPageView(
                        imageName: "person.3.fill",
                        title: "Unisciti alla comunità",
                        description: "Sfida amici e cittadini della tua città in classifiche sostenibili",
                        accentColor: .purple
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack {
                    Spacer()
                    
                    if currentPage == 3 {
                        Button(action: {
                            withAnimation {
                                showLogin = true
                            }
                        }) {
                            Text("Inizia ora")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(accentColor)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthenticationManager())
}
