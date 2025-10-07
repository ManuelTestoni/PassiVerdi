//
//  UserProfile.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import CloudKit

/**
 # UserProfile
 
 Modello che rappresenta il profilo utente dell'applicazione.
 
 ## Proprietà:
 - Informazioni personali (nome, età, comune)
 - Statistiche accumulate (punti, km, CO₂ risparmiata)
 - Badge ottenuti
 - Preferenze utente
 
 ## Sincronizzazione:
 - Salvato su CloudKit per backup cloud
 - Condiviso con Apple Watch via WatchConnectivity
 */
struct UserProfile: Codable, Identifiable {
    
    // MARK: - Properties
    
    /// ID univoco del profilo
    var id: UUID = UUID()
    
    /// Nome completo dell'utente
    var fullName: String
    
    /// Età dell'utente (opzionale)
    var age: Int?
    
    /// Comune di residenza
    var city: String
    
    /// Email dell'utente (per login)
    var email: String?
    
    /// Punti verdi totali accumulati
    var totalPoints: Int = 0
    
    /// Chilometri totali percorsi in modo sostenibile
    var totalKilometers: Double = 0.0
    
    /// CO₂ totale risparmiata (in kg)
    var totalCO2Saved: Double = 0.0
    
    /// Lista degli ID dei badge ottenuti
    var earnedBadgeIDs: [String] = []
    
    /// Data di registrazione
    var registrationDate: Date = Date()
    
    /// Ultimo aggiornamento del profilo
    var lastUpdated: Date = Date()
    
    // MARK: - Computed Properties
    
    /// Livello utente basato sui punti
    var level: Int {
        return totalPoints / 100 // Ogni 100 punti = 1 livello
    }
    
    /// Punti necessari per il prossimo livello
    var pointsToNextLevel: Int {
        let nextLevel = level + 1
        return (nextLevel * 100) - totalPoints
    }
    
    // MARK: - CloudKit Conversion
    
    /**
     Converte il profilo in un CKRecord per CloudKit
     
     - Returns: CKRecord contenente tutti i dati del profilo
     */
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "UserProfile")
        record["id"] = id.uuidString as CKRecordValue
        record["fullName"] = fullName as CKRecordValue
        if let age = age {
            record["age"] = age as CKRecordValue
        }
        record["city"] = city as CKRecordValue
        if let email = email {
            record["email"] = email as CKRecordValue
        }
        record["totalPoints"] = totalPoints as CKRecordValue
        record["totalKilometers"] = totalKilometers as CKRecordValue
        record["totalCO2Saved"] = totalCO2Saved as CKRecordValue
        record["earnedBadgeIDs"] = earnedBadgeIDs as CKRecordValue
        record["registrationDate"] = registrationDate as CKRecordValue
        record["lastUpdated"] = Date() as CKRecordValue
        return record
    }
    
    /**
     Crea un UserProfile da un CKRecord di CloudKit
     
     - Parameter record: CKRecord da convertire
     - Returns: UserProfile opzionale (nil se i dati non sono validi)
     */
    static func fromCKRecord(_ record: CKRecord) -> UserProfile? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let fullName = record["fullName"] as? String,
              let city = record["city"] as? String else {
            return nil
        }
        
        var profile = UserProfile(
            id: id,
            fullName: fullName,
            city: city
        )
        
        profile.age = record["age"] as? Int
        profile.email = record["email"] as? String
        profile.totalPoints = record["totalPoints"] as? Int ?? 0
        profile.totalKilometers = record["totalKilometers"] as? Double ?? 0.0
        profile.totalCO2Saved = record["totalCO2Saved"] as? Double ?? 0.0
        profile.earnedBadgeIDs = record["earnedBadgeIDs"] as? [String] ?? []
        profile.registrationDate = record["registrationDate"] as? Date ?? Date()
        profile.lastUpdated = record["lastUpdated"] as? Date ?? Date()
        
        return profile
    }
}

// MARK: - Sample Data

extension UserProfile {
    
    /// Profilo di esempio per preview e testing
    static var sample: UserProfile {
        UserProfile(
            fullName: "Mario Rossi",
            age: 28,
            city: "Milano",
            email: "mario.rossi@example.com",
            totalPoints: 450,
            totalKilometers: 125.5,
            totalCO2Saved: 32.4,
            earnedBadgeIDs: ["eco-explorer", "bike-hero"]
        )
    }
}
