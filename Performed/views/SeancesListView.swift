//
//  SeancesListView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct SeancesListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSeance = false
    @State private var searchText = ""
    @State private var selectedFilter: FilterType = .all
    @State private var showDeleteAlert = false
    @State private var seanceToDelete: Seance?
    
    enum FilterType: String, CaseIterable {
        case all = "Toutes"
        case thisWeek = "Cette semaine"
        case thisMonth = "Ce mois"
        case older = "Plus anciennes"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .thisWeek: return "calendar.badge.clock"
            case .thisMonth: return "calendar"
            case .older: return "clock.arrow.circlepath"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredSeances: [Seance] {
        let calendar = Calendar.current
        let now = Date()
        
        var filtered = dataManager.seances.sorted { $0.date > $1.date }
        
        // Filtre par recherche
        if !searchText.isEmpty {
            filtered = filtered.filter { seance in
                seance.date.formatted().localizedCaseInsensitiveContains(searchText) ||
                seance.workouts.contains { $0.exercice.rawValue.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filtre par période
        switch selectedFilter {
        case .all:
            break
        case .thisWeek:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            filtered = filtered.filter { $0.date >= weekStart }
        case .thisMonth:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filtered = filtered.filter { $0.date >= monthStart }
        case .older:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            filtered = filtered.filter { $0.date < monthStart }
        }
        
        return filtered
    }
    
    var groupedSeances: [String: [Seance]] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        
        return Dictionary(grouping: filteredSeances) { seance in
            formatter.string(from: seance.date)
        }
    }
    
    var sortedGroups: [(key: String, value: [Seance])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        
        return groupedSeances.sorted { first, second in
            guard let date1 = formatter.date(from: first.key),
                  let date2 = formatter.date(from: second.key) else {
                return first.key > second.key
            }
            return date1 > date2
        }
    }
    
    var totalWorkouts: Int {
        filteredSeances.reduce(0) { $0 + $1.workouts.count }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.seances.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats rapides
                            quickStatsView
                            
                            // Barre de recherche
                            searchBar
                            
                            // Filtres
                            filterBar
                            
                            // Liste groupée par mois
                            if filteredSeances.isEmpty {
                                noResultsView
                            } else {
                                seancesList
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingAddButton
                            .padding()
                    }
                }
            }
            .navigationTitle("Mes Séances")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddSeance) {
                AddSeanceView()
                    .environmentObject(dataManager)
            }
            .alert("Supprimer la séance", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    if let seance = seanceToDelete {
                        withAnimation {
                            dataManager.deleteSeance(seance)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cette séance ? Cette action est irréversible.")
            }
        }
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickStatMini(
                    icon: "dumbbell.fill",
                    value: "\(filteredSeances.count)",
                    label: "Séances",
                    color: .blue
                )
                
                QuickStatMini(
                    icon: "list.bullet",
                    value: "\(totalWorkouts)",
                    label: "Exercices",
                    color: .green
                )
                
                if let lastSeance = filteredSeances.first {
                    QuickStatMini(
                        icon: "clock.fill",
                        value: lastSeance.date.timeAgoDisplay(),
                        label: "Dernière",
                        color: .orange
                    )
                }
                
                if selectedFilter != .all {
                    QuickStatMini(
                        icon: "line.3.horizontal.decrease.circle.fill",
                        value: selectedFilter.rawValue,
                        label: "Filtre actif",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Rechercher une séance ou un exercice", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Seances List
    
    private var seancesList: some View {
        LazyVStack(spacing: 24) {
            ForEach(sortedGroups, id: \.key) { group in
                VStack(alignment: .leading, spacing: 12) {
                    // Section Header
                    HStack {
                        Text(group.key.capitalized)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(group.value.count) séance\(group.value.count > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray5))
                            )
                    }
                    .padding(.horizontal)
                    
                    // Séances du groupe
                    ForEach(group.value) { seance in
                        NavigationLink(destination: SeanceDetailView(seance: seance)) {
                            EnhancedSeanceCardView(seance: seance) {
                                seanceToDelete = seance
                                showDeleteAlert = true
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button {
            showingAddSeance = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Nouvelle séance")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack{
            
            VStack(spacing: 20) {
                
                Text("Aucune séance enregistrée")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Commencez à suivre vos entraînements en créant votre première séance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Button {
                    showingAddSeance = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Créer ma première séance")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Aucun résultat")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Essayez de modifier votre recherche ou vos filtres")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Enhanced Seance Card

struct EnhancedSeanceCardView: View {
    let seance: Seance
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    private var totalSeries: Int {
        seance.workouts.reduce(0) { $0 + $1.series.count }
    }
    
    private var totalReps: Int {
        seance.workouts.reduce(0) { total, workout in
            total + workout.series.reduce(0) { $0 + $1.repetitions.count }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(seance.seanceName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(seance.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(seance.workouts.count)", systemImage: "list.bullet")
                        Label("\(totalSeries)", systemImage: "number")
                        Label("\(totalReps)", systemImage: "repeat")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Exercices preview
            if !seance.workouts.isEmpty {
                Divider()
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(seance.workouts.prefix(3), id: \.id) { workout in
                            ExerciceChip(exercice: workout.exercice)
                        }
                        
                        if seance.workouts.count > 3 {
                            Text("+\(seance.workouts.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 1 : 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Supporting Views

struct QuickStatMini: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct ExerciceChip: View {
    let exercice: Exercice
    
    var body: some View {
        Text(exercice.rawValue)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
    }
}

// MARK: - Preview

struct SeancesListView_Previews: PreviewProvider {
    static var previews: some View {
        SeancesListView()
            .environmentObject(DataManager())
    }
}
