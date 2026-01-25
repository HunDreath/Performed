//
//  ProfilView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct ProfilView: View {
    
    @EnvironmentObject var dataManager: DataManager
    @State private var showEditNameSheet = false
    @State private var showAboutSheet = false
    @State private var showResetAlert = false
    @State private var tempName = ""
    
    // Stats calculées
    var totalSeances: Int {
        dataManager.seances.count
    }
    
    var totalExercices: Int {
        var uniqueExercices: Set<Exercice> = []
        dataManager.seances.forEach { seance in
            seance.workouts.forEach { workout in
                uniqueExercices.insert(workout.exercice)
            }
        }
        return uniqueExercices.count
    }
    
    var totalSeries: Int {
        dataManager.seances.reduce(0) { total, seance in
            total + seance.workouts.reduce(0) { $0 + $1.series.count }
        }
    }
    
    var memberSince: String {
        if let firstSeance = dataManager.seances.sorted(by: { $0.date < $1.date }).first {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: firstSeance.date)
        }
        return "Nouveau membre"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec avatar et nom
                    profileHeaderView
                    
                    // Sections
                    VStack(spacing: 16) {
                        accountSection
                        
                        BannerAdView()
                        .frame(height: 50)
                        
                        statsSection
                        appSection
                        dangerZoneSection
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditNameSheet) {
                editNameSheet
            }
            .sheet(isPresented: $showAboutSheet) {
                aboutSheet
            }
            .alert("Réinitialiser les données", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer tout", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer toutes vos données ? Cette action est irréversible.")
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text(dataManager.user.name.prefix(2).uppercased())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Nom et bouton d'édition
            VStack(spacing: 4) {
                Text(dataManager.user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Membre depuis \(memberSince)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button {
                tempName = dataManager.user.name
                showEditNameSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.caption)
                    Text("Modifier le profil")
                        .font(.subheadline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Sections
    
    private var accountSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Compte")
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "person.fill",
                    title: "Nom",
                    value: dataManager.user.name,
                    color: .blue
                ) {
                    tempName = dataManager.user.name
                    showEditNameSheet = true
                }
                
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Statistiques détaillées")
            
            VStack(spacing: 0) {
                NavigationLink(destination: StatistiquesView()) {
                    ProfileRow(
                        icon: "chart.bar.fill",
                        title: "Voir les statistiques",
                        color: .purple,
                        showValue: false
                    )
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileRow(
                    icon: "calendar",
                    title: "Première séance",
                    value: memberSince,
                    color: .orange,
                    showChevron: false
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private var appSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Application")
            
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "info.circle.fill",
                    title: "À propos",
                    color: .indigo
                ) {
                    showAboutSheet = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileRow(
                    icon: "star.fill",
                    title: "Noter l'application",
                    color: .yellow
                ) {
                    // Action pour noter l'app
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Partager l'application",
                    color: .cyan
                ) {
                    // Action pour partager
                }
                
                Divider()
                    .padding(.leading, 56)
                
                ProfileRow(
                    icon: "gear",
                    title: "Version",
                    value: "1.0.0",
                    color: .gray,
                    showChevron: false
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Zone de danger")
            
            VStack(spacing: 0) {
                Button {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.red)
                            .cornerRadius(8)
                        
                        Text("Réinitialiser toutes les données")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    // MARK: - Edit Name Sheet
    
    private var editNameSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nom", text: $tempName)
                        .textContentType(.name)
                } header: {
                    Text("Modifier votre nom")
                } footer: {
                    Text("Ce nom sera affiché sur votre profil")
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        showEditNameSheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        if !tempName.trimmingCharacters(in: .whitespaces).isEmpty {
                            dataManager.user.name = tempName
                            dataManager.saveUser()
                            showEditNameSheet = false
                        }
                    }
                    .disabled(tempName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - About Sheet
    
    private var aboutSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()
                    
                    VStack(spacing: 8) {
                        Text("Performed")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("À propos")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("Performed est votre compagnon d'entraînement personnel. Suivez vos séances, analysez votre progression et atteignez vos objectifs de fitness.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical)
                        
                        VStack(spacing: 12) {
                            InfoRow(label: "Développeur", value: "Algiz Team")
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("© 2026 Performed. Tous droits réservés.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        showAboutSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateStreak() -> Int? {
        guard !dataManager.seances.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let sortedDates = dataManager.seances
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if date < currentDate {
                break
            }
        }
        
        return streak > 0 ? streak : nil
    }
    
    private func resetAllData() {
        dataManager.seances.removeAll()
        dataManager.saveSeances()
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let color: Color
    var showValue: Bool = true
    var showChevron: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .cornerRadius(8)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if showValue, let value = value {
                    Text(value)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .disabled(action == nil && !showChevron)
    }
}

struct StatCardCompact: View {
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
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView()
            .environmentObject(DataManager())
    }
}
