//
//  MainDashboardView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Cyberpunk Glassmorphism UI Dashboard
//

import SwiftUI

public struct MainDashboardView: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @StateObject private var speechManager = SpeechRecognizerManager()
    @StateObject private var llmManager = LLMManager()
    @StateObject private var actionExecutor = SystemActionExecutor()
    @StateObject private var ttsManager = TextToSpeechManager.shared
    @StateObject private var wakeWordDetector = WakeWordDetectorManager.shared
    @StateObject private var liveActivityManager = LiveActivityManager.shared
    
    @State private var selectedTab: CyberTab = .home
    @State private var isThinking: Bool = false
    @State private var statusText: String = ""
    @State private var pendingConfirmationIntent: ParsedIntent? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 背景深空渐变
            CyberTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 1. 顶部 Header 状态栏
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // MARK: - 2. 中央全息 AI 虚拟形象/光球 (Audio Reactive Particle Core)
                        VStack(spacing: 12) {
                            HolographicAICoreView(
                                isListening: $speechManager.isListening,
                                isThinking: $isThinking,
                                audioLevel: speechManager.audioLevel
                            )
                            .frame(height: 200)
                            
                            Text(currentStatusText)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(speechManager.isListening ? CyberTheme.electricCyan : .gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        .padding(.top, 10)
                        
                        // MARK: - 3. 实时语音转文本对话气泡 (Live Speech Bubble)
                        if !speechManager.recognizedText.isEmpty {
                            HStack {
                                Image(systemName: "mic.bubble.fill")
                                    .foregroundColor(CyberTheme.electricCyan)
                                Text(speechManager.recognizedText)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .glassCardStyle(cornerRadius: 16)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // MARK: - 4. 实时 JSON Function Calling & Telemetry 监控卡片
                        ActionInspectorView(
                            rawOutput: llmManager.lastRawOutput,
                            parsedIntent: llmManager.lastParsedIntent,
                            tokensPerSecond: llmManager.tokensPerSecond,
                            latencyMs: llmManager.latencyMs,
                            ramUsageMB: llmManager.ramUsageMB
                        )
                        .padding(.horizontal, 20)
                        
                        // MARK: - 5. 智能快捷功能网格 (Smart Actions)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(langManager.text(.smartShortcutsTitle))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.electricCyan)
                                .padding(.leading, 4)
                            
                            SmartShortcutCard(
                                icon: "phone.fill",
                                title: langManager.text(.callDemoTitle),
                                subtitle: langManager.text(.callDemoSub),
                                color: CyberTheme.electricCyan
                            ) {
                                triggerTestCommand(langManager.text(.callDemoCmd))
                            }
                            
                            SmartShortcutCard(
                                icon: "envelope.fill",
                                title: langManager.text(.emailDemoTitle),
                                subtitle: langManager.text(.emailDemoSub),
                                color: CyberTheme.neonPurple
                            ) {
                                triggerTestCommand(langManager.text(.emailDemoCmd))
                            }
                            
                            SmartShortcutCard(
                                icon: "bell.fill",
                                title: "提醒事项示例",
                                subtitle: "创建离线系统提醒",
                                color: Color.green
                            ) {
                                triggerTestCommand("提醒我晚上八点开会")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 90)
                    }
                }
            }
            
            // MARK: - 6. 底部悬浮胶囊 TabBar
            VStack {
                Spacer()
                FloatingTabBar(
                    selectedTab: $selectedTab,
                    onMicTapped: toggleSpeechRecognition
                )
                .padding(.bottom, 10)
            }
            
            // MARK: - 7. 科技感操作安全确认卡片 Overlay Modal
            if let confirmationIntent = pendingConfirmationIntent {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        pendingConfirmationIntent = nil
                    }
                
                ActionConfirmationCard(
                    intent: confirmationIntent,
                    onConfirm: {
                        let targetIntent = confirmationIntent
                        pendingConfirmationIntent = nil
                        liveActivityManager.updateState(state: .executing, text: "正在执行: \(targetIntent.action.rawValue)", tps: llmManager.tokensPerSecond, actionName: targetIntent.action.rawValue)
                        actionExecutor.execute(intent: targetIntent)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            liveActivityManager.endActivity()
                        }
                    },
                    onCancel: {
                        pendingConfirmationIntent = nil
                        liveActivityManager.endActivity()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        // 绑定音频停顿完成与唤醒词回调
        .onAppear {
            speechManager.onSpeechEnded = { finalText in
                handleSpeechRecognitionComplete(text: finalText)
            }
            
            // 配置唤醒词监控
            wakeWordDetector.onWakeWordDetected = { keyword in
                if !speechManager.isListening {
                    statusText = "已唤醒：检测到'\(keyword)'"
                    toggleSpeechRecognition()
                }
            }
            wakeWordDetector.startDetection()
        }
        // 弹窗提示与邮件草稿 Sheet 挂载
        .alert(item: Binding(
            get: { actionExecutor.alertMessage != nil ? AlertItem(message: actionExecutor.alertMessage!) : nil },
            set: { _ in actionExecutor.alertMessage = nil }
        )) { item in
            Alert(
                title: Text(langManager.text(.alertTitle)),
                message: Text(item.message),
                dismissButton: .default(Text(langManager.text(.alertOK)))
            )
        }
        .sheet(item: $actionExecutor.pendingEmailDraft) { draft in
            MailComposeView(draft: draft)
        }
    }
    
    // 状态文案计算
    private var currentStatusText: String {
        if !statusText.isEmpty {
            return statusText
        }
        return langManager.text(.statusDefault)
    }
    
    // MARK: - Subviews: Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(langManager.text(.headerTitle))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if wakeWordDetector.isListeningForWakeWord {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(CyberTheme.electricCyan)
                                .frame(width: 6, height: 6)
                            Text("喊'小助手'唤醒")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(CyberTheme.electricCyan)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(CyberTheme.electricCyan.opacity(0.15))
                        .cornerRadius(6)
                    }
                }
                
                Text(langManager.text(.headerSubtitle))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(CyberTheme.electricCyan)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // 一键语言控制切换按键 (Language Switch Control Button)
                Button(action: {
                    langManager.toggleLanguage()
                    if !speechManager.isListening && !isThinking {
                        statusText = langManager.text(.statusDefault)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(CyberTheme.electricCyan)
                        Text(langManager.currentLanguage.buttonTitle)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .glassCardStyle(cornerRadius: 12)
                }
                
                // 模型规格与资源状态 Badge
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("1.5B 4-bit")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Text("RAM ~1.3GB")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassCardStyle(cornerRadius: 12)
            }
        }
    }
    
    // MARK: - Actions Logic
    private func toggleSpeechRecognition() {
        if speechManager.isListening {
            speechManager.stopListening()
            statusText = langManager.text(.statusDefault)
            liveActivityManager.endActivity()
        } else {
            ttsManager.stop()
            statusText = langManager.text(.statusListening)
            speechManager.startListening()
            liveActivityManager.startActivity(initialText: "正在倾听指令...")
        }
    }
    
    private func handleSpeechRecognitionComplete(text: String) {
        guard !text.isEmpty else { return }
        
        // 如果包含唤醒词且没有其他操作，进行唤醒词二次校验
        wakeWordDetector.processAudioText(text)
        
        statusText = langManager.text(.statusThinking)
        isThinking = true
        liveActivityManager.updateState(state: .thinking, text: "正在端侧推理...", tps: llmManager.tokensPerSecond)
        
        llmManager.processUserSpeech(text) { intent in
            isThinking = false
            if let intent = intent {
                statusText = langManager.text(.statusSuccess)
                if intent.action == .unknown {
                    liveActivityManager.updateState(state: .executing, text: intent.reply ?? "意图完成", tps: llmManager.tokensPerSecond)
                    actionExecutor.execute(intent: intent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        liveActivityManager.endActivity()
                    }
                } else {
                    liveActivityManager.updateState(state: .executing, text: "确认操作: \(intent.action.rawValue)", tps: llmManager.tokensPerSecond, actionName: intent.action.rawValue)
                    withAnimation(.spring()) {
                        pendingConfirmationIntent = intent
                    }
                }
            } else {
                statusText = langManager.text(.statusFailed)
                liveActivityManager.endActivity()
            }
        }
    }
    
    private func triggerTestCommand(_ command: String) {
        speechManager.recognizedText = command
        handleSpeechRecognitionComplete(text: command)
    }
}

// 辅助 Alert 数据结构
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
