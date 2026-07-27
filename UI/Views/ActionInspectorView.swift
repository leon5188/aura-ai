//
//  ActionInspectorView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Live JSON Function Calling Inspector Card
//

import SwiftUI

public struct ActionInspectorView: View {
    public var rawOutput: String
    public var parsedIntent: ParsedIntent?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "terminal.fill")
                    .foregroundColor(CyberTheme.electricCyan)
                Text("AI FUNCTION CALLING (JSON)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.electricCyan)
                
                Spacer()
                
                Text("ON-DEVICE")
                    .font(.system(size: 9, weight: .black))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(CyberTheme.royalBlue.opacity(0.4))
                    .cornerRadius(4)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(CyberTheme.cardBorder)
            
            if rawOutput.isEmpty {
                Text("// 等待语音指令或模型输出...")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                Text(rawOutput)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.6))
                    .padding(8)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
            }
            
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
                }
            }
        }
        .padding(14)
        .glassCardStyle(cornerRadius: 16)
    }
}
