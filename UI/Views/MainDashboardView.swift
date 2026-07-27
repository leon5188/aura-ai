//
//  MainDashboardView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Cyberpunk Glassmorphism UI Dashboard
//

import SwiftUI

public struct MainDashboardView: View {
    @StateObject private var speechManager = SpeechRecognizerManager()
    @StateObject private var llmManager = LLMManager()
    @StateObject private var actionExecutor = SystemActionExecutor()
    
    @State private var selectedTab: CyberTab = .home
    @State private var isThinking: Bool = false
    @State private var statusText: String = "点击下方麦克风开始说..."
    
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
                        
                        // MARK: - 2. 中央全息 AI 虚拟形象/光球
                        VStack(spacing: 12) {
                            HolographicAICoreView(
                                isListening: $speechManager.isListening,
                                isThinking: $isThinking,
                                audioLevel: speechManager.audioLevel
                            )
                            .frame(height: 200)
                            
                            Text(statusText)
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
                        
                        // MARK: - 4. 实时 JSON Function Calling 监控卡片
                        ActionInspectorView(
                            rawOutput: llmManager.lastRawOutput,
                            parsedIntent: llmManager.lastParsedIntent
                        )
                        .padding(.horizontal, 20)
                        
                        // MARK: - 5. 智能快捷功能网格 (Smart Actions)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SMART SHORTCUTS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.electricCyan)
                                .padding(.leading, 4)
                            
                            SmartShortcutCard(
                                icon: "phone.fill",
                                title: "拨打电话示例",
                                subtitle: "说：“帮我给张三打个电话”",
                                color: CyberTheme.electricCyan
                            ) {
                                triggerTestCommand("帮我给张三打个电话")
                            }
                            
                            SmartShortcutCard(
                                icon: "envelope.fill",
                                title: "撰写邮件示例",
                                subtitle: "说：“给李四发邮件，主题是开会”",
                                color: CyberTheme.neonPurple
                            ) {
                                triggerTestCommand("给李四发邮件，主题是开会，内容是下午两点三楼会议室")
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
        }
        // 绑定音频停顿完成回调
        .onAppear {
            speechManager.onSpeechEnded = { finalText in
                handleSpeechRecognitionComplete(text: finalText)
            }
        }
        // 弹窗提示与邮件草稿 Sheet 挂载
        .alert(item: Binding(
            get: { actionExecutor.alertMessage != nil ? AlertItem(message: actionExecutor.alertMessage!) : nil },
            set: { _ in actionExecutor.alertMessage = nil }
        )) { item in
            Alert(title: Text("本地 AI 助手"), message: Text(item.message), dismissButton: .default(Text("确定")))
        }
        .sheet(item: $actionExecutor.pendingEmailDraft) { draft in
            MailComposeView(draft: draft)
        }
    }
    
    // MARK: - Subviews: Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, Master")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("On-Device AI Engine Active")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(CyberTheme.electricCyan)
            }
            
            Spacer()
            
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
    
    // MARK: - Actions Logic
    private func toggleSpeechRecognition() {
        if speechManager.isListening {
            speechManager.stopListening()
        } else {
            statusText = "正在倾听中... 说出“给张三打电话”或“给李四发邮件”"
            speechManager.startListening()
        }
    }
    
    private func handleSpeechRecognitionComplete(text: String) {
        guard !text.isEmpty else { return }
        
        statusText = "端侧 LLM 正在推理解析意图..."
        isThinking = true
        
        llmManager.processUserSpeech(text) { intent in
            isThinking = false
            if let intent = intent {
                statusText = "解析成功！准备执行操作..."
                actionExecutor.execute(intent: intent)
            } else {
                statusText = "未能识别有效指令"
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
