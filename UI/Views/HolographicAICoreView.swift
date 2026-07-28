//
//  HolographicAICoreView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Holographic Glowing AI Hologram & Audio-Reactive Shader Particle Animation
//

import SwiftUI

public struct HolographicAICoreView: View {
    @Binding public var isListening: Bool
    @Binding public var isThinking: Bool
    public var audioLevel: Float // 0.0 ~ 1.0 实时声音振幅
    
    @State private var rotationAngle: Double = 0
    @State private var innerRotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particlePhase: Double = 0
    
    public init(isListening: Binding<Bool>, isThinking: Binding<Bool>, audioLevel: Float) {
        self._isListening = isListening
        self._isThinking = isThinking
        self.audioLevel = audioLevel
    }
    
    public var body: some View {
        ZStack {
            // 最外层声波弥散晕层 (Audio Reactive Ambient Aura)
            Circle()
                .fill(currentCoreColor.opacity(0.18))
                .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.6 : pulseScale)
                .frame(width: 230, height: 230)
                .blur(radius: 30)
            
            // 外围 3D 极光粒子切片环
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [currentCoreColor.opacity(0.8), CyberTheme.royalBlue, currentCoreColor.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 180 + CGFloat(i * 18), height: 180 + CGFloat(i * 18))
                    .rotation3DEffect(.degrees(45 + Double(i * 30)), axis: (x: 1, y: 0.5, z: 0))
                    .rotationEffect(.degrees(rotationAngle * (i % 2 == 0 ? 1 : -1.2)))
                    .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.15 : 1.0)
            }
            
            // 虚线全息科技盘 (Dash Tech Ring)
            Circle()
                .stroke(CyberTheme.electricCyan, style: StrokeStyle(lineWidth: 1.8, dash: [8, 12]))
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-innerRotationAngle))
                .opacity(0.85)
            
            // 核心 3D 全息双层发光体 (Dynamic Glowing Core)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentCoreColor,
                                CyberTheme.royalBlue.opacity(0.9),
                                Color.black.opacity(0.95)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 65
                        )
                    )
                    .frame(width: 125, height: 125)
                    .shadow(color: currentCoreColor.opacity(0.9), radius: 30)
                
                // 内部核心 AI 图标与思考状态
                if isThinking {
                    VStack(spacing: 6) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.4)
                        Text("端侧推理中")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberTheme.electricCyan)
                    }
                } else {
                    Image(systemName: "cpu")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundColor(.white)
                        .shadow(color: currentCoreColor, radius: 12)
                }
            }
            .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.25 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: audioLevel)
        }
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                innerRotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.18
            }
        }
    }
    
    private var currentCoreColor: Color {
        if isThinking {
            return CyberTheme.neonPurple
        } else if isListening {
            return CyberTheme.electricCyan
        } else {
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        }
    }
}
