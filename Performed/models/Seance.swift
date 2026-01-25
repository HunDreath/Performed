//
//  Seance.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import Foundation


struct Seance: Codable, Identifiable {
    let id: UUID
    var date: Date
    var workouts: [Workout]
    var seanceName: String
    
    init(id: UUID = UUID(), date: Date = Date(), workouts: [Workout] = []) {
        self.id = id
        self.date = date
        self.workouts = workouts
        self.seanceName = date.formatted()
    }
    
    init(id: UUID = UUID(), date: Date = Date(), workouts: [Workout] = [], seanceName: String) {
        self.id = id
        self.date = date
        self.workouts = workouts
        self.seanceName = seanceName
    }
    
    var duree: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
