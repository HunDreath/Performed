//
//  Workout.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import Foundation

struct Workout: Codable, Identifiable {
    
    let id: UUID
    var exercice: Exercice
    var series: [Serie]
    
    func totalWorkoutRep() -> Int {
        var totalRep = 0

        for serie in self.series {
            totalRep += serie.totalReps
        }

        return totalRep
    }
    
    func totalWorkoutSerie() -> Int {
        series.count
    }


    
}
