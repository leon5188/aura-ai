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

// MARK: - 100% 还原参考图 13.34.40.png 的 3D 高彩液体水晶宝石修饰器 (加强立体折射版)
public struct LiquidGlassGemModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var isSelected: Bool = false

    public func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. 高彩饱和液体核心 (Rich Saturated Liquid Gem Core)
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
                                    Color(red: 0.22, green: 0.38, blue: 0.68).opacity(0.95),
                                    Color(red: 0.10, green: 0.18, blue: 0.40).opacity(0.9),
                                    Color(red: 0.03, green: 0.06, blue: 0.16).opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(.ultraThinMaterial)

                    // 2. 底部厚度暗角 — 模拟玻璃体积与光线衰减 (制造真实"立体感")
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .clear, Color.black.opacity(isSelected ? 0.28 : 0.45)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 3. 顶部弧面 3D 凸起水滴高光弧 (Top Specular Gloss Spotlight，更亮更集中)
                    VStack {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.98),
                                        Color.white.opacity(0.45),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: max(14, cornerRadius * 0.9))
                            .mask(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .padding(.top, 1)
                                    .padding(.horizontal, 2)
                            )
                        Spacer()
                    }

                    // 4. 左上角玻璃"折射光斑" (glint) — 让玻璃看起来真正凸起、有厚度
                    GeometryReader { geo in
                        Ellipse()
                            .fill(Color.white.opacity(0.55))
                            .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.4)
                            .blur(radius: geo.size.width * 0.12)
                            .offset(x: -geo.size.width * 0.10, y: -geo.size.height * 0.24)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .blendMode(.plusLighter)

                    // 5. 双色切割棱镜描边：左上亮、右下暗，制造真实厚度切边
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.98),
                                    Color.white.opacity(0.25),
                                    (isSelected ? CyberTheme.neonPurple : Color.black).opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.6
                        )

                    // 6. 内侧极细暗边，强化"切边厚度"
                    RoundedRectangle(cornerRadius: cornerRadius - 1.5, style: .continuous)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                        .padding(1.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: isSelected ? CyberTheme.electricCyan.opacity(0.9) : Color.black.opacity(0.55), radius: 16, x: 0, y: 9)
            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
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

// MARK: - 100% 对标 "iPhone Aesthetic" 高彩玻璃小图标 (App Icon Style Badge)
// 每个功能拥有独立品牌色渐变 + 顶部水滴高光弧 + 玻璃描边，取代原本单色 SF Symbol 平面图标
public enum IconPalette {
    public static let instagram: [Color] = [Color(red: 0.85, green: 0.25, blue: 0.55), Color(red: 0.55, green: 0.25, blue: 0.85)]
    public static let whatsapp: [Color]  = [Color(red: 0.35, green: 0.85, blue: 0.45), Color(red: 0.10, green: 0.55, blue: 0.28)]
    public static let facebook: [Color]  = [Color(red: 0.32, green: 0.56, blue: 0.98), Color(red: 0.12, green: 0.30, blue: 0.82)]
    public static let youtube: [Color]   = [Color(red: 0.98, green: 0.38, blue: 0.33), Color(red: 0.78, green: 0.12, blue: 0.12)]
    public static let skyBlue: [Color]   = [Color(red: 0.38, green: 0.78, blue: 0.99), Color(red: 0.16, green: 0.48, blue: 0.88)]
    public static let spotify: [Color]   = [Color(red: 0.38, green: 0.86, blue: 0.48), Color(red: 0.10, green: 0.55, blue: 0.28)]
    public static let sunGold: [Color]   = [Color(red: 1.00, green: 0.85, blue: 0.35), Color(red: 0.90, green: 0.62, blue: 0.10)]
    public static let purpleGem: [Color] = [Color(red: 0.68, green: 0.36, blue: 0.98), Color(red: 0.40, green: 0.16, blue: 0.72)]
    public static let orange: [Color]    = [Color(red: 1.00, green: 0.62, blue: 0.28), Color(red: 0.92, green: 0.36, blue: 0.12)]
    public static let teal: [Color]      = [Color(red: 0.22, green: 0.82, blue: 0.76), Color(red: 0.06, green: 0.55, blue: 0.55)]
    public static let indigo: [Color]    = [Color(red: 0.46, green: 0.42, blue: 0.96), Color(red: 0.26, green: 0.20, blue: 0.70)]
    public static let cyanBlue: [Color]  = [CyberTheme.electricCyan, CyberTheme.royalBlue]
    public static let pink: [Color]      = [Color(red: 0.98, green: 0.40, blue: 0.62), Color(red: 0.82, green: 0.16, blue: 0.48)]
    public static let slate: [Color]     = [Color(red: 0.58, green: 0.62, blue: 0.68), Color(red: 0.30, green: 0.34, blue: 0.40)]
    public static let crimson: [Color]   = [Color(red: 0.95, green: 0.32, blue: 0.38), Color(red: 0.68, green: 0.10, blue: 0.20)]
}

public struct GlossyIconBadge: View {
    public var systemName: String
    public var colors: [Color]
    public var size: CGFloat
    public var iconSize: CGFloat?
    public var cornerRadius: CGFloat?

    public init(_ systemName: String, colors: [Color], size: CGFloat = 34, iconSize: CGFloat? = nil, cornerRadius: CGFloat? = nil) {
        self.systemName = systemName
        self.colors = colors
        self.size = size
        self.iconSize = iconSize
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        let radius = cornerRadius ?? size * 0.32
        ZStack {
            // 1. 品牌渐变核心
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            // 2. 底部暗角厚度 — 制造凸起体积感
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, .clear, Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 3. 顶部水滴玻璃高光弧 (更亮更集中)
            VStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.95), Color.white.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: size * 0.46)
                    .padding(.horizontal, size * 0.05)
                    .padding(.top, size * 0.05)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))

            // 4. 左上角玻璃折射光斑 (glint)
            Ellipse()
                .fill(Color.white.opacity(0.65))
                .frame(width: size * 0.55, height: size * 0.4)
                .blur(radius: size * 0.14)
                .offset(x: -size * 0.14, y: -size * 0.22)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                .blendMode(.plusLighter)

            // 5. 双色切割棱镜描边：左上亮、右下暗
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.white.opacity(0.2), Color.black.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.0, size * 0.035)
                )

            Image(systemName: systemName)
                .font(.system(size: iconSize ?? size * 0.46, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.35), radius: 1.5, x: 0, y: 1)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .shadow(color: (colors.first ?? .black).opacity(0.55), radius: size * 0.24, x: 0, y: size * 0.13)
        .shadow(color: Color.black.opacity(0.3), radius: size * 0.05, x: 0, y: size * 0.03)
    }
}
