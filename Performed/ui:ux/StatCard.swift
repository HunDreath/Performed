//
//  StatCard.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    var icon: String? = nil
    var subtitle: String? = nil
    var trend: TrendType? = nil
    var style: CardStyle = .default
    
    @State private var isAnimating = false
    
    enum TrendType {
        case up(String)
        case down(String)
        case neutral(String)
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .orange
            }
        }
        
        var text: String {
            switch self {
            case .up(let value), .down(let value), .neutral(let value):
                return value
            }
        }
    }
    
    enum CardStyle {
        case `default`
        case compact
        case detailed
        case gradient
    }
    
    var body: some View {
        Group {
            switch style {
            case .default:
                defaultStyle
            case .compact:
                compactStyle
            case .detailed:
                detailedStyle
            case .gradient:
                gradientStyle
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Default Style
    
    private var defaultStyle: some View {
        VStack(spacing: 12) {
            // Icon header
            if let icon = icon {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if let trend = trend {
                        trendBadge(trend)
                    }
                }
            }
            
            // Value
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
            
            // Title and subtitle
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Compact Style
    
    private var compactStyle: some View {
        HStack(spacing: 12) {
            // Icon
            if let icon = icon {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    if let trend = trend {
                        Text(trend.text)
                            .font(.caption)
                            .foregroundColor(trend.color)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    // MARK: - Detailed Style
    
    private var detailedStyle: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and trend
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(color.opacity(0.15))
                        )
                }
                
                Spacer()
                
                if let trend = trend {
                    trendBadge(trend)
                }
            }
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Value
            Text(value)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
            
            // Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar (decorative)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: isAnimating ? geometry.size.width * 0.7 : 0, height: 4)
                        .animation(.easeOut(duration: 1.0).delay(0.2), value: isAnimating)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Gradient Style
    
    private var gradientStyle: some View {
        VStack(spacing: 12) {
            // Icon
            if let icon = icon {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption2)
                            Text(trend.text)
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
            
            // Title and subtitle
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color,
                            color.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Trend Badge
    
    private func trendBadge(_ trend: TrendType) -> some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.caption2)
            Text(trend.text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(trend.color.opacity(0.15))
        )
        .foregroundColor(trend.color)
    }
}

// MARK: - Convenience Initializers

extension StatCard {
    // Simple card without extras
    init(title: String, value: String, color: Color) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = nil
        self.subtitle = nil
        self.trend = nil
        self.style = .default
    }
    
    // Card with icon
    init(title: String, value: String, color: Color, icon: String) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
        self.subtitle = nil
        self.trend = nil
        self.style = .default
    }
    
    // Full featured card
    init(title: String, value: String, color: Color, icon: String, subtitle: String, trend: TrendType, style: CardStyle = .default) {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
        self.subtitle = subtitle
        self.trend = trend
        self.style = style
    }
}

// MARK: - Preview

struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Default style
                Text("Default Style")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    StatCard(
                        title: "Séances",
                        value: "42",
                        color: .blue,
                        icon: "dumbbell.fill",
                        subtitle: "Ce mois",
                        trend: .up("+12%"),
                        style: .default
                    )
                    
                    StatCard(
                        title: "Exercices",
                        value: "156",
                        color: .green,
                        icon: "list.bullet",
                        subtitle: "Total",
                        trend: .up("+5%"),
                        style: .default
                    )
                }
                .padding(.horizontal)
                
                // Compact style
                Text("Compact Style")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    StatCard(
                        title: "Poids total soulevé",
                        value: "2.5k kg",
                        color: .orange,
                        icon: "scalemass.fill",
                        subtitle: "",
                        trend: .up("+8%"),
                        style: .compact
                    )
                    
                    StatCard(
                        title: "Temps d'entraînement",
                        value: "24h",
                        color: .purple,
                        icon: "clock.fill",
                        subtitle: "",
                        trend: .neutral("0%"),
                        style: .compact
                    )
                }
                .padding(.horizontal)
                
                // Detailed style
                Text("Detailed Style")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                StatCard(
                    title: "Record personnel",
                    value: "120 kg",
                    color: .red,
                    icon: "trophy.fill",
                    subtitle: "Développé couché",
                    trend: .up("+5 kg"),
                    style: .detailed
                )
                .padding(.horizontal)
                
                // Gradient style
                Text("Gradient Style")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    StatCard(
                        title: "Streak",
                        value: "7",
                        color: .orange,
                        icon: "flame.fill",
                        subtitle: "jours",
                        trend: .up("+2"),
                        style: .gradient
                    )
                    
                    StatCard(
                        title: "Niveau",
                        value: "12",
                        color: .indigo,
                        icon: "star.fill",
                        subtitle: "Intermédiaire",
                        trend: .up("+1"),
                        style: .gradient
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
