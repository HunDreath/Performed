//
//  AddSeanceView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct AddSeanceView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newSeance = Seance()
    @State private var showingAddWorkout = false
    @State private var selectedWorkoutIndex: Int?
    @State private var showDeleteAlert = false
    @State private var workoutToDelete: Workout?
    @State private var seanceName = ""
    @State private var seanceNotes = ""
    
    // Validation
    private var canSave: Bool {
        !newSeance.workouts.isEmpty && !seanceName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var totalSeries: Int {
        newSeance.workouts.reduce(0) { $0 + $1.series.count }
    }
    
    private var totalReps: Int {
        newSeance.workouts.reduce(0) { total, workout in
            total + workout.series.reduce(0) { $0 + $1.repetitions.count }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header card
                    headerCard
                    
                    // Stats rapides
                    if !newSeance.workouts.isEmpty {
                        quickStatsSection
                    }
                    
                    // Bouton ajouter exercice
                    addWorkoutButton
                    
                    // Liste des exercices
                    workoutsSection
                    
                    // Date section
                    dateSection
                    
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nouvelle Séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.caption)
                            Text("Annuler")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveSeance()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                            Text("Enregistrer")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(seance: $newSeance)
            }
            .sheet(item: $selectedWorkoutIndex) { index in
                if index < newSeance.workouts.count {
                    EditWorkoutView(
                        workout: $newSeance.workouts[index],
                        onDelete: {
                            newSeance.workouts.remove(at: index)
                            selectedWorkoutIndex = nil
                        }
                    )
                }
            }
            .alert("Supprimer l'exercice", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    if let workout = workoutToDelete,
                       let index = newSeance.workouts.firstIndex(where: { $0.id == workout.id }) {
                        withAnimation {
                            newSeance.workouts.remove(at: index)
                        }
                    }
                }
            } message: {
                Text("Voulez-vous vraiment supprimer cet exercice de la séance ?")
            }
        }
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            
            // Nom de la séance
            VStack(spacing: 8) {
                Text("Nom de la séance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Ex: Push Day, Full Body...", text: $seanceName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Date Section
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Date de la séance", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.primary)
            
            DatePicker(
                "",
                selection: $newSeance.date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .tint(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            QuickStatBox(
                icon: "list.bullet",
                value: "\(newSeance.workouts.count)",
                label: "Exercices",
                color: .blue
            )
            
            QuickStatBox(
                icon: "number",
                value: "\(totalSeries)",
                label: "Séries",
                color: .green
            )
            
            QuickStatBox(
                icon: "repeat",
                value: "\(totalReps)",
                label: "Reps",
                color: .orange
            )
        }
    }
    
    // MARK: - Workouts Section
    
    private var workoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Exercices", systemImage: "dumbbell.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !newSeance.workouts.isEmpty {
                    Text("\(newSeance.workouts.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            
            if newSeance.workouts.isEmpty {
                emptyWorkoutsView
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(newSeance.workouts.enumerated()), id: \.element.id) { index, workout in
                        WorkoutCardView(
                            workout: workout,
                            rank: index + 1,
                            onTap: {
                                selectedWorkoutIndex = index
                            },
                            onDelete: {
                                workoutToDelete = workout
                                showDeleteAlert = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Empty Workouts View
    
    private var emptyWorkoutsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.walk")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Aucun exercice ajouté")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Commencez par ajouter des exercices à votre séance")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
    
    // MARK: - Add Workout Button
    
    private var addWorkoutButton: some View {
        Button {
            showingAddWorkout = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Ajouter un exercice")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Helper Functions
    
    private func saveSeance() {
        newSeance.seanceName = seanceName.trimmingCharacters(in: .whitespaces)
    
        dataManager.addSeance(newSeance)
        dismiss()
    }
}

// MARK: - Workout Card View

struct WorkoutCardView: View {
    let workout: Workout
    let rank: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    private var totalReps: Int {
        workout.series.reduce(0) { $0 + $1.repetitions.count }
    }
    
    private var avgWeight: Double {
        let allWeights = workout.series.flatMap { $0.poids }
        guard !allWeights.isEmpty else { return 0 }
        return allWeights.reduce(0, +) / Double(allWeights.count)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.exercice.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(workout.series.count)", systemImage: "number")
                        Label("\(totalReps)", systemImage: "repeat")
                        
                        if avgWeight > 0 {
                            Label("\(String(format: "%.1f", avgWeight)) kg", systemImage: "scalemass")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: 8) {
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Quick Stat Box

struct QuickStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Edit Workout View

struct EditWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var workout: Workout
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercice") {
                    Text(workout.exercice.rawValue)
                        .font(.headline)
                }
                
                Section("Séries") {
                    ForEach(Array(workout.series.enumerated()), id: \.offset) { index, serie in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Série \(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("\(serie.repetitions.count) reps")
                                Spacer()
                                if let avgPoids = serie.poids.isEmpty ? nil : serie.poids.reduce(0, +) / Double(serie.poids.count) {
                                    Text("\(String(format: "%.1f", avgPoids)) kg")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Supprimer cet exercice", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Int Identifiable Extension

extension Int: Identifiable {
    public var id: Int { self }
}

// MARK: - Preview

struct AddSeanceView_Previews: PreviewProvider {
    static var previews: some View {
        AddSeanceView()
            .environmentObject(DataManager())
    }
}
