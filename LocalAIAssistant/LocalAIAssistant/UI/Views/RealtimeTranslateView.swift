//
//  RealtimeTranslateView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Real-Time Simultaneous Translation Console & Bilingual Subtitles (Speech-to-Speech & 3D Crystal Glass)
//

import SwiftUI

public struct RealtimeTranslateView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var translationEngine = RealtimeTranslationEngine.shared
    @StateObject private var speechManager = SpeechRecognizerManager()
    
    @State private var inputText: String = ""
    @State private var isListeningToTranslate: Bool = false
    
    private let siriGifURL = BundledMedia.siriWaveformGIFURL
    
    public var body: some View {
        ZStack {
            CyberTheme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "character.bubble.fill")
                            .foregroundColor(CyberTheme.electricCyan)
                        Text("AURA 同声传译 (中英实时互译)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                // 2. 双语高清晰同传字幕卡片列表 (100% 3D 立体水晶玻璃卡片)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(translationEngine.translationHistory) { item in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(item.sourceLanguage)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(CyberTheme.electricCyan)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(CyberTheme.neonPurple)
                                        Text(item.targetLanguage)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(CyberTheme.neonPurple)
                                        Spacer()
                                        
                                        // 重复朗读按钮
                                        Button(action: {
                                            TTSSpeechManager.shared.speak(text: item.translatedText)
                                        }) {
                                            Image(systemName: "speaker.wave.2.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(CyberTheme.electricCyan)
                                        }
                                    }
                                    
                                    // 语音原文 (大字号清晰展示)
                                    Text(item.originalText)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Rectangle()
                                        .fill(LinearGradient(colors: [CyberTheme.electricCyan.opacity(0.6), .clear], startPoint: .leading, endPoint: .trailing))
                                        .frame(height: 1)
                                    
                                    // 译文 (突出高亮)
                                    Text(item.translatedText)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(CyberTheme.electricCyan)
                                }
                                .padding(16)
                                .pure3DGlassStyle(cornerRadius: 18)
                                .id(item.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .onChange(of: translationEngine.translationHistory.count) { _, _ in
                        if let lastId = translationEngine.translationHistory.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }
                
                // 3. 同声传译语音 & 文本双控制台
                VStack(spacing: 10) {
                    // 语音同传控制按钮
                    Button(action: toggleTranslationListening) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(CyberTheme.electricCyan.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                
                                AnimatedGIFView(gifURL: siriGifURL, isPlaying: true)
                                    .frame(width: 38, height: 38)
                                    .clipShape(Circle())
                            }
                            
                            Text(isListeningToTranslate ? "正在同声监听中... 点击完成" : "点击开启实时语音同传")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isListeningToTranslate ? CyberTheme.electricCyan : .white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .pure3DGlassStyle(cornerRadius: 24, isSelected: isListeningToTranslate)
                    }
                    
                    // 文本辅助输入同传
                    HStack(spacing: 10) {
                        TextField("或在此输入任意中英文短句同传...", text: $inputText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                        
                        Button(action: {
                            let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            inputText = ""
                            
                            performTranslation(text: trimmed)
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(CyberTheme.electricCyan)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.8))
            }
        }
        .onAppear {
            speechManager.onSpeechEnded = { finalText in
                if isListeningToTranslate {
                    isListeningToTranslate = false
                    performTranslation(text: finalText)
                }
            }
        }
    }
    
    private func toggleTranslationListening() {
        HapticFeedbackManager.shared.impactMedium()
        if speechManager.isListening {
            speechManager.stopListening()
            isListeningToTranslate = false
        } else {
            TTSSpeechManager.shared.stop()
            isListeningToTranslate = true
            speechManager.startListening()
        }
    }
    
    private func performTranslation(text: String) {
        translationEngine.translate(text: text) { res in
            TTSSpeechManager.shared.speak(text: res.translatedText)
        }
    }
}
