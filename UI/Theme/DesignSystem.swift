//
//  DesignSystem.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Design Style: Cyberpunk Blue Holographic Glow & Glassmorphism
//

import SwiftUI

public enum CyberTheme {
    // MARK: - Colors
    public static let backgroundDark = Color(red: 0.03, green: 0.05, blue: 0.10)       // #080C19
    public static let cardBackground = Color(red: 0.07, green: 0.11, blue: 0.22).opacity(0.65) // #121C38 @ 65%
    public static let cardBorder = Color(red: 0.20, green: 0.45, blue: 0.95).opacity(0.35)     // #3373F2 Glow Border
    
    // Neon Accents
    public static let electricCyan = Color(red: 0.00, green: 0.94, blue: 1.00)        // #00F0FF
    public static let royalBlue = Color(red: 0.23, green: 0.51, blue: 0.96)           // #3A82F6
    public static let neonPurple = Color(red: 0.66, green: 0.33, blue: 0.97)          // #A855F7
    
    // Gradients
    public static let holographicGradient = LinearGradient(
        colors: [electricCyan, royalBlue, neonPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.03, blue: 0.07),
            Color(red: 0.05, green: 0.08, blue: 0.16),
            Color(red: 0.02, green: 0.04, blue: 0.09)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Glassmorphism View Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(CyberTheme.cardBackground)
                    .background(.ultraThinMaterial.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                CyberTheme.electricCyan.opacity(0.6),
                                CyberTheme.cardBorder,
                                CyberTheme.neonPurple.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: borderWidth
                    )
            )
            .shadow(color: CyberTheme.electricCyan.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

extension View {
    public func glassCardStyle(cornerRadius: CGFloat = 20, borderWidth: CGFloat = 1.0) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, borderWidth: borderWidth))
    }
}
