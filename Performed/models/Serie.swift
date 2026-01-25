//
//  Serie.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import Foundation

struct Serie: Codable, Identifiable {
    let id: UUID
    var repetitions: [Int]
    var poids: [Double]
    
    init(id: UUID = UUID(), repetitions: [Int] = [], poids: [Double] = []) {
        self.id = id
        self.repetitions = repetitions
        self.poids = poids
    }
    
    var totalReps: Int {
        repetitions.reduce(0, +)
    }
    
    var moyennePoids: Double {
        guard !poids.isEmpty else { return 0 }
        return poids.reduce(0, +) / Double(poids.count)
    }
}
