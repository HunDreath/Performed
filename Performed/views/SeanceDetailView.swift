//
//  SeanceDetailView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct SeanceDetailView: View {
    let seance: Seance
    
    var body: some View {
        List {
            Section(header: Text("Informations")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(seance.duree)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Exercices")
                    Spacer()
                    Text("\(seance.workouts.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(seance.workouts) { workout in
                Section(header: Text(workout.exercice.rawValue)) {
                    ForEach(Array(workout.series.enumerated()), id: \.offset) { index, serie in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Série \(index + 1)")
                                .font(.headline)
                            HStack {
                                Text("Reps: \(serie.totalReps)")
                                Spacer()
                                Text("Poids: \(String(format: "%.1f", serie.moyennePoids)) kg")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Détail Séance")
    }
}

// MARK: - Preview

struct SeanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with complete workout session
        NavigationView {
            SeanceDetailView(seance: Seance(
                id: UUID(),
                date: Date(),
                workouts: [
                    Workout(
                        id: UUID(),
                        exercice: .developeCouche,
                        series: [
                            Serie(repetitions: [10], poids: [60]),
                            Serie(repetitions: [8], poids: [65]),
                            Serie(repetitions: [6], poids: [70]),
                            Serie(repetitions: [8], poids: [65])
                        ]
                    ),
                    Workout(
                        id: UUID(),
                        exercice: .squat,
                        series: [
                            Serie(repetitions: [12], poids: [80]),
                            Serie(repetitions: [10], poids: [90]),
                            Serie(repetitions: [8], poids: [100])
                        ]
                    ),
                    Workout(
                        id: UUID(),
                        exercice: .tractionsDos,
                        series: [
                            Serie(repetitions: [8], poids: [0]),
                            Serie(repetitions: [6], poids: [0]),
                            Serie(repetitions: [5], poids: [0])
                        ]
                    )
                ]
            ))
        }
        .previewDisplayName("Complete Session")
        
        // Preview with single exercise
        NavigationView {
            SeanceDetailView(seance: Seance(
                id: UUID(),
                date: Date(),
                workouts: [
                    Workout(
                        id: UUID(),
                        exercice: .souleverDeTerre,
                        series: [
                            Serie(repetitions: [5], poids: [120]),
                            Serie(repetitions: [5], poids: [140]),
                            Serie(repetitions: [5], poids: [160]),
                            Serie(repetitions: [3], poids: [180]),
                            Serie(repetitions: [1], poids: [200])
                        ]
                    )
                ]
            ))
        }
        .previewDisplayName("Single Exercise - Heavy")
        
        // Preview in dark mode
        NavigationView {
            SeanceDetailView(seance: Seance(
                id: UUID(),
                date: Date().addingTimeInterval(-86400), // Yesterday
                workouts: [
                    Workout(
                        id: UUID(),
                        exercice: .curlsBiceps,
                        series: [
                            Serie(repetitions: [12], poids: [15]),
                            Serie(repetitions: [10], poids: [17.5]),
                            Serie(repetitions: [8], poids: [20])
                        ]
                    ),
                    Workout(
                        id: UUID(),
                        exercice: .extensionNuque,
                        series: [
                            Serie(repetitions: [15], poids: [12.5]),
                            Serie(repetitions: [12], poids: [15]),
                            Serie(repetitions: [10], poids: [17.5])
                        ]
                    )
                ]
            ))
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode - Arms Day")
        
        // Preview with minimal data
        NavigationView {
            SeanceDetailView(seance: Seance(
                id: UUID(),
                date: Date(),
                workouts: [
                    Workout(
                        id: UUID(),
                        exercice: .developeMilitaire,
                        series: [
                            Serie(repetitions: [10], poids: [40])
                        ]
                    )
                ]
            ))
        }
        .previewDisplayName("Minimal Session")
    }
}
