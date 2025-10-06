//
//  WatchConnectivityManager.swift
//  PassiVerdi Watch Watch App
//
//  Created on 06/10/2025.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var totalPoints: Int = 0
    @Published var todayKm: Double = 0.0
    @Published var todayCO2: Double = 0.0
    @Published var isReachable = false
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func requestUpdate() {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(["request": "update"], replyHandler: { reply in
            DispatchQueue.main.async {
                if let points = reply["points"] as? Int {
                    self.totalPoints = points
                }
                if let km = reply["km"] as? Double {
                    self.todayKm = km
                }
                if let co2 = reply["co2"] as? Double {
                    self.todayCO2 = co2
                }
            }
        }, errorHandler: { error in
            print("Watch connectivity error: \(error)")
        })
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation error: \(error)")
        } else {
            DispatchQueue.main.async {
                self.isReachable = session.isReachable
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let points = message["points"] as? Int {
                self.totalPoints = points
            }
            if let km = message["km"] as? Double {
                self.todayKm = km
            }
            if let co2 = message["co2"] as? Double {
                self.todayCO2 = co2
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
