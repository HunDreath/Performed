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
