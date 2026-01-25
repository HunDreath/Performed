//
//  HomeView.swift
//  Performed
//
//  Created by Lucas Morin on 14/01/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedExercice: Exercice?
    @State private var showAllStats = false
    
    // MARK: - Computed Properties
    
    var totalSeances: Int {
        dataManager.seances.count
    }
    
    var seancesThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        return dataManager.seances.filter { seance in
            seance.date >= weekStart && seance.date <= now
        }.count
    }
    
    var seancesThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return dataManager.seances.filter { seance in
            seance.date >= monthStart && seance.date <= now
        }.count
    }
    
    var lastSeance: Seance? {
        dataManager.seances.sorted { $0.date > $1.date }.first
    }
    
    var topExercices: [(Exercice, Int)] {
        var counts: [Exercice: Int] = [:]
        dataManager.seances.forEach { seance in
            seance.workouts.forEach { workout in
                counts[workout.exercice, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { $0 }
    }
    
    var totalWorkoutsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        return dataManager.seances
            .filter { $0.date >= weekStart && $0.date <= now }
            .reduce(0) { $0 + $1.workouts.count }
    }
    
    // Progression pour un exercice spécifique
    func progressionExercice(_ exercice: Exercice) -> [(Date, Double)] {
        var progression: [(Date, Double)] = []
        
        let seancesSorted = dataManager.seances.sorted { $0.date < $1.date }
        
        seancesSorted.forEach { seance in
            if let workout = seance.workouts.first(where: { $0.exercice == exercice }) {
                let poidsMax = workout.series.compactMap { serie in
                    serie.poids.max()
                }.max() ?? 0
                
                if poidsMax > 0 {
                    progression.append((seance.date, poidsMax))
                }
            }
        }
        
        return progression
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec greeting
                    headerView
                    
                    if totalSeances == 0 {
                        // État vide
                        emptyStateView
                    } else {
                        // Stats rapides
                        quickStatsView
                        
                        // Dernière séance
                        if let lastSeance = lastSeance {
                            lastSessionView(lastSeance)
                        }
                        
                        // Top 3 exercices
                        if !topExercices.isEmpty {
                            topExercicesView
                        }
                        
                        // Bouton vers les stats complètes
                        fullStatsButton
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tableau de bord")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if totalSeances > 0 {
                        Text("Continuez comme ça ! 💪")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Prêt pour votre première séance ?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Badge de streak ou motivation
                if seancesThisWeek > 0 {
                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("\(seancesThisWeek)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("cette sem.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aperçu")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickStatCard(
                        icon: "calendar",
                        title: "Total",
                        value: "\(totalSeances)",
                        subtitle: "séances",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "séances",
                        value: "\(seancesThisMonth)",
                        subtitle: "ce mois",
                        color: .green
                    )
                    
                    QuickStatCard(
                        icon: "dumbbell.fill",
                        title: "exercices",
                        value: "\(totalWorkoutsThisWeek)",
                        subtitle: "cette semaine",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Last Session
    
    private func lastSessionView(_ seance: Seance) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dernière séance")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(seance.seanceName)
                            .font(.subheadline)
                        
                        Text(seance.date.formatted(date: .long, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(seance.workouts.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("exercices")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Liste des exercices de la dernière séance
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(seance.workouts.prefix(3), id: \.id) { workout in
                        HStack {
                            
                            Text(workout.exercice.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(workout.series.count) séries")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if seance.workouts.count > 3 {
                        Text("+\(seance.workouts.count - 3) autres exercices")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Top Exercices
    
    private var topExercicesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top 3 exercices")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(Array(topExercices.enumerated()), id: \.element.0) { index, item in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(rankColor(index).opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(rankColor(index))
                        }
                        
                        Text(item.0.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(rankColor(index))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Full Stats Button
    
    private var fullStatsButton: some View {
        NavigationLink(destination: StatistiquesView()) {
            HStack {
                Text("Voir toutes les statistiques")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "arrow.right")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("Commencez votre parcours")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enregistrez votre première séance pour voir vos statistiques et suivre votre progression")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            NavigationLink(destination: AddSeanceView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Créer une séance")
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Bonjour"
        case 12..<18:
            return "Bon après-midi"
        default:
            return "Bonsoir"
        }
    }
    
    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .orange
        case 1: return .blue
        case 2: return .green
        default: return .purple
        }
    }
}

// MARK: - Quick Stat Card Component

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 140, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
    }
}

// MARK: - Date Extension

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Hier" : "Il y a \(day)j"
        } else if let hour = components.hour, hour > 0 {
            return "Il y a \(hour)h"
        } else if let minute = components.minute, minute > 0 {
            return "Il y a \(minute)m"
        } else {
            return "À l'instant"
        }
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataManager())
    }
}
