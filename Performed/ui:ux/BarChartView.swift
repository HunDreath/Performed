//
//  BarChartView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct BarChartView: View {
    let data: [(String, Int)]
    let title: String?
    let color: Color
    
    @State private var animateBars = false
    @State private var selectedIndex: Int?
    
    private var maxValue: Int {
        data.map { $0.1 }.max() ?? 1
    }
    
    private var totalValue: Int {
        data.reduce(0) { $0 + $1.1 }
    }
    
    private var averageValue: Double {
        data.isEmpty ? 0 : Double(totalValue) / Double(data.count)
    }
    
    init(data: [(String, Int)], title: String? = nil, color: Color = .blue) {
        self.data = data
        self.title = title
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            if let title = title {
                headerView
            }
            
            // Chart
            VStack(spacing: 12) {
                // Legend / Stats
                statsRow
                
                // Bars
                GeometryReader { geometry in
                    HStack(alignment: .bottom, spacing: calculateSpacing(for: geometry.size.width)) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            barView(for: item, at: index, maxHeight: geometry.size.height - 40)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                
                // X-axis labels
                xAxisLabels
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateBars = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Total badge
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                    Text("\(totalValue)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.15))
                )
                .foregroundColor(color)
            }
            
            Divider()
        }
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 20) {
            // Max value indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Max")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(maxValue)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
            
            // Average indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(color.opacity(0.5))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Moy.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", averageValue))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Selected value
            if let selectedIndex = selectedIndex {
                HStack(spacing: 4) {
                    Image(systemName: "hand.point.up.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text("\(data[selectedIndex].1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
    }
    
    // MARK: - Bar View
    
    private func barView(for item: (String, Int), at index: Int, maxHeight: CGFloat) -> some View {
        let isSelected = selectedIndex == index
        let barHeight = animateBars ? (CGFloat(item.1) / CGFloat(maxValue) * maxHeight) : 0
        let isAboveAverage = Double(item.1) > averageValue
        
        return VStack(spacing: 8) {
            // Value label
            if animateBars {
                Text("\(item.1)")
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? color : .secondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Bar with gradient
            ZStack(alignment: .bottom) {
                // Background bar (for context)
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(height: maxHeight)
                
                // Average line
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(height: 1)
                    .offset(y: -(CGFloat(averageValue) / CGFloat(maxValue) * maxHeight))
                
                // Actual bar
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                isAboveAverage ? color.opacity(0.7) : color.opacity(0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: barHeight)
                    .overlay(
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .offset(y: animateBars ? -maxHeight : maxHeight)
                            .animation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.1),
                                value: animateBars
                            )
                    )
                    .shadow(color: isSelected ? color.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                
                // Above average indicator
                if isAboveAverage && animateBars {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .offset(y: -barHeight - 5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.05), value: animateBars)
            .scaleEffect(x: isSelected ? 1.1 : 1.0, y: 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIndex = selectedIndex == index ? nil : index
            }
        }
    }
    
    // MARK: - X-Axis Labels
    
    private var xAxisLabels: some View {
        HStack(alignment: .top, spacing: calculateSpacing(for: UIScreen.main.bounds.width - 64)) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                Text(item.0)
                    .font(.caption2)
                    .foregroundColor(selectedIndex == index ? color : .secondary)
                    .fontWeight(selectedIndex == index ? .semibold : .regular)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateSpacing(for width: CGFloat) -> CGFloat {
        let numberOfBars = CGFloat(data.count)
        let totalBarWidth = numberOfBars * 40
        let availableSpace = width - totalBarWidth
        return max(8, availableSpace / (numberOfBars + 1))
    }
}

// MARK: - Convenience Initializers

extension BarChartView {
    // Simple initializer (backward compatible)
    init(data: [(String, Int)]) {
        self.data = data
        self.title = nil
        self.color = .blue
    }
}

// MARK: - Preview

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Default
                BarChartView(
                    data: [
                        ("Jan", 8),
                        ("Fév", 12),
                        ("Mar", 15),
                        ("Avr", 10),
                        ("Mai", 18),
                        ("Juin", 14)
                    ],
                    title: "Séances par mois",
                    color: .blue
                )
                .frame(height: 250)
                
                // Different color
                BarChartView(
                    data: [
                        ("Lun", 5),
                        ("Mar", 8),
                        ("Mer", 6),
                        ("Jeu", 12),
                        ("Ven", 9),
                        ("Sam", 15),
                        ("Dim", 4)
                    ],
                    title: "Séances par jour",
                    color: .green
                )
                .frame(height: 250)
                
                // Orange theme
                BarChartView(
                    data: [
                        ("S1", 20),
                        ("S2", 25),
                        ("S3", 18),
                        ("S4", 30)
                    ],
                    title: "Progression hebdomadaire",
                    color: .orange
                )
                .frame(height: 250)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
