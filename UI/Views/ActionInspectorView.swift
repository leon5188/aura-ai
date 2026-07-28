//
//  ActionInspectorView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Live JSON Function Calling Inspector Card & Hardware Telemetry
//

import SwiftUI

public struct ActionInspectorView: View {
    @ObservedObject private var langManager = LanguageManager.shared
    public var rawOutput: String
    public var parsedIntent: ParsedIntent?
    public var tokensPerSecond: Double
    public var latencyMs: Int
    public var ramUsageMB: Double
    
    public init(
        rawOutput: String,
        parsedIntent: ParsedIntent?,
        tokensPerSecond: Double = 36.4,
        latencyMs: Int = 380,
        ramUsageMB: Double = 1280.0
    ) {
        self.rawOutput = rawOutput
        self.parsedIntent = parsedIntent
        self.tokensPerSecond = tokensPerSecond
        self.latencyMs = latencyMs
        self.ramUsageMB = ramUsageMB
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header 状态与标题
            HStack {
                Image(systemName: "terminal.fill")
                    .foregroundColor(CyberTheme.electricCyan)
                Text(langManager.text(.inspectorTitle))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.electricCyan)
                
                Spacer()
                
                Text(langManager.text(.inspectorBadge))
                    .font(.system(size: 9, weight: .black))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(CyberTheme.royalBlue.opacity(0.4))
                    .cornerRadius(4)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(CyberTheme.cardBorder)
            
            // 硬核硬件与端侧推理 Telemetry 监视网格
            HStack(spacing: 8) {
                metricCell(title: "推理速率", value: String(format: "%.1f", tokensPerSecond) + " t/s", icon: "bolt.fill", color: CyberTheme.electricCyan)
                metricCell(title: "处理延时", value: "\(latencyMs) ms", icon: "timer", color: CyberTheme.neonPurple)
                metricCell(title: "内存占用", value: String(format: "%.0f", ramUsageMB) + " MB", icon: "memorychip", color: Color.green)
            }
            
            // 原始 JSON 输出控制台
            if rawOutput.isEmpty {
                Text(langManager.text(.inspectorPlaceholder))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                Text(rawOutput)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.6))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
            }
            
            // 解析意图卡片
            if let intent = parsedIntent {
                HStack(spacing: 8) {
                    Text("Action:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(intent.action.rawValue.uppercased())
                        .font(.caption.bold())
                        .foregroundColor(CyberTheme.electricCyan)
                    
                    if let target = intent.targetName {
                        Text("Target:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(target)
                            .font(.caption.bold())
                            .foregroundColor(CyberTheme.neonPurple)
                    }
                    
                    if let title = intent.title {
                        Text("Title:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(title)
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
    
    private func metricCell(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.3))
        .cornerRadius(6)
    }
}
