//
//  PointsManager.swift
//  PassiVerdi
//
//  Created on 06/10/2025.
//

import Foundation

@MainActor
class PointsManager: ObservableObject {
    @Published var badges: [Badge] = []
    
    func calculatePoints(for activity: Activity) -> Int {
        let basePoints = Int(activity.distance * Double(activity.transportType.pointsPerKm))
        return basePoints
    }
    
    func checkAndAwardBadges(user: User, activities: [Activity]) -> [Badge] {
        var newBadges: [Badge] = []
        
        // Controlla ogni tipo di badge
        for badgeType in BadgeType.allCases {
            // Verifica se l'utente ha già questo badge
            if !user.badges.contains(where: { $0.type == badgeType }) {
                if shouldAwardBadge(badgeType, user: user, activities: activities) {
                    let badge = Badge(type: badgeType, earnedDate: Date(), isUnlocked: true)
                    newBadges.append(badge)
                }
            }
        }
        
        return newBadges
    }
    
    private func shouldAwardBadge(_ badgeType: BadgeType, user: User, activities: [Activity]) -> Bool {
        switch badgeType {
        case .firstStep:
            return activities.count >= 1
            
        case .ecoExplorer:
            return user.totalKilometers >= 50
            
        case .bikeHero:
            let bikeKm = activities
                .filter { $0.transportType == .cycling }
                .reduce(0.0) { $0 + $1.distance }
            return bikeKm >= 100
            
        case .walkingMaster:
            let walkKm = activities
                .filter { $0.transportType == .walking }
                .reduce(0.0) { $0 + $1.distance }
            return walkKm >= 100
            
        case .weekWarrior:
            return checkConsecutiveDays(activities: activities, days: 7)
            
        case .monthChampion:
            return checkConsecutiveDays(activities: activities, days: 30)
            
        case .co2Saver:
            return user.totalCO2Saved >= 100
            
        case .publicTransportFan:
            let ptCount = activities
                .filter { $0.transportType == .publicTransport }
                .count
            return ptCount >= 50
        }
    }
    
    private func checkConsecutiveDays(activities: [Activity], days: Int) -> Bool {
        guard !activities.isEmpty else { return false }
        
        let calendar = Calendar.current
        let sortedActivities = activities.sorted { $0.startTime > $1.startTime }
        
        var consecutiveDays = 1
        var currentDate = calendar.startOfDay(for: sortedActivities[0].startTime)
        
        for activity in sortedActivities.dropFirst() {
            let activityDate = calendar.startOfDay(for: activity.startTime)
            
            if let daysDifference = calendar.dateComponents([.day], from: activityDate, to: currentDate).day {
                if daysDifference == 1 {
                    consecutiveDays += 1
                    currentDate = activityDate
                } else if daysDifference > 1 {
                    break
                }
            }
        }
        
        return consecutiveDays >= days
    }
    
    func getLeaderboard() -> [LeaderboardEntry] {
        // TODO: Implementare con CloudKit per classifica reale
        // Per ora restituiamo dati di esempio
        return [
            LeaderboardEntry(rank: 1, name: "Mario Rossi", points: 1250, city: "Milano"),
            LeaderboardEntry(rank: 2, name: "Anna Verdi", points: 980, city: "Milano"),
            LeaderboardEntry(rank: 3, name: "Luca Bianchi", points: 875, city: "Milano"),
            LeaderboardEntry(rank: 4, name: "Tu", points: 450, city: "Milano", isCurrentUser: true),
            LeaderboardEntry(rank: 5, name: "Sara Neri", points: 420, city: "Milano")
        ]
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    var rank: Int
    var name: String
    var points: Int
    var city: String
    var isCurrentUser: Bool = false
}
