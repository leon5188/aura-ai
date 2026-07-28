//
//  ActionInspectorView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Real-Time JSON Inspector View (100% Match to f655351c61b901f311ba62c6b09c4c56.jpg 3D Crystal Glass)
//

import SwiftUI

public struct ActionInspectorView: View {
    public let rawOutput: String
    public let parsedIntent: ParsedIntent?
    
    public init(rawOutput: String, parsedIntent: ParsedIntent?) {
        self.rawOutput = rawOutput
        self.parsedIntent = parsedIntent
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(CyberTheme.electricCyan)
                Text("AI FUNCTION CALLING (JSON)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.electricCyan)
                Spacer()
                Text("ON-DEVICE")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(CyberTheme.electricCyan.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
            
            Text(rawOutput)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.9))
                .lineLimit(4)
                .padding(8)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(12)
        .pure3DGlassStyle(cornerRadius: 16) // 应用 100% 3D 立体水晶玻璃风格
    }
}
