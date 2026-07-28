//
//  DesignSystem.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  100% Match to 13.34.40.png High-Color 3D Liquid Glass Gem System
//

import SwiftUI

public enum CyberTheme {
    // MARK: - Colors
    public static let backgroundDark = Color(red: 0.03, green: 0.05, blue: 0.10)       // #080C19
    public static let cardBackground = Color.white.opacity(0.18)                        // 高透水晶底色
    public static let cardBorder = Color.white.opacity(0.70)                            // 高光晶莹边框

    // Neon Accents
    public static let electricCyan = Color(red: 0.00, green: 0.94, blue: 1.00)        // #00F0FF
    public static let royalBlue = Color(red: 0.23, green: 0.51, blue: 0.96)           // #3A82F6
    public static let neonPurple = Color(red: 0.66, green: 0.33, blue: 0.97)          // #A855F7

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

// MARK: - 100% 还原参考图 13.34.40.png 的 3D 高彩液体水晶宝石修饰器
public struct LiquidGlassGemModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var isSelected: Bool = false

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. 100% 对标 13.34.40.png 的高彩饱和液体核心 (Rich Saturated Liquid Gem Core)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [
                                    CyberTheme.electricCyan,
                                    CyberTheme.royalBlue,
                                    CyberTheme.neonPurple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.28, blue: 0.55).opacity(0.85),
                                    Color(red: 0.06, green: 0.14, blue: 0.32).opacity(0.65)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(.thinMaterial)

                    // 2. 顶部弧面 3D 凸起水滴高光弧 (Top Specular Gloss Spotlight)
                    VStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.92),
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 16)
                            .mask(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .padding(.top, 1)
                                    .padding(.horizontal, 2)
                            )
                        Spacer()
                    }

                    // 3. 内部高光发光微边
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.85),
                                    Color.white.opacity(0.2),
                                    CyberTheme.electricCyan.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: isSelected ? CyberTheme.electricCyan.opacity(0.8) : Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 全局导出 GlossyIceGlassTile
public struct GlossyIceGlassTile<Content: View>: View {
    public var isSelected: Bool
    public var content: Content

    public init(isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    public var body: some View {
        content
            .frame(width: 56, height: 56)
            .modifier(LiquidGlassGemModifier(cornerRadius: 18, isSelected: isSelected))
    }
}

extension View {
    public func pure3DGlassStyle(cornerRadius: CGFloat = 20, isSelected: Bool = false) -> some View {
        self.modifier(LiquidGlassGemModifier(cornerRadius: cornerRadius, isSelected: isSelected))
    }

    public func glassCardStyle(cornerRadius: CGFloat = 20, borderWidth: CGFloat = 1.0) -> some View {
        self.modifier(LiquidGlassGemModifier(cornerRadius: cornerRadius))
    }
}
