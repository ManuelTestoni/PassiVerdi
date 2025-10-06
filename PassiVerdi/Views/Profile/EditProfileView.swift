//
//  EditProfileView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var name: String = ""
    @State private var city: String = ""
    @State private var age: String = ""
    @State private var selectedGender: User.Gender = .preferNotToSay
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informazioni personali") {
                    TextField("Nome", text: $name)
                    TextField("Città", text: $city)
                    TextField("Età", text: $age)
                        .keyboardType(.numberPad)
                    
                    Picker("Genere", selection: $selectedGender) {
                        ForEach(User.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
                
                Section("Email") {
                    Text(userManager.currentUser?.email ?? "")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                loadCurrentData()
            }
        }
    }
    
    func loadCurrentData() {
        if let user = userManager.currentUser {
            name = user.name
            city = user.city
            age = user.age != nil ? "\(user.age!)" : ""
            selectedGender = user.gender ?? .preferNotToSay
        }
    }
    
    func saveProfile() {
        guard var user = userManager.currentUser else { return }
        
        user.name = name
        user.city = city
        user.age = Int(age)
        user.gender = selectedGender
        
        userManager.updateUserProfile(user)
        dismiss()
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserManager())
}
