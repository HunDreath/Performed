//
//  LineChartView.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct LineChartView: View {
    let data: [(Date, Double)]
    let exercice: String
    
    @State private var selectedPoint: Int?
    @State private var showAnimation = false
    
    private var maxValue: Double {
        data.map { $0.1 }.max() ?? 1
    }
    
    private var minValue: Double {
        let min = data.map { $0.1 }.min() ?? 0
        // Ajoute une marge en bas pour une meilleure visualisation
        return max(0, min - (maxValue - min) * 0.1)
    }
    
    private var valueRange: Double {
        max(maxValue - minValue, 1)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header avec stats
            headerView
            
            // Graphique avec labels à gauche
            HStack(spacing: 8) {
                // Labels des valeurs (axe Y)
                yAxisLabels
                    .frame(width: 45)
                
                // Graphique
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        // Grille
                        gridView(geometry: geometry)
                        
                        // Gradient sous la courbe
                        gradientArea(geometry: geometry)
                        
                        // Ligne de progression
                        lineChart(geometry: geometry)
                        
                        // Points interactifs
                        pointsView(geometry: geometry)
                        
                        // Tooltip au survol
                        if let selectedPoint = selectedPoint {
                            tooltipView(for: selectedPoint, geometry: geometry)
                        }
                    }
                }
                .frame(height: 200)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateSelectedPoint(at: value.location, in: UIScreen.main.bounds.width - 109)
                        }
                        .onEnded { _ in
                            selectedPoint = nil
                        }
                )
            }
            
            // Axe des dates
            HStack(spacing: 8) {
                Spacer()
                    .frame(width: 45)
                
                dateAxisView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                showAnimation = true
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Progression - \(exercice)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let progression = calculateProgression() {
                    HStack(spacing: 4) {
                        Image(systemName: progression >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(progression >= 0 ? "+" : "")\(String(format: "%.1f", progression))%")
                    }
                    .font(.caption)
                    .foregroundColor(progression >= 0 ? .green : .red)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let last = data.last {
                    Text("\(String(format: "%.1f", last.1)) kg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Actuel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Y-Axis Labels
    private var yAxisLabels: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<5) { i in
                Text("\(String(format: "%.0f", maxValue - (maxValue - minValue) * Double(i) / 4)) kg")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(height: i < 4 ? 200 / 4 : 0, alignment: .top)
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Grid
    private func gridView(geometry: GeometryProxy) -> some View {
        ForEach(0..<5) { i in
            let y = geometry.size.height * CGFloat(i) / 4
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
            .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
        }
    }
    
    // MARK: - Gradient Area
    private func gradientArea(geometry: GeometryProxy) -> some View {
        Path { path in
            guard !data.isEmpty else { return }
            
            let points = calculatePoints(in: geometry)
            
            path.move(to: CGPoint(x: points[0].x, y: geometry.size.height))
            path.addLine(to: points[0])
            
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            
            path.addLine(to: CGPoint(x: points.last!.x, y: geometry.size.height))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .opacity(showAnimation ? 1 : 0)
    }
    
    // MARK: - Line Chart
    private func lineChart(geometry: GeometryProxy) -> some View {
        Path { path in
            guard !data.isEmpty else { return }
            
            let points = calculatePoints(in: geometry)
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .trim(from: 0, to: showAnimation ? 1 : 0)
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    // MARK: - Points
    private func pointsView(geometry: GeometryProxy) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, _ in
            let point = calculatePoint(at: index, in: geometry)
            
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: selectedPoint == index ? 12 : 8, height: selectedPoint == index ? 12 : 8)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: selectedPoint == index ? 12 : 8, height: selectedPoint == index ? 12 : 8)
            }
            .position(point)
            .scaleEffect(showAnimation ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.05), value: showAnimation)
        }
    }
    
    // MARK: - Tooltip
    private func tooltipView(for index: Int, geometry: GeometryProxy) -> some View {
        let point = calculatePoint(at: index, in: geometry)
        let dataPoint = data[index]
        
        return VStack(spacing: 4) {
            Text(dateFormatter.string(from: dataPoint.0))
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(String(format: "%.1f", dataPoint.1)) kg")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4)
        )
        .position(x: point.x, y: max(point.y - 40, 30))
    }
    
    // MARK: - Date Axis
    private var dateAxisView: some View {
        HStack {
            if let first = data.first {
                Text(dateFormatter.string(from: first.0))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if data.count > 2, let middle = data[safe: data.count / 2] {
                Text(dateFormatter.string(from: middle.0))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let last = data.last {
                Text(dateFormatter.string(from: last.0))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calculatePoints(in geometry: GeometryProxy) -> [CGPoint] {
        data.enumerated().map { index, point in
            calculatePoint(at: index, in: geometry)
        }
    }
    
    private func calculatePoint(at index: Int, in geometry: GeometryProxy) -> CGPoint {
        let x = geometry.size.width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
        let normalizedValue = (data[index].1 - minValue) / valueRange
        let y = geometry.size.height * (1 - CGFloat(normalizedValue))
        return CGPoint(x: x, y: y)
    }
    
    private func updateSelectedPoint(at location: CGPoint, in width: CGFloat) {
        guard !data.isEmpty else { return }
        
        let index = Int(round(location.x / width * CGFloat(data.count - 1)))
        selectedPoint = min(max(index, 0), data.count - 1)
    }
    
    private func calculateProgression() -> Double? {
        guard data.count >= 2,
              let first = data.first?.1,
              let last = data.last?.1,
              first > 0 else { return nil }
        
        return ((last - first) / first) * 100
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progression positive
                LineChartView(
                    data: generateProgressionData(
                        startValue: 60,
                        endValue: 80,
                        numberOfPoints: 8
                    ),
                    exercice: "Développé Couché"
                )
                .frame(height: 300)
                
                // Progression négative
                LineChartView(
                    data: generateProgressionData(
                        startValue: 100,
                        endValue: 85,
                        numberOfPoints: 10
                    ),
                    exercice: "Squat"
                )
                .frame(height: 300)
                
                // Progression stable avec variations
                LineChartView(
                    data: generateProgressionData(
                        startValue: 50,
                        endValue: 52,
                        numberOfPoints: 12,
                        variance: 5
                    ),
                    exercice: "Curl Biceps"
                )
                .frame(height: 300)
                
                // Progression rapide
                LineChartView(
                    data: generateProgressionData(
                        startValue: 40,
                        endValue: 70,
                        numberOfPoints: 6
                    ),
                    exercice: "Soulevé de Terre"
                )
                .frame(height: 300)
                
                // Peu de données
                LineChartView(
                    data: generateProgressionData(
                        startValue: 30,
                        endValue: 35,
                        numberOfPoints: 3
                    ),
                    exercice: "Extensions Triceps"
                )
                .frame(height: 300)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // Helper pour générer des données de test
    static func generateProgressionData(
        startValue: Double,
        endValue: Double,
        numberOfPoints: Int,
        variance: Double = 3
    ) -> [(Date, Double)] {
        let calendar = Calendar.current
        let today = Date()
        let increment = (endValue - startValue) / Double(numberOfPoints - 1)
        
        return (0..<numberOfPoints).map { index in
            let date = calendar.date(byAdding: .day, value: -((numberOfPoints - 1 - index) * 7), to: today)!
            let baseValue = startValue + (increment * Double(index))
            let randomVariance = Double.random(in: -variance...variance)
            let value = max(0, baseValue + randomVariance)
            
            return (date, value)
        }
    }
}
