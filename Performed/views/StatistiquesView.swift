//
//  StatistiquesView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct StatistiquesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedExercice: Exercice?
    
    var totalSeances: Int {
        dataManager.seances.count
    }
    
    var exercicesStats: [(Exercice, Int)] {
        var counts: [Exercice: Int] = [:]
        dataManager.seances.forEach { seance in
            seance.workouts.forEach { workout in
                counts[workout.exercice, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
    
    var totalExercicesUniques: Int {
        exercicesStats.count
    }
    
    var totalSeries: Int {
        dataManager.seances.reduce(0) { total, seance in
            total + seance.workouts.reduce(0) { $0 + $1.series.count }
        }
    }
    
    var moyenneSeriesParSeance: Int {
        totalSeances > 0 ? totalSeries / totalSeances : 0
    }
    
    // Calcul des tendances
    var seancesTrend: StatCard.TrendType? {
        let calendar = Calendar.current
        let now = Date()
        
        // Séances du mois actuel
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let currentMonthSeances = dataManager.seances.filter { $0.date >= currentMonthStart }.count
        
        // Séances du mois dernier
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)!
        let lastMonthSeances = dataManager.seances.filter {
            $0.date >= lastMonthStart && $0.date < currentMonthStart
        }.count
        
        if lastMonthSeances == 0 { return nil }
        
        let percentChange = ((Double(currentMonthSeances) - Double(lastMonthSeances)) / Double(lastMonthSeances)) * 100
        
        if percentChange > 0 {
            return .up("+\(Int(percentChange))%")
        } else if percentChange < 0 {
            return .down("\(Int(percentChange))%")
        } else {
            return .neutral("0%")
        }
    }
    
    var seriesTrend: StatCard.TrendType? {
        guard let lastSeance = dataManager.seances.sorted(by: { $0.date > $1.date }).first,
              dataManager.seances.count > 1 else { return nil }
        
        let lastSeanceSeries = lastSeance.workouts.reduce(0) { $0 + $1.series.count }
        
        if lastSeanceSeries > moyenneSeriesParSeance {
            return .up("+\(lastSeanceSeries - moyenneSeriesParSeance)")
        } else if lastSeanceSeries < moyenneSeriesParSeance {
            return .down("\(lastSeanceSeries - moyenneSeriesParSeance)")
        } else {
            return .neutral("Moy.")
        }
    }
    
    var recordPoids: (exercice: String, poids: Double)? {
        var maxPoids: Double = 0
        var maxExercice: String = ""
        
        dataManager.seances.forEach { seance in
            seance.workouts.forEach { workout in
                if let poidsMax = workout.series.compactMap({ $0.poids.max() }).max(),
                   poidsMax > maxPoids {
                    maxPoids = poidsMax
                    maxExercice = workout.exercice.rawValue
                }
            }
        }
        
        return maxPoids > 0 ? (maxExercice, maxPoids) : nil
    }
    
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
                    // Vue d'ensemble - Stats principales
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vue d'ensemble")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Séances",
                                    value: "\(totalSeances)",
                                    color: .blue,
                                    icon: "dumbbell.fill",
                                    subtitle: "Total",
                                    trend: seancesTrend ?? .neutral("Stable"),
                                    style: .default
                                )
                                
                                StatCard(
                                    title: "Exercices",
                                    value: "\(totalExercicesUniques)",
                                    color: .green,
                                    icon: "list.bullet",
                                    subtitle: "Différents",
                                    trend: .neutral("\(exercicesStats.count) types"),
                                    style: .default
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Séries",
                                    value: "\(totalSeries)",
                                    color: .orange,
                                    icon: "number",
                                    subtitle: "Total effectuées",
                                    trend: seriesTrend ?? .neutral("Moy."),
                                    style: .default
                                )
                                
                                StatCard(
                                    title: "Moyenne",
                                    value: "\(moyenneSeriesParSeance)",
                                    color: .purple,
                                    icon: "chart.bar.fill",
                                    subtitle: "Séries / séance",
                                    trend: .neutral("Par séance"),
                                    style: .default
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Record personnel
                    if let record = recordPoids {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Record personnel")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            StatCard(
                                title: record.exercice,
                                value: "\(String(format: "%.1f", record.poids)) kg",
                                color: .red,
                                icon: "trophy.fill",
                                subtitle: "Poids maximum",
                                trend: .up("Record !"),
                                style: .detailed
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Exercices les plus pratiqués
                    if !exercicesStats.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Exercices les plus pratiqués")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if let topExercice = exercicesStats.first {
                                    HStack(spacing: 4) {
                                        Image(systemName: "medal.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text("\(topExercice.1)x")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            HorizontalBarChartView(
                                data: Array(exercicesStats.prefix(10)),
                                title: "Top 10 des exercices"
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Stats compactes supplémentaires
                    if totalSeances > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistiques détaillées")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                StatCard(
                                    title: "Poids total soulevé (estimé)",
                                    value: "\(calculateTotalWeight()) kg",
                                    color: .cyan,
                                    icon: "scalemass.fill",
                                    subtitle: "",
                                    trend: .neutral("Cumulé"),
                                    style: .compact
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Sélection exercice pour progression
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progression par exercice")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Menu de sélection amélioré
                        Menu {
                            Button("Aucun exercice") {
                                selectedExercice = nil
                            }
                            
                            Divider()
                            
                            ForEach(exercicesStats.prefix(20), id: \.0) { exercice, count in
                                Button {
                                    selectedExercice = exercice
                                } label: {
                                    HStack {
                                        Text(exercice.rawValue)
                                        Spacer()
                                        Text("\(count) sessions")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if exercicesStats.count > 20 {
                                Divider()
                                
                                Menu("Tous les exercices") {
                                    ForEach(Exercice.allCases) { exercice in
                                        Button(exercice.rawValue) {
                                            selectedExercice = exercice
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "dumbbell")
                                    .foregroundColor(selectedExercice == nil ? .secondary : .blue)
                                
                                Text(selectedExercice?.rawValue ?? "Sélectionner un exercice")
                                    .foregroundColor(selectedExercice == nil ? .secondary : .primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                            )
                        }
                        .padding(.horizontal)
                        
                        if let exercice = selectedExercice {
                            let progression = progressionExercice(exercice)
                            if !progression.isEmpty {
                                LineChartView(data: progression, exercice: exercice.rawValue)
                                    .padding(.horizontal)
                                    .transition(.opacity.combined(with: .scale))
                            } else {
                                emptyProgressionView
                            }
                        } else {
                            selectExercicePromptView
                        }
                    }
                    
                    // État vide général
                    if totalSeances == 0 {
                        emptyStateView
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut, value: selectedExercice)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Empty States
    
    private var emptyProgressionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Aucune donnée disponible")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Enregistrez des séances pour cet exercice")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
        .transition(.opacity)
    }
    
    private var selectExercicePromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.3))
            
            Text("Sélectionnez un exercice")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Visualisez votre progression au fil du temps")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.3))
            
            Text("Aucune statistique disponible")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enregistrez vos premières séances pour voir vos statistiques et suivre votre progression")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
    
    // MARK: - Helper Functions
    
    private func calculateTotalWeight() -> String {
        let total = dataManager.seances.reduce(0.0) { seanceTotal, seance in
            seanceTotal + seance.workouts.reduce(0.0) { workoutTotal, workout in
                workoutTotal + workout.series.reduce(0.0) { seriesTotal, serie in
                    let avgPoids = serie.poids.isEmpty ? 0 : serie.poids.reduce(0, +) / Double(serie.poids.count)
                    return seriesTotal + (avgPoids * Double(serie.repetitions.count))
                }
            }
        }
        
        if total >= 1000 {
            return String(format: "%.1f", total / 1000) + "k"
        } else {
            return String(format: "%.0f", total)
        }
    }
    
    private func daysSinceFirstSession(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        
        if days >= 365 {
            let years = days / 365
            return "\(years) an\(years > 1 ? "s" : "")"
        } else if days >= 30 {
            let months = days / 30
            return "\(months) mois"
        } else {
            return "\(days) j"
        }
    }
}

// MARK: - Preview
struct StatistiquesView_Previews: PreviewProvider {
    static var previews: some View {
        StatistiquesView()
            .environmentObject(DataManager())
    }
}
