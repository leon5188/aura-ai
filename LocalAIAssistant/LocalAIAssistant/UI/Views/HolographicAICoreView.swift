//
//  HolographicAICoreView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Holographic Cyber Robotic Avatar Core View
//

import SwiftUI
import AVFoundation

public struct HolographicAICoreView: View {
    @Binding public var isListening: Bool
    @Binding public var isThinking: Bool
    public var audioLevel: Float // 0.0 ~ 1.0 实时声音振幅
    
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    // 女机器人主角图片 (打包在 App Bundle 内)
    private let robotImageURL = BundledMedia.heroPortraitURL
    
    public init(isListening: Binding<Bool>, isThinking: Binding<Bool>, audioLevel: Float) {
        self._isListening = isListening
        self._isThinking = isThinking
        self.audioLevel = audioLevel
    }
    
    public var body: some View {
        ZStack {
            // MARK: - 1. 外层霓虹发光环 (Outer Cyber Glow)
            Circle()
                .fill(CyberTheme.electricCyan.opacity(0.15))
                .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.45 : pulseScale)
                .frame(width: 230, height: 230)
                .blur(radius: 25)
            
            // 全息旋转刻度外环
            Circle()
                .stroke(CyberTheme.holographicGradient, lineWidth: 2)
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(rotationAngle))
                .opacity(0.7)
            
            // 虚线激光内环
            Circle()
                .stroke(CyberTheme.electricCyan, style: StrokeStyle(lineWidth: 1.5, dash: [6, 8]))
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(-rotationAngle * 1.5))
                .opacity(0.85)
            
            // MARK: - 2. 核心主角女机器人全息头像 (AURA Cyber Android Core)
            ZStack {
                if let uiImage = UIImage(contentsOfFile: robotImageURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            isThinking ? CyberTheme.neonPurple : CyberTheme.electricCyan,
                                            CyberTheme.royalBlue
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                        )
                        .shadow(
                            color: isThinking ? CyberTheme.neonPurple.opacity(0.85) : CyberTheme.electricCyan.opacity(0.85),
                            radius: 20
                        )
                } else {
                    Circle()
                        .fill(CyberTheme.cardBackground)
                        .frame(width: 140, height: 140)
                }
                
                // 加载思考时的全息蒙层
                if isThinking {
                    Circle()
                        .fill(CyberTheme.neonPurple.opacity(0.3))
                        .frame(width: 140, height: 140)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.6)
                        )
                }
            }
            .scaleEffect(isListening ? 1.0 + CGFloat(audioLevel) * 0.25 : 1.0)
        }
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
        }
    }
}
