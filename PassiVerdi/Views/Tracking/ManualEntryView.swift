//
//  ManualEntryView.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var selectedTransport: TransportType = .walking
    @State private var distance: String = ""
    @State private var duration: String = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo di trasporto") {
                    Picker("Mezzo", selection: $selectedTransport) {
                        ForEach(TransportType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Dettagli spostamento") {
                    HStack {
                        Text("Distanza")
                        Spacer()
                        TextField("0.0", text: $distance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("km")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Durata")
                        Spacer()
                        TextField("0", text: $duration)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                    
                    DatePicker("Data", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Riepilogo") {
                    if let dist = Double(distance), dist > 0 {
                        HStack {
                            Text("Punti guadagnati")
                            Spacer()
                            Text("+\(Int(dist * Double(selectedTransport.pointsPerKm)))")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                        
                        let carCO2 = (TransportType.car.co2PerKm * dist) / 1000.0
                        let currentCO2 = (selectedTransport.co2PerKm * dist) / 1000.0
                        let co2Saved = carCO2 - currentCO2
                        
                        HStack {
                            Text("CO₂ risparmiata")
                            Spacer()
                            Text(String(format: "%.2f kg", co2Saved))
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Inserimento manuale")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveActivity()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    var isValid: Bool {
        guard let dist = Double(distance), dist > 0 else { return false }
        guard let dur = Double(duration), dur > 0 else { return false }
        return true
    }
    
    func saveActivity() {
        guard let dist = Double(distance),
              let dur = Double(duration) else { return }
        
        let durationInSeconds = dur * 60
        let endTime = selectedDate
        let startTime = selectedDate.addingTimeInterval(-durationInSeconds)
        
        let carCO2 = (TransportType.car.co2PerKm * dist) / 1000.0
        let currentCO2 = (selectedTransport.co2PerKm * dist) / 1000.0
        let co2Saved = carCO2 - currentCO2
        
        let points = Int(dist * Double(selectedTransport.pointsPerKm))
        
        let activity = Activity(
            transportType: selectedTransport,
            distance: dist,
            duration: durationInSeconds,
            startTime: startTime,
            endTime: endTime,
            co2Saved: co2Saved,
            pointsEarned: points
        )
        
        userManager.addActivity(activity)
        dismiss()
    }
}

#Preview {
    ManualEntryView()
        .environmentObject(UserManager())
}
