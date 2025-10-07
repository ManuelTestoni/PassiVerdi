//
//  WatchConnectivityManager.swift
//  PassiVerdi
//
//  Created on 07/10/2025.
//  Copyright © 2025 PassiVerdi. All rights reserved.
//

import Foundation
import WatchConnectivity

/**
 # WatchConnectivityManager
 
 Manager per la sincronizzazione dati tra iPhone e Apple Watch.
 
 ## Responsabilità:
 - Invio dati da iPhone a Watch
 - Ricezione dati da Watch a iPhone
 - Sincronizzazione real-time di punti e attività
 - Transfer file per dati di grandi dimensioni
 
 ## Pattern:
 - Singleton condiviso tra app iOS e watchOS
 - Utilizza WCSession per la comunicazione
 */
class WatchConnectivityManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = WatchConnectivityManager()
    
    // MARK: - Published Properties
    
    /// Indica se la sessione è attiva e raggiungibile
    @Published var isReachable: Bool = false
    
    /// Indica se il Watch è paired
    @Published var isPaired: Bool = false
    
    /// Ultimo messaggio ricevuto
    @Published var lastMessage: [String: Any] = [:]
    
    // MARK: - Private Properties
    
    /// WatchConnectivity Session
    private var session: WCSession?
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            print("⌚ WatchConnectivityManager inizializzato")
        } else {
            print("⚠️ WatchConnectivity non supportato su questo dispositivo")
        }
    }
    
    // MARK: - Public Methods
    
    /**
     Attiva la sessione di connettività
     */
    func activate() {
        session?.activate()
    }
    
    /**
     Invia un messaggio al Watch
     
     - Parameters:
        - message: Dizionario con i dati da inviare
        - replyHandler: Handler opzionale per la risposta
        - errorHandler: Handler opzionale per gli errori
     */
    func sendMessage(
        _ message: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        guard let session = session, session.isReachable else {
            print("⚠️ Watch non raggiungibile")
            errorHandler?(WatchConnectivityError.notReachable)
            return
        }
        
        session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
        print("📤 Messaggio inviato al Watch: \(message)")
    }
    
    /**
     Aggiorna il context dell'applicazione (dati persistenti)
     
     - Parameter context: Dizionario con i dati da sincronizzare
     */
    func updateApplicationContext(_ context: [String: Any]) {
        guard let session = session else { return }
        
        do {
            try session.updateApplicationContext(context)
            print("📤 Application Context aggiornato: \(context)")
        } catch {
            print("❌ Errore aggiornamento context: \(error.localizedDescription)")
        }
    }
    
    /**
     Invia i dati del profilo utente al Watch
     
     - Parameter profile: Profilo utente da sincronizzare
     */
    func syncUserProfile(_ profile: UserProfile) {
        let context: [String: Any] = [
            "type": "userProfile",
            "fullName": profile.fullName,
            "totalPoints": profile.totalPoints,
            "totalKilometers": profile.totalKilometers,
            "totalCO2Saved": profile.totalCO2Saved,
            "level": profile.level
        ]
        
        updateApplicationContext(context)
    }
    
    /**
     Invia un'attività al Watch
     
     - Parameter activity: Attività da sincronizzare
     */
    func syncActivity(_ activity: Activity) {
        guard let activityData = try? JSONEncoder().encode(activity),
              let activityDict = try? JSONSerialization.jsonObject(with: activityData) as? [String: Any] else {
            print("❌ Errore encoding attività")
            return
        }
        
        var message = activityDict
        message["type"] = "newActivity"
        
        sendMessage(message)
    }
    
    /**
     Invia le statistiche giornaliere al Watch
     
     - Parameters:
        - points: Punti di oggi
        - kilometers: Km di oggi
        - co2Saved: CO₂ risparmiata oggi
     */
    func syncDailyStats(points: Int, kilometers: Double, co2Saved: Double) {
        let context: [String: Any] = [
            "type": "dailyStats",
            "todayPoints": points,
            "todayKilometers": kilometers,
            "todayCO2Saved": co2Saved,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        updateApplicationContext(context)
    }
    
    /**
     Trasferisce un file al Watch (per dati di grandi dimensioni)
     
     - Parameter fileURL: URL del file da trasferire
     */
    func transferFile(_ fileURL: URL) {
        guard let session = session else { return }
        
        session.transferFile(fileURL, metadata: ["type": "largeData"])
        print("📤 File transfer avviato: \(fileURL.lastPathComponent)")
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    
    /**
     Chiamato quando lo stato della sessione cambia
     */
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            if let error = error {
                print("❌ Errore attivazione sessione: \(error.localizedDescription)")
                return
            }
            
            switch activationState {
            case .activated:
                print("✅ WCSession attivata")
                self.isPaired = session.isPaired
                self.isReachable = session.isReachable
            case .inactive:
                print("⚠️ WCSession inattiva")
            case .notActivated:
                print("⚠️ WCSession non attivata")
            @unknown default:
                print("⚠️ Stato WCSession sconosciuto")
            }
        }
    }
    
    /**
     Chiamato quando cambia lo stato di reachability
     */
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("⌚ Watch reachable: \(session.isReachable)")
        }
    }
    
    /**
     Chiamato quando viene ricevuto un messaggio dal Watch
     */
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.lastMessage = message
            print("📥 Messaggio ricevuto dal Watch: \(message)")
            
            // Gestisci il messaggio in base al tipo
            if let type = message["type"] as? String {
                self.handleReceivedMessage(type: type, data: message)
            }
        }
    }
    
    /**
     Chiamato quando viene ricevuto un messaggio con richiesta di risposta
     */
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        DispatchQueue.main.async {
            self.lastMessage = message
            print("📥 Messaggio con reply ricevuto dal Watch: \(message)")
            
            // Invia una risposta
            let reply: [String: Any] = [
                "status": "received",
                "timestamp": Date().timeIntervalSince1970
            ]
            replyHandler(reply)
        }
    }
    
    /**
     Chiamato quando viene aggiornato l'application context
     */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            print("📥 Application Context ricevuto dal Watch: \(applicationContext)")
            self.handleReceivedMessage(type: "applicationContext", data: applicationContext)
        }
    }
    
    /**
     Chiamato quando viene completato un file transfer
     */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("📥 File ricevuto dal Watch: \(file.fileURL.lastPathComponent)")
    }
    
    // iOS only
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ WCSession diventata inattiva")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ WCSession deattivata")
        // Riattiva la sessione
        session.activate()
    }
    #endif
    
    // MARK: - Message Handling
    
    /**
     Gestisce i messaggi ricevuti in base al tipo
     */
    private func handleReceivedMessage(type: String, data: [String: Any]) {
        switch type {
        case "requestSync":
            // Watch richiede sincronizzazione
            print("🔄 Richiesta sync dal Watch")
            // TODO: Implementare logica di sync
            
        case "activityStarted":
            print("🏃 Attività avviata dal Watch")
            
        case "activityCompleted":
            print("✅ Attività completata dal Watch")
            
        default:
            print("ℹ️ Tipo messaggio non gestito: \(type)")
        }
    }
}

// MARK: - Errors

enum WatchConnectivityError: Error {
    case notReachable
    case notSupported
    case encodingFailed
    
    var localizedDescription: String {
        switch self {
        case .notReachable:
            return "Apple Watch non raggiungibile"
        case .notSupported:
            return "WatchConnectivity non supportato"
        case .encodingFailed:
            return "Errore encoding dati"
        }
    }
}
