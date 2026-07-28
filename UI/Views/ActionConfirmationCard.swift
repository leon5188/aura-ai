//
//  ActionConfirmationCard.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Action Confirmation Modal Card
//

import SwiftUI

public struct ActionConfirmationCard: View {
    public let intent: ParsedIntent
    public var onConfirm: () -> Void
    public var onCancel: () -> Void
    
    @State private var isPulsing: Bool = false
    
    public init(intent: ParsedIntent, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.intent = intent
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // 头部警告/操作图标
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(CyberTheme.electricCyan.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                    
                    Image(systemName: actionIconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(CyberTheme.electricCyan)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("智能意图确认")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Text(actionTitle)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("AI 安全验证")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CyberTheme.neonPurple.opacity(0.3))
                    .cornerRadius(6)
                    .foregroundColor(CyberTheme.neonPurple)
            }
            
            Divider()
                .background(CyberTheme.cardBorder)
            
            // 操作详情卡片
            VStack(alignment: .leading, spacing: 8) {
                actionDetailRow(label: "动作类型:", value: intent.action.rawValue.uppercased())
                
                if let target = intent.targetName {
                    actionDetailRow(label: "目标人物:", value: target)
                }
                if let title = intent.title {
                    actionDetailRow(label: "内容主题:", value: title)
                }
                if let subject = intent.subject {
                    actionDetailRow(label: "邮件主题:", value: subject)
                }
                if let body = intent.body {
                    actionDetailRow(label: "详情说明:", value: body)
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
            
            // 操作控制按钮
            HStack(spacing: 14) {
                Button(action: {
                    triggerHapticFeedback()
                    onCancel()
                }) {
                    Text("取消")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHapticFeedback()
                    onConfirm()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("立即执行")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CyberTheme.electricCyan)
                    .cornerRadius(12)
                    .shadow(color: CyberTheme.electricCyan.opacity(0.6), radius: 8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.07, green: 0.10, blue: 0.22).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CyberTheme.electricCyan.opacity(0.5), lineWidth: 1.5)
                )
        )
        .shadow(color: CyberTheme.electricCyan.opacity(0.3), radius: 20)
        .padding(.horizontal, 24)
        .onAppear {
            isPulsing = true
        }
    }
    
    private func actionDetailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(CyberTheme.electricCyan)
            Spacer()
        }
    }
    
    private var actionTitle: String {
        switch intent.action {
        case .call: return "呼叫联系人"
        case .sendEmail: return "发送电子邮件"
        case .createReminder: return "创建提醒事项"
        case .createEvent: return "添加日历行程"
        case .unknown: return "未明意图处理"
        }
    }
    
    private var actionIconName: String {
        switch intent.action {
        case .call: return "phone.fill"
        case .sendEmail: return "envelope.fill"
        case .createReminder: return "bell.fill"
        case .createEvent: return "calendar"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
