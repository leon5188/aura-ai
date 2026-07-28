//
//  DynamicIslandWidgetView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Cyberpunk Dynamic Island Widget View
//

import SwiftUI
import ActivityKit

public struct DynamicIslandWidgetView: View {
    public let context: ActivityViewContext<AssistantActivityAttributes>
    
    public var body: some View {
        VStack(spacing: 12) {
            // 顶栏 Header
            HStack {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(CyberTheme.electricCyan.opacity(0.3))
                            .frame(width: 24, height: 24)
                        Image(systemName: "cpu")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(CyberTheme.electricCyan)
                    }
                    
                    Text("LOCAL AI")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(context.state.state.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(CyberTheme.neonPurple.opacity(0.35))
                    .cornerRadius(6)
                    .foregroundColor(CyberTheme.neonPurple)
            }
            
            // 中央识别文案与推理动作
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.recognizedText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let action = context.state.actionName {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(CyberTheme.electricCyan)
                        Text("ACTION: \(action.uppercased())")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberTheme.electricCyan)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)
            
            // 底栏 Telemetry 指标
            HStack {
                Text(String(format: "%.1f t/s", context.state.tokensPerSecond))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("RAM ~1.3GB")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color(red: 0.05, green: 0.07, blue: 0.16))
    }
}
