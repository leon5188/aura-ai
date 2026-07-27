//
//  SmartShortcutCard.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Action Grid Item
//

import SwiftUI

public struct SmartShortcutCard: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public let color: Color
    public let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(CyberTheme.electricCyan.opacity(0.6))
            }
            .padding(12)
            .glassCardStyle(cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
