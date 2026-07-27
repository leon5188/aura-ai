//
//  HolographicAICoreView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Holographic Glowing AI Hologram & Pulse Animation
//

import SwiftUI

public struct HolographicAICoreView: View {
    @Binding public var isListening: Bool
    @Binding public var isThinking: Bool
    public var audioLevel: Float // 0.0 ~ 1.0 实时声音振幅
    
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    public init(isListening: Binding<Bool>, isThinking: Binding<Bool>, audioLevel: Float) {
        self._isListening = isListening
        self._isThinking = isThinking
        self.audioLevel = audioLevel
    }
    
    public var body: some View {
        ZStack {
            // 背景多重外层发光环 (Outer Glow Rings)
            Circle()
                .fill(CyberTheme.electricCyan.opacity(0.12))
                .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.4 : pulseScale)
                .frame(width: 220, height: 220)
                .blur(radius: 20)
            
            Circle()
                .stroke(CyberTheme.holographicGradient, lineWidth: 2)
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(rotationAngle))
                .opacity(0.6)
            
            Circle()
                .stroke(CyberTheme.electricCyan, style: StrokeStyle(lineWidth: 1.5, dash: [6, 8]))
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-rotationAngle * 1.5))
                .opacity(0.8)
            
            // 核心 3D 全息光球 (Holographic Core)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isThinking ? CyberTheme.neonPurple : CyberTheme.electricCyan,
                                CyberTheme.royalBlue,
                                CyberTheme.backgroundDark
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: isThinking ? CyberTheme.neonPurple.opacity(0.8) : CyberTheme.electricCyan.opacity(0.8), radius: 25)
                
                // AI Core 状态图标或立体波纹
                if isThinking {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: "cpu")
                        .font(.system(size: 42, weight: .thin))
                        .foregroundColor(.white)
                        .shadow(color: CyberTheme.electricCyan, radius: 10)
                }
            }
            .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.2 : 1.0)
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
        }
    }
}
