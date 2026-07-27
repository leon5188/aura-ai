//
//  AIRobotHeroView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Cyberpunk Female AI Android Hero View (The Main Avatar)
//

import SwiftUI

public struct AIRobotHeroView: View {
    @Binding public var isListening: Bool
    @Binding public var isThinking: Bool
    public var audioLevel: Float
    
    // 主角女机器人图片 (打包在 App Bundle 内)
    private let robotImageURL = BundledMedia.heroPortraitURL
    
    @State private var scanBeamOffset: CGFloat = -180
    @State private var glowOpacity: Double = 0.6
    
    public init(isListening: Binding<Bool>, isThinking: Binding<Bool>, audioLevel: Float) {
        self._isListening = isListening
        self._isThinking = isThinking
        self.audioLevel = audioLevel
    }
    
    public var body: some View {
        ZStack {
            CyberTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // MARK: - 1. 顶部主角标题与端侧算力标记
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(CyberTheme.electricCyan)
                                .frame(width: 8, height: 8)
                                .shadow(color: CyberTheme.electricCyan, radius: 4)
                            Text("AURA")
                                .font(.system(size: 26, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Text("ON-DEVICE AI ASSISTANT • 1.5B 4-BIT")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberTheme.electricCyan)
                    }
                    
                    Spacer()
                    
                    Text("100% PRIVACY")
                        .font(.system(size: 9, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(CyberTheme.royalBlue.opacity(0.4))
                        .cornerRadius(6)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // MARK: - 2. 中央女机器人主角卡片 (Hero Avatar Card)
                ZStack {
                    // 主角机器人大图
                    AsyncImage(url: robotImageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        if let uiImage = UIImage(contentsOfFile: robotImageURL.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 320, height: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        CyberTheme.electricCyan,
                                        CyberTheme.cardBorder,
                                        CyberTheme.neonPurple
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: CyberTheme.electricCyan.opacity(glowOpacity), radius: 25)
                    
                    // 全息扫光效果 (Scan Beam)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    CyberTheme.electricCyan.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 320, height: 20)
                        .offset(y: scanBeamOffset)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    // 状态环发光效果 (Voice Reactive Glow Overlay)
                    if isListening {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(CyberTheme.electricCyan, lineWidth: 4)
                            .scaleEffect(1.0 + CGFloat(audioLevel) * 0.05)
                            .opacity(Double(audioLevel) * 0.8 + 0.2)
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - 3. 主角对话状态
                Text(isListening ? "AURA 正在倾听您的指引..." : (isThinking ? "AURA 正在脑海推理解析..." : "我是 AURA，您的端侧智能助手。"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isListening ? CyberTheme.electricCyan : .white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            // 全息扫光动画
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: true)) {
                scanBeamOffset = 180
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.9
            }
        }
    }
}
