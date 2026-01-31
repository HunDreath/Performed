//
//  ExercisePicker.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//  Enhanced with search functionality
//

import SwiftUI

struct ExercisePicker: View {
    @Binding var selectedExercice: Exercice
    @State private var showingExerciseList = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Type d'exercice")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                showingExerciseList = true
            }) {
                HStack {
                    Text(selectedExercice.rawValue)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .sheet(isPresented: $showingExerciseList) {
            ExerciseSearchView(selectedExercice: $selectedExercice, isPresented: $showingExerciseList)
        }
    }
}

// MARK: - Exercise Search View

struct ExerciseSearchView: View {
    @Binding var selectedExercice: Exercice
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @FocusState private var searchFieldFocused: Bool
    
    var filteredExercices: [Exercice] {
        if searchText.isEmpty {
            return Exercice.allCases
        } else {
            return Exercice.allCases.filter { exercice in
                exercice.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Rechercher un exercice...", text: $searchText)
                            .focused($searchFieldFocused)
                            .autocorrectionDisabled()
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Exercise list
                if filteredExercices.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredExercices) { exercice in
                                ExerciseRow(
                                    exercice: exercice,
                                    isSelected: exercice == selectedExercice,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedExercice = exercice
                                        }
                                        
                                        // Haptic feedback
                                        let generator = UISelectionFeedbackGenerator()
                                        generator.selectionChanged()
                                        
                                        // Dismiss after short delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            isPresented = false
                                        }
                                    }
                                )
                                
                                if exercice != filteredExercices.last {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Choisir un exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            // Auto-focus search field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                searchFieldFocused = true
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Aucun exercice trouvé")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Essayez un autre terme de recherche")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercice: Exercice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray5))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: exerciceIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
                
                // Exercise name
                Text(exercice.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // Helper to get appropriate icon for each exercise type
    private var exerciceIcon: String {
        switch exercice {
        case .developeCouche, .developeNuque, .developeHalteresEpaules:
            return "figure.strengthtraining.functional"
        case .squat, .squatFront, .legCurl:
            return "figure.strengthtraining.traditional"
        case .souleverDeTerre, .rowingBarre:
            return "figure.mixed.cardio"
        case .tractionsDos, .tractionsSupination:
            return "figure.climbing"
        case .developeMilitaire, .elevationLaterale:
            return "figure.arms.open"
        case .curlsBarre, .curlsBiceps:
            return "figure.cooldown"
        case .extensionNuque, .dips:
            return "figure.core.training"
        default:
            return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Preview

struct ExercisePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ExercisePicker(selectedExercice: .constant(.developeCouche))
            
            ExercisePicker(selectedExercice: .constant(.squat))
            
            ExercisePicker(selectedExercice: .constant(.tractionsDos))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Exercise Picker")
        
        // Dark mode
        ExercisePicker(selectedExercice: .constant(.souleverDeTerre))
            .padding()
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark Mode")
        
        // Search view preview
        ExerciseSearchView(
            selectedExercice: .constant(.squat),
            isPresented: .constant(true)
        )
        .previewDisplayName("Search View")
    }
}
