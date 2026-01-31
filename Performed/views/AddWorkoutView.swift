//
//  AddWorkoutView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//  Refactored with modern UI components
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var seance: Seance
    @State private var selectedExercice: Exercice = .developeCouche
    @State private var series: [Serie] = [Serie(repetitions: [10], poids: [20])]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Exercise Picker
                    ExercisePicker(selectedExercice: $selectedExercice)
                    
                    // Series Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Section header
                        HStack {
                            Label {
                                Text("Séries")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            } icon: {
                                Image(systemName: "list.bullet.rectangle.fill")
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            // Serie count badge
                            Text("\(series.count)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .blue.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 4)
                        
                        // Series list
                        ForEach(series.indices, id: \.self) { index in
                            SerieRow(
                                index: index,
                                serie: $series[index],
                                canDelete: series.count > 1,
                                onDelete: {
                                    if series.count > 1 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            series.remove(atOffsets: IndexSet(integer: index))
                                        }
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                        
                        // Add serie button
                        AddSerieButton {
                            series.append(Serie(id: UUID(), repetitions: [10], poids: [20]))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Summary card
                    summaryCard
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Nouvel Exercice")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                            Text("Annuler")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let workout = Workout(id: UUID(), exercice: selectedExercice, series: series)
                        seance.workouts.append(workout)
                        
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Text("Ajouter")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.orange)
                
                Text("Résumé de l'exercice")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Divider()
            
            // Stats
            HStack(spacing: 20) {
                // Total sets
                VStack(spacing: 4) {
                    Text("\(series.count)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Séries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                // Total reps
                VStack(spacing: 4) {
                    Text("\(totalReps)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text("Reps totales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                // Total volume
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", totalVolume))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Volume (kg)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.2), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Computed Properties
    
    private var totalReps: Int {
        series.reduce(0) { $0 + ($1.repetitions.first ?? 0) }
    }
    
    private var totalVolume: Double {
        series.reduce(0.0) { total, serie in
            let reps = Double(serie.repetitions.first ?? 0)
            let weight = Double(serie.poids.first ?? 0)
            return total + (reps * weight)
        }
    }
}

// MARK: - Preview

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        // Default preview
        AddWorkoutView(seance: .constant(Seance(
            id: UUID(),
            date: Date(),
            workouts: [
                Workout(
                    id: UUID(),
                    exercice: .squat,
                    series: [
                        Serie(repetitions: [10], poids: [100]),
                        Serie(repetitions: [8], poids: [110]),
                        Serie(repetitions: [6], poids: [120])
                    ]
                )
            ]
        )))
        .previewDisplayName("Add Workout - Default")
        
        // Dark mode
        AddWorkoutView(seance: .constant(Seance(
            id: UUID(),
            date: Date(),
            workouts: []
        )))
        .preferredColorScheme(.dark)
        .previewDisplayName("Add Workout - Dark Mode")
        
        // With multiple series
        AddWorkoutView(seance: .constant(Seance(
            id: UUID(),
            date: Date(),
            workouts: []
        )))
        .onAppear {
            // This would show a workout with 4 series in preview
        }
        .previewDisplayName("Add Workout - Multiple Series")
    }
}
