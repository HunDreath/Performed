//
//  HorizontalBarChartView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct HorizontalBarChartView: View {
    let data: [(Exercice, Int)]
    let title: String
    
    @State private var animateBars = false
    @State private var animateShimmer = false
    @State private var selectedExercice: Exercice?
    
    private var maxValue: Int {
        data.map { $0.1 }.max() ?? 1
    }
    
    private var totalSessions: Int {
        data.map { $0.1 }.reduce(0, +)
    }
    
    private var sortedData: [(Exercice, Int)] {
        data.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            headerView
            
            // Chart
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(sortedData.enumerated()), id: \.element.0) { index, item in
                        barView(for: item, rank: index + 1)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateBars = true
            }
            
            // Démarre l'animation shimmer après un court délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateShimmer = true
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(totalSessions) sessions au total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Podium icon
                if let topExercice = sortedData.first {
                    VStack(spacing: 2) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        
                        Text("\(topExercice.1)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Divider()
        }
    }
    
    // MARK: - Bar View
    private func barView(for item: (Exercice, Int), rank: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                // Rank badge
                rankBadge(rank)
                
                // Exercise name
                Text(item.0.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                // Count with percentage
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(item.1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(colorForRank(rank))
                    
                    if totalSessions > 0 {
                        Text("\(Int(Double(item.1) / Double(totalSessions) * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 24)
                    
                    // Animated bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors(for: rank)),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: animateBars ? geometry.size.width * CGFloat(item.1) / CGFloat(maxValue) : 0,
                            height: 24
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(rank - 1) * 0.05), value: animateBars)
                        .overlay(
                            // Shimmer effect
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0),
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60)
                                .offset(x: animateShimmer ? geometry.size.width : -60)
                                .animation(
                                    Animation.linear(duration: 1.5)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(rank - 1) * 0.1),
                                    value: animateShimmer
                                )
                        )
                    
                    // Value label inside bar
                    if animateBars && item.1 > maxValue / 4 {
                        Text("\(item.1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                            .transition(.opacity)
                    }
                }
            }
            .frame(height: 24)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedExercice = selectedExercice == item.0 ? nil : item.0
            }
        }
        .scaleEffect(selectedExercice == item.0 ? 1.02 : 1.0)
        .shadow(color: selectedExercice == item.0 ? Color.black.opacity(0.1) : Color.clear, radius: 4)
    }
    
    // MARK: - Rank Badge
    private func rankBadge(_ rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(backgroundColorForRank(rank))
                .frame(width: 28, height: 28)
            
            if rank <= 3 {
                Image(systemName: medalIcon(for: rank))
                    .font(.caption)
                    .foregroundColor(medalColor(for: rank))
            } else {
                Text("\(rank)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func gradientColors(for rank: Int) -> [Color] {
        switch rank {
        case 1:
            return [Color.orange, Color.orange.opacity(0.7)]
        case 2:
            return [Color.blue, Color.blue.opacity(0.7)]
        case 3:
            return [Color.green, Color.green.opacity(0.7)]
        default:
            return [Color.purple.opacity(0.7), Color.purple.opacity(0.5)]
        }
    }
    
    private func colorForRank(_ rank: Int) -> Color {
        switch rank {
        case 1: return .orange
        case 2: return .blue
        case 3: return .green
        default: return .purple
        }
    }
    
    private func backgroundColorForRank(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.orange.opacity(0.15)
        case 2: return Color.blue.opacity(0.15)
        case 3: return Color.green.opacity(0.15)
        default: return Color.gray.opacity(0.1)
        }
    }
    
    private func medalIcon(for rank: Int) -> String {
        switch rank {
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
    
    private func medalColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .gray
        }
    }
}

// MARK: - Preview
struct HorizontalBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top 5 exercices
                HorizontalBarChartView(
                    data: [
                        (.developeCouche, 25),
                        (.squat, 22),
                        (.souleverDeTerre, 18),
                        (.developeMilitaire, 15),
                        (.tractionsDos, 12)
                    ],
                    title: "Top 5 des exercices"
                )
                .frame(height: 350)
                
                // Top 10 exercices
                HorizontalBarChartView(
                    data: [
                        (.developeCouche, 30),
                        (.squat, 28),
                        (.souleverDeTerre, 25),
                        (.developeMilitaire, 20),
                        (.tractionsDos, 18),
                        (.rowing, 15),
                        (.curlsBiceps, 14),
                        (.extensionsTriceps, 12),
                        (.presseCuisses, 10),
                        (.elevationsMollets, 8)
                    ],
                    title: "Top 10 des exercices"
                )
                .frame(height: 600)
                
                // Peu de données
                HorizontalBarChartView(
                    data: [
                        (.developeCouche, 5),
                        (.squat, 3),
                        (.souleverDeTerre, 2)
                    ],
                    title: "Exercices récents"
                )
                .frame(height: 250)
                
                // Distribution équilibrée
                HorizontalBarChartView(
                    data: [
                        (.developeCouche, 15),
                        (.squat, 14),
                        (.souleverDeTerre, 13),
                        (.developeMilitaire, 13),
                        (.tractionsDos, 12),
                        (.rowing, 12)
                    ],
                    title: "Exercices équilibrés"
                )
                .frame(height: 400)
                
                // Un exercice dominant
                HorizontalBarChartView(
                    data: [
                        (.developeCouche, 50),
                        (.squat, 10),
                        (.souleverDeTerre, 8),
                        (.developeMilitaire, 5),
                        (.tractionsDos, 3)
                    ],
                    title: "Un favori clair"
                )
                .frame(height: 350)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}
