//
//  AddSerieButton.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI

struct AddSerieButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Ajouter une série")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(color: isPressed ? Color.blue.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct AddSerieButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AddSerieButton {
                print("Add serie tapped")
            }
            
            // In a container
            VStack(spacing: 16) {
                Text("Séries actuelles")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Mock series
                ForEach(0..<2) { index in
                    HStack {
                        Text("Série \(index + 1)")
                        Spacer()
                        Text("10 reps × 20kg")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                AddSerieButton {
                    print("Add serie")
                }
            }
            .padding()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Add Serie Button")
        
        // Dark mode
        AddSerieButton {
            print("Add serie")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark Mode")
    }
}
