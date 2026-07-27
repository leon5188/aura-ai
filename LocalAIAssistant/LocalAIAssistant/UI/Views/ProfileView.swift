//
//  ProfileView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Personal Control Center & On-Device Security Dashboard (100% Match to f655351c61b901f311ba62c6b09c4c56.jpg 3D Crystal Glass)
//

import SwiftUI

public struct ProfileView: View {
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("个人控制台 & 使用指南")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                GlossyIconBadge("sparkles", colors: IconPalette.purpleGem, size: 28, iconSize: 13)
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 16) {
                    // 1. AI 主角卡片 (100% 3D 水晶玻璃模块)
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(contentsOfFile: BundledMedia.heroPortraitURL.path) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AURA 智能助手")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("系统语言：简体中文 (zh-CN)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(CyberTheme.electricCyan)
                            Text("端侧架构：100% 本地神经推理引擎")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .pure3DGlassStyle(cornerRadius: 20)
                    
                    // 2. ✨ 使用说明与启发卡片 (下任何指令，AURA 就能执行)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            GlossyIconBadge("book.fill", colors: IconPalette.cyanBlue, size: 26, iconSize: 12)
                            Text("AURA 使用说明 & 隐藏玩法")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Divider().background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 10) {
                            GuideBullet(
                                icon: "mic.fill",
                                iconColors: IconPalette.whatsapp,
                                title: "直接自然语言下达指令",
                                detail: "无需死记硬背固定按键与复杂菜单！按住下方 Siri 麦克风，像对朋友说话一样对 AURA 提出任何需求即可。"
                            )

                            GuideBullet(
                                icon: "bolt.horizontal.circle.fill",
                                iconColors: IconPalette.sunGold,
                                title: "下什么指令，AURA 就能执行",
                                detail: "尝试说：“给张三打个电话”、“发短信给李四约饭”、“提醒我下午三点开会”、“打开淘宝搜索无人机”、“实时同传”、“识图提取文字”，甚至直接对她说“晚安”！"
                            )

                            GuideBullet(
                                icon: "sparkles.rectangle.stack.fill",
                                iconColors: IconPalette.purpleGem,
                                title: "探索无限可能",
                                detail: "更多高级玩法由您直接发掘！日常闲聊、写诗作画、代码排错、网页总结... 随时向 AURA 下达新的挑战指令！"
                            )
                        }
                    }
                    .padding(16)
                    .pure3DGlassStyle(cornerRadius: 20)

                    // 3. 端侧安全与设置面板
                    VStack(spacing: 14) {
                        ProfileRow(icon: "lock.shield.fill", iconColors: IconPalette.teal, title: "100% 离线端侧安全加密", detail: "数据不出手机")
                        ProfileRow(icon: "waveform.path.ecg", iconColors: IconPalette.pink, title: "温柔清脆少女声音", detail: "自然句间顿挫")
                        ProfileRow(icon: "cpu.fill", iconColors: IconPalette.indigo, title: "端侧内存占用", detail: "~1.2 GB (离线神经网络)")
                        ProfileRow(icon: "app.badge.checkmark.fill", iconColors: IconPalette.facebook, title: "iOS 原生系统支持", detail: "已开启快捷集成")
                    }
                    .padding(16)
                    .pure3DGlassStyle(cornerRadius: 20)
                    
                    Text("AURA 本地 AI 语音助手 v2.0 (全能指令版)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
            }
        }
    }
}

struct GuideBullet: View {
    let icon: String
    var iconColors: [Color] = IconPalette.cyanBlue
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            GlossyIconBadge(icon, colors: iconColors, size: 26, iconSize: 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineSpacing(3)
            }
        }
    }
}

struct ProfileRow: View {
    let icon: String
    var iconColors: [Color] = IconPalette.cyanBlue
    let title: String
    let detail: String

    var body: some View {
        HStack {
            GlossyIconBadge(icon, colors: iconColors, size: 30, iconSize: 14)
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Text(detail)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.75))
        }
    }
}
