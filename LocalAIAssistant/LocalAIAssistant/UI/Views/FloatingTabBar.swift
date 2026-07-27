//
//  FloatingTabBar.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  100% Match to 13.34.40.png High-Color 3D Liquid Glass Gem Floating TabBar
//

import SwiftUI

public enum CyberTab: String, CaseIterable {
    case home = "Home"
    case chat = "Chat"
    case aiCore = "AI"
    case tools = "Tools"
    case profile = "Profile"
    
    var localizedName: String {
        let isZh = LocalizationHelper.isChineseSystem
        switch self {
        case .home: return isZh ? "首页" : "Home"
        case .chat: return isZh ? "对话" : "Chat"
        case .aiCore: return "AURA"
        case .tools: return isZh ? "工具" : "Tools"
        case .profile: return isZh ? "我的" : "Profile"
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
    @Binding public var selectedTab: CyberTab
    public var onMicTapped: () -> Void
    
    private let siriGifURL = BundledMedia.siriWaveformGIFURL
    
    public init(selectedTab: Binding<CyberTab>, onMicTapped: @escaping () -> Void) {
        self._selectedTab = selectedTab
        self.onMicTapped = onMicTapped
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            ForEach(CyberTab.allCases, id: \.self) { tab in
                if tab == .aiCore {
                    // 100% 对标 13.34.40.png 的纯圆 3D 水晶宝石 Siri 麦克风
                    Button(action: {
                        HapticFeedbackManager.shared.impactMedium()
                        print("[FloatingTabBar] 点击 Siri 纯圆麦克风")
                        onMicTapped()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.50),
                                            Color.white.opacity(0.18)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(.thinMaterial)
                                .frame(width: 58, height: 58)
                                .clipShape(Circle())
                                .shadow(color: CyberTheme.electricCyan.opacity(0.85), radius: 12, x: 0, y: 5)
                            
                            Circle()
                                .fill(Color(red: 0.05, green: 0.08, blue: 0.18))
                                .frame(width: 50, height: 50)
                            
                            AnimatedGIFView(gifURL: siriGifURL, isPlaying: true)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .mask(Circle())
                        }
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // 100% 还原 13.34.40.png 的高彩 3D 液体水晶宝石按键
                    Button(action: {
                        HapticFeedbackManager.shared.impactLight()
                        print("[FloatingTabBar] 点击切换 3D Glass Tab: \(tab.localizedName)")
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        GlossyIceGlassTile(isSelected: selectedTab == tab) {
                            VStack(spacing: 2) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16, weight: .bold))
                                Text(tab.localizedName)
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(selectedTab == tab ? .white : Color.white.opacity(0.85))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}
