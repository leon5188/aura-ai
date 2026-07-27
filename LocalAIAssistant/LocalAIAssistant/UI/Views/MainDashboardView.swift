//
//  MainDashboardView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Full-Screen Female AI Robot Hero Cover with Proactive Care & Emotional Resonance Physics
//

import SwiftUI

public struct MainDashboardView: View {
    @StateObject private var speechManager = SpeechRecognizerManager()
    @StateObject private var llmManager = LLMManager()
    @StateObject private var actionExecutor = SystemActionExecutor()
    @StateObject private var ttsManager = TTSSpeechManager.shared
    
    @State private var selectedTab: CyberTab = .home
    @State private var isThinking: Bool = false
    @State private var statusText: String = LocalizationHelper.initialStatusText
    
    // 情感物理色彩状态 (Cyan: 默认 / Gold: 欢快 / Purple: 沉思)
    @State private var emotionalGlowColor: Color = CyberTheme.electricCyan
    
    // 豆包风格对话历史
    @State private var chatMessages: [ChatMessageItem] = [
        ChatMessageItem(sender: .aura, text: "主人早上好！我是 AURA 端侧 AI 助手。今天天气晴朗，各项本地神经引擎均已就绪。有什么我可以帮您的？")
    ]
    
    private let robotImageURL = BundledMedia.heroPortraitURL
    private let waveGifURL = BundledMedia.voiceWaveformGIFURL
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // MARK: - 1. 赛博女机器人全屏沉浸式大背景 (含动态情感共鸣发光)
            ZStack {
                if let uiImage = UIImage(contentsOfFile: robotImageURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                } else {
                    CyberTheme.backgroundGradient
                        .ignoresSafeArea()
                }
                
                LinearGradient(
                    colors: [
                        Color.black.opacity(selectedTab == .home ? 0.35 : 0.88),
                        Color.black.opacity(selectedTab == .home ? 0.65 : 0.94)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: selectedTab)
            }
            
            // MARK: - 2. 前置全息情感声波、主动关怀与控制台
            VStack(spacing: 0) {
                switch selectedTab {
                case .chat:
                    ChatHistoryView(messages: $chatMessages) { userText in
                        processTextDirectly(userText)
                    }
                    .padding(.top, 40)
                    
                case .tools:
                    ToolsView(actionExecutor: actionExecutor)
                    
                case .profile:
                    ProfileView()
                    
                case .home, .aiCore:
                    Spacer()
                    
                    // 具备动态情感色彩共鸣声波物理系统
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(emotionalGlowColor.opacity(0.35))
                                .frame(width: 150, height: 65)
                                .blur(radius: 20)
                                .scaleEffect((speechManager.isListening || ttsManager.isSpeaking) ? 1.0 + CGFloat(speechManager.audioLevel) * 0.55 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: emotionalGlowColor)
                            
                            AnimatedGIFView(gifURL: waveGifURL, isPlaying: true)
                                .frame(width: 250, height: 70)
                                .blendMode(.screen)
                                .opacity((speechManager.isListening || ttsManager.isSpeaking) ? 0.95 : 0.75)
                                .scaleEffect((speechManager.isListening || ttsManager.isSpeaking) ? 1.0 + CGFloat(speechManager.audioLevel) * 0.4 : 1.0)
                        }
                        
                        Text(speechManager.recognizedText.isEmpty ? statusText : speechManager.recognizedText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(speechManager.isListening ? emotionalGlowColor : .white)
                            .shadow(color: .black, radius: 4)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .frame(height: 36)
                    }
                    .padding(.bottom, 6)
                    
                    if !llmManager.lastRawOutput.isEmpty {
                        ActionInspectorView(
                            rawOutput: llmManager.lastRawOutput,
                            parsedIntent: llmManager.lastParsedIntent
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }
                
                // 底部 3D 水晶按键 TabBar
                FloatingTabBar(
                    selectedTab: $selectedTab,
                    onMicTapped: toggleSpeechRecognition
                )
                .padding(.bottom, 14)
            }
        }
        .onAppear {
            speechManager.onSpeechEnded = { finalText in
                handleSpeechRecognitionComplete(text: finalText)
            }
            
            // 启动时触发温柔少女音主动语音关怀
            triggerProactiveWelcome()
        }
        .sheet(item: $actionExecutor.pendingEmailDraft) { draft in
            MailComposeView(draft: draft)
        }
        .sheet(item: $actionExecutor.pendingSMSDraft) { smsDraft in
            SMSComposeView(draft: smsDraft)
        }
    }
    
    // MARK: - Actions & Proactive Logic
    private func triggerProactiveWelcome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let welcome = "主人你好！我是 AURA 智能助手。本地神经引擎已就绪，今天有什么我可以帮您的吗？"
            ttsManager.speak(text: welcome)
        }
    }
    
    private func toggleSpeechRecognition() {
        if speechManager.isListening {
            speechManager.stopListening()
        } else {
            ttsManager.stop()
            statusText = LocalizationHelper.listeningStatusText
            speechManager.startListening()
        }
    }
    
    private func handleSpeechRecognitionComplete(text: String) {
        guard !text.isEmpty else { return }
        
        chatMessages.append(ChatMessageItem(sender: .user, text: text))
        statusText = LocalizationHelper.thinkingStatusText
        isThinking = true
        
        // 动态调整情感色彩共鸣
        updateEmotionalGlow(for: text)
        
        llmManager.processUserSpeech(text) { intent in
            isThinking = false
            if let intent = intent {
                let responseSpeech = LocalizationHelper.generateResponseSpeech(for: intent)
                statusText = responseSpeech
                chatMessages.append(ChatMessageItem(sender: .aura, text: responseSpeech))
                
                ttsManager.speak(text: responseSpeech)
                actionExecutor.execute(intent: intent)
            } else {
                let fallback = LocalizationHelper.unknownInstructionText
                statusText = fallback
                chatMessages.append(ChatMessageItem(sender: .aura, text: fallback))
                ttsManager.speak(text: fallback)
            }
        }
    }
    
    private func processTextDirectly(_ text: String) {
        chatMessages.append(ChatMessageItem(sender: .user, text: text))
        updateEmotionalGlow(for: text)
        
        llmManager.processUserSpeech(text) { intent in
            if let intent = intent {
                let responseSpeech = LocalizationHelper.generateResponseSpeech(for: intent)
                statusText = responseSpeech
                chatMessages.append(ChatMessageItem(sender: .aura, text: responseSpeech))
                ttsManager.speak(text: responseSpeech)
                actionExecutor.execute(intent: intent)
            }
        }
    }
    
    private func updateEmotionalGlow(for text: String) {
        if text.contains("开心") || text.contains("棒") || text.contains("喜") {
            emotionalGlowColor = Color.yellow
        } else if text.contains("爱") || text.contains("喜欢") || text.contains("美") {
            emotionalGlowColor = CyberTheme.neonPurple
        } else {
            emotionalGlowColor = CyberTheme.electricCyan
        }
    }
}
