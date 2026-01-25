//
//  AddWorkoutView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var seance: Seance
    @State private var selectedExercice: Exercice = .developeCouche
    @State private var series: [Serie] = [Serie(repetitions: [10], poids: [20])]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercice")) {
                    Picker("Type d'exercice", selection: $selectedExercice) {
                        ForEach(Exercice.allCases) { exercice in
                            Text(exercice.rawValue).tag(exercice)
                        }
                    }
                }
                
                Section(header: Text("Séries")) {
                    ForEach(series.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Série \(index + 1)")
                                .font(.headline)
                            
                            HStack {
                                Text("Reps:")
                                TextField("10", value: Binding(
                                    get: { series[index].repetitions.first ?? 0 },
                                    set: { series[index].repetitions = [$0] }
                                ), format: .number)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Poids (kg):")
                                TextField("20", value: Binding(
                                    get: { series[index].poids.first ?? 0 },
                                    set: { series[index].poids = [$0] }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    .onDelete { indexSet in
                        series.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        series.append(Serie(id: UUID(), repetitions: [10], poids: [20]))
                    }) {
                        Label("Ajouter une série", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Nouvel Exercice")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        let workout = Workout(id: UUID(), exercice: selectedExercice, series: series)
                        seance.workouts.append(workout)
                        dismiss()
                    }
                }
            }
        }
    }
}
