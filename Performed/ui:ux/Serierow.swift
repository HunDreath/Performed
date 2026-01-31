//
//  SerieRow.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct SerieRow: View {
    let index: Int
    @Binding var serie: Serie
    let canDelete: Bool
    let onDelete: () -> Void
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case reps, weight
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with serie number and delete button
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Série \(index + 1)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Input fields
            HStack(spacing: 12) {
                // Repetitions field
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text("Répétitions")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("10", value: Binding(
                            get: { serie.repetitions.first ?? 0 },
                            set: { serie.repetitions = [$0] }
                        ), format: .number)
                        .keyboardType(.numberPad)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            focusedField == .reps ? Color.blue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        )
                        .focused($focusedField, equals: .reps)
                        
                        Text("reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Weight field
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text("Poids")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "scalemass.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("20", value: Binding(
                            get: { serie.poids.first ?? 0 },
                            set: { serie.poids = [$0] }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            focusedField == .weight ? Color.orange : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        )
                        .focused($focusedField, equals: .weight)
                        
                        Text("kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(.separator).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct SerieRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Single serie
            SerieRow(
                index: 0,
                serie: .constant(Serie(repetitions: [10], poids: [20])),
                canDelete: false,
                onDelete: {}
            )
            
            // Serie with delete button
            SerieRow(
                index: 1,
                serie: .constant(Serie(repetitions: [12], poids: [25])),
                canDelete: true,
                onDelete: { print("Delete tapped") }
            )
            
            // Heavy weight serie
            SerieRow(
                index: 2,
                serie: .constant(Serie(repetitions: [6], poids: [100])),
                canDelete: true,
                onDelete: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Serie Rows")
        
        // Dark mode
        VStack(spacing: 16) {
            SerieRow(
                index: 0,
                serie: .constant(Serie(repetitions: [10], poids: [20])),
                canDelete: true,
                onDelete: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark Mode")
    }
}
