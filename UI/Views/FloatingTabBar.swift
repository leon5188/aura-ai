//
//  FloatingTabBar.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Futuristic Floating Capsule Navigation Bar
//

import SwiftUI

public enum CyberTab: String, CaseIterable {
    case home
    case chat
    case aiCore
    case tools
    case profile
    
    public var displayName: String {
        switch self {
        case .home: return LanguageManager.shared.text(.tabHome)
        case .chat: return LanguageManager.shared.text(.tabChat)
        case .aiCore: return LanguageManager.shared.text(.tabAI)
        case .tools: return LanguageManager.shared.text(.tabTools)
        case .profile: return LanguageManager.shared.text(.tabProfile)
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .aiCore: return "brain.head.profile"
        case .tools: return "square.grid.2x2.fill"
        case .profile: return "person.fill"
        }
    }
}

public struct FloatingTabBar: View {
    @ObservedObject private var langManager = LanguageManager.shared
    @Binding public var selectedTab: CyberTab
    public var onMicTapped: () -> Void
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(CyberTab.allCases, id: \.self) { tab in
                Spacer()
                
                if tab == .aiCore {
                    // 中央突出 AI 悬浮主控按键
                    Button(action: onMicTapped) {
                        ZStack {
                            Circle()
                                .fill(CyberTheme.holographicGradient)
                                .frame(width: 54, height: 54)
                                .shadow(color: CyberTheme.electricCyan.opacity(0.8), radius: 12)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -12)
                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                            Text(tab.displayName)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? CyberTheme.electricCyan : Color.gray)
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(red: 0.05, green: 0.08, blue: 0.18).opacity(0.85))
                .background(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(CyberTheme.cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: CyberTheme.electricCyan.opacity(0.2), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 24)
    }
}
