//
//  CloudKitManager.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import CloudKit
import Combine

/**
 # CloudKitManager
 
 Manager per la sincronizzazione dati con iCloud CloudKit.
 
 ## Responsabilità:
 - Salvataggio profilo utente su iCloud
 - Backup attività e statistiche
 - Sincronizzazione tra dispositivi
 - Gestione classiche e ranking
 
 ## Database:
 - Utilizza il container privato per dati utente
 - Container pubblico per classifiche e challenge future
 */
class CloudKitManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Indica se CloudKit è disponibile
    @Published var isAvailable: Bool = false
    
    /// Indica se è in corso una sincronizzazione
    @Published var isSyncing: Bool = false
    
    /// Ultimo errore occorso
    @Published var lastError: String?
    
    /// Profilo utente caricato da CloudKit
    @Published var userProfile: UserProfile?
    
    // MARK: - Private Properties
    
    /// Container CloudKit
    private let container: CKContainer
    
    /// Database privato
    private let privateDatabase: CKDatabase
    
    /// Database pubblico (per future features sociali)
    private let publicDatabase: CKDatabase
    
    // MARK: - Initialization
    
    init() {
        // Usa il container di default o uno custom
        self.container = CKContainer(identifier: "iCloud.com.passiverdi.app")
        self.privateDatabase = container.privateCloudDatabase
        self.publicDatabase = container.publicCloudDatabase
        
        checkAccountStatus()
        print("☁️ CloudKitManager inizializzato")
    }
    
    // MARK: - Account Status
    
    /**
     Verifica lo stato dell'account iCloud
     */
    func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Errore verifica account iCloud: \(error.localizedDescription)")
                    self?.lastError = error.localizedDescription
                    self?.isAvailable = false
                    return
                }
                
                switch status {
                case .available:
                    print("✅ iCloud disponibile")
                    self?.isAvailable = true
                case .noAccount:
                    print("⚠️ Nessun account iCloud configurato")
                    self?.lastError = "Nessun account iCloud configurato"
                    self?.isAvailable = false
                case .restricted:
                    print("⚠️ iCloud limitato")
                    self?.lastError = "iCloud limitato"
                    self?.isAvailable = false
                case .couldNotDetermine:
                    print("⚠️ Stato iCloud non determinabile")
                    self?.lastError = "Impossibile verificare iCloud"
                    self?.isAvailable = false
                case .temporarilyUnavailable:
                    print("⚠️ iCloud temporaneamente non disponibile")
                    self?.lastError = "iCloud temporaneamente non disponibile"
                    self?.isAvailable = false
                @unknown default:
                    print("⚠️ Stato iCloud sconosciuto")
                    self?.isAvailable = false
                }
            }
        }
    }
    
    // MARK: - User Profile Methods
    
    /**
     Salva il profilo utente su CloudKit
     
     - Parameter profile: Profilo da salvare
     */
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard isAvailable else {
            throw CloudKitError.notAvailable
        }
        
        DispatchQueue.main.async {
            self.isSyncing = true
        }
        
        let record = profile.toCKRecord()
        
        do {
            let savedRecord = try await privateDatabase.save(record)
            
            DispatchQueue.main.async {
                print("✅ Profilo salvato su CloudKit")
                self.isSyncing = false
                self.lastError = nil
            }
        } catch {
            DispatchQueue.main.async {
                print("❌ Errore salvataggio profilo: \(error.localizedDescription)")
                self.lastError = error.localizedDescription
                self.isSyncing = false
            }
            throw error
        }
    }
    
    /**
     Carica il profilo utente da CloudKit
     */
    func fetchUserProfile() async {
        guard isAvailable else {
            print("⚠️ CloudKit non disponibile")
            return
        }
        
        DispatchQueue.main.async {
            self.isSyncing = true
        }
        
        // Query per cercare il profilo dell'utente
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        
        do {
            let results = try await privateDatabase.records(matching: query, resultsLimit: 1)
            
            if let (_, result) = results.matchResults.first {
                switch result {
                case .success(let record):
                    if let profile = UserProfile.fromCKRecord(record) {
                        DispatchQueue.main.async {
                            self.userProfile = profile
                            print("✅ Profilo caricato da CloudKit")
                            self.isSyncing = false
                            self.lastError = nil
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("❌ Errore caricamento profilo: \(error.localizedDescription)")
                        self.lastError = error.localizedDescription
                        self.isSyncing = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("ℹ️ Nessun profilo trovato su CloudKit")
                    self.isSyncing = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("❌ Errore query profilo: \(error.localizedDescription)")
                self.lastError = error.localizedDescription
                self.isSyncing = false
            }
        }
    }
    
    /**
     Elimina il profilo utente da CloudKit
     */
    func deleteUserProfile() async throws {
        guard isAvailable else {
            throw CloudKitError.notAvailable
        }
        
        // Query per trovare il profilo
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        do {
            let results = try await privateDatabase.records(matching: query, resultsLimit: 1)
            
            if let (recordID, _) = results.matchResults.first {
                try await privateDatabase.deleteRecord(withID: recordID)
                
                DispatchQueue.main.async {
                    self.userProfile = nil
                    print("✅ Profilo eliminato da CloudKit")
                }
            }
        } catch {
            print("❌ Errore eliminazione profilo: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Activity Methods
    
    /**
     Salva un'attività su CloudKit
     
     - Parameter activity: Attività da salvare
     */
    func saveActivity(_ activity: Activity) async throws {
        guard isAvailable else {
            throw CloudKitError.notAvailable
        }
        
        let record = CKRecord(recordType: "Activity")
        record["id"] = activity.id.uuidString as CKRecordValue
        record["transportType"] = activity.transportType.rawValue as CKRecordValue
        record["distance"] = activity.distance as CKRecordValue
        record["startDate"] = activity.startDate as CKRecordValue
        record["endDate"] = activity.endDate as CKRecordValue
        record["pointsEarned"] = activity.pointsEarned as CKRecordValue
        record["co2Saved"] = activity.co2Saved as CKRecordValue
        
        do {
            let _ = try await privateDatabase.save(record)
            print("✅ Attività salvata su CloudKit")
        } catch {
            print("❌ Errore salvataggio attività: \(error.localizedDescription)")
            throw error
        }
    }
    
    /**
     Carica le attività dell'utente da CloudKit
     
     - Parameter limit: Numero massimo di attività da caricare
     - Returns: Array di attività
     */
    func fetchActivities(limit: Int = 100) async throws -> [Activity] {
        guard isAvailable else {
            throw CloudKitError.notAvailable
        }
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Activity", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        var activities: [Activity] = []
        
        do {
            let results = try await privateDatabase.records(matching: query, resultsLimit: limit)
            
            for (_, result) in results.matchResults {
                switch result {
                case .success(let record):
                    if let activity = activityFromRecord(record) {
                        activities.append(activity)
                    }
                case .failure(let error):
                    print("⚠️ Errore caricamento attività: \(error.localizedDescription)")
                }
            }
            
            print("✅ Caricate \(activities.count) attività da CloudKit")
            return activities
            
        } catch {
            print("❌ Errore query attività: \(error.localizedDescription)")
            throw error
        }
    }
    
    /**
     Converte un CKRecord in Activity
     */
    private func activityFromRecord(_ record: CKRecord) -> Activity? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let transportTypeString = record["transportType"] as? String,
              let transportType = TransportType(rawValue: transportTypeString),
              let distance = record["distance"] as? Double,
              let startDate = record["startDate"] as? Date,
              let endDate = record["endDate"] as? Date else {
            return nil
        }
        
        return Activity(
            id: id,
            transportType: transportType,
            distance: distance,
            startDate: startDate,
            endDate: endDate
        )
    }
}

// MARK: - Errors

enum CloudKitError: LocalizedError {
    case notAvailable
    case noAccount
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "iCloud non disponibile"
        case .noAccount:
            return "Nessun account iCloud configurato"
        case .saveFailed:
            return "Errore durante il salvataggio"
        case .fetchFailed:
            return "Errore durante il caricamento"
        }
    }
}
