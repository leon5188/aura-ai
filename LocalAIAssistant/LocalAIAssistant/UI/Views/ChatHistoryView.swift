//
//  ChatHistoryView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Doubao-style Interactive Chat Timeline View (iOS 17/18 Modern API)
//

import SwiftUI

public struct ChatMessageItem: Identifiable {
    public let id = UUID()
    public let sender: Sender
    public let text: String
    public let timestamp = Date()
    
    public enum Sender {
        case user
        case aura
    }
}

public struct ChatHistoryView: View {
    @Binding public var messages: [ChatMessageItem]
    public var onSendMessage: (String) -> Void
    
    @State private var inputText: String = ""
    
    public var body: some View {
        VStack(spacing: 0) {
            // 顶部 Cyber Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(CyberTheme.electricCyan)
                Text("AURA 实时对话流")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("端侧 100% 隐私加密")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(CyberTheme.electricCyan.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.4))
            
            // 对话气泡列表 (豆包风格)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(messages) { msg in
                            HStack(alignment: .top, spacing: 10) {
                                if msg.sender == .aura {
                                    Circle()
                                        .fill(CyberTheme.electricCyan.opacity(0.3))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "brain.head.profile")
                                                .font(.system(size: 14))
                                                .foregroundColor(CyberTheme.electricCyan)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(msg.text)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(red: 0.10, green: 0.16, blue: 0.30).opacity(0.85))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(CyberTheme.cardBorder, lineWidth: 1)
                                                    )
                                            )
                                    }
                                    Spacer(minLength: 40)
                                } else {
                                    Spacer(minLength: 40)
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(msg.text)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                LinearGradient(
                                                    colors: [CyberTheme.electricCyan, CyberTheme.royalBlue],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                            )
                                    }

                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 底部文本输入框
            HStack(spacing: 10) {
                TextField("与 AURA 对话或发送指令...", text: $inputText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                
                Button(action: {
                    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onSendMessage(trimmed)
                    inputText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(CyberTheme.electricCyan)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.6))
        }
    }
}
