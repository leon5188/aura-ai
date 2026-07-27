//
//  ToolsView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  100% Match to f655351c61b901f311ba62c6b09c4c56.jpg 3D Crystal Glass Tools Matrix
//

import SwiftUI

public struct ToolsView: View {
    @ObservedObject var actionExecutor: SystemActionExecutor
    
    @State private var showCameraVisionSheet: Bool = false
    @State private var showTranslationSheet: Bool = false
    
    private let isZh = LocalizationHelper.isChineseSystem
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isZh ? "黑科技工具矩阵" : "Advanced Tools Matrix")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(isZh ? "12 大 3D 水晶模块" : "12 Core 3D Glass Features")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(CyberTheme.electricCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CyberTheme.electricCyan.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            .padding(.bottom, 12)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    // 黑科技 1: 实时同声传译
                    ToolCard(
                        icon: "character.bubble.fill",
                        iconColors: IconPalette.skyBlue,
                        title: isZh ? "实时同声传译" : "Simultaneous Interpretation",
                        subtitle: isZh ? "中英双向语音同传与双语字幕" : "Real-time bilingual translation",
                        category: isZh ? "同声传译" : "Translation"
                    ) {
                        showTranslationSheet = true
                    }

                    // 黑科技 2: 摄像头实时视觉眼
                    ToolCard(
                        icon: "camera.viewfinder",
                        iconColors: IconPalette.orange,
                        title: isZh ? "摄像头实时视觉眼" : "Camera Vision",
                        subtitle: isZh ? "实时画面识别与智能解答" : "Real-time visual OCR & QA",
                        category: isZh ? "多模态视觉" : "Camera Vision"
                    ) {
                        showCameraVisionSheet = true
                    }

                    // 黑科技 3: 组合宏动作链 (晚安模式)
                    ToolCard(
                        icon: "moon.stars.fill",
                        iconColors: IconPalette.indigo,
                        title: isZh ? "一键晚安宏动作" : "Sleep Macro",
                        subtitle: isZh ? "一句话设闹钟+勿扰+日程" : "Chained sleep macro",
                        category: isZh ? "系统宏动作" : "Macro Chain"
                    ) {
                        MacroActionChainEngine.shared.executeMacro(named: "晚安") { res in
                            actionExecutor.alertMessage = res
                        }
                    }

                    // 4. 拨打电话
                    ToolCard(
                        icon: "phone.fill",
                        iconColors: IconPalette.whatsapp,
                        title: isZh ? "拨打电话" : "Phone Call",
                        subtitle: isZh ? "搜索通讯录一键呼叫" : "Search contacts and call",
                        category: isZh ? "系统通讯" : "Telephony"
                    ) {
                        actionExecutor.execute(intent: ParsedIntent(action: .call, targetName: "张三", subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil))
                    }

                    // 5. 发送短信
                    ToolCard(
                        icon: "message.fill",
                        iconColors: IconPalette.spotify,
                        title: isZh ? "发送短信" : "Send SMS",
                        subtitle: isZh ? "语音生成并快速发短信" : "Draft and send SMS text",
                        category: isZh ? "系统通讯" : "Messaging"
                    ) {
                        actionExecutor.execute(intent: ParsedIntent(action: .sendSMS, targetName: "李四", subject: nil, body: nil, message: "晚上一起吃饭", title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil))
                    }

                    // 6. 发送邮件
                    ToolCard(
                        icon: "envelope.fill",
                        iconColors: IconPalette.facebook,
                        title: isZh ? "发送邮件" : "Send Email",
                        subtitle: isZh ? "草拟并拉起系统邮件" : "Draft and compose email",
                        category: isZh ? "办公协作" : "Office"
                    ) {
                        actionExecutor.execute(intent: ParsedIntent(action: .sendEmail, targetName: "王五", subject: "智能通知", body: "端侧 AI 自动化邮件", message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil))
                    }

                    // 7. 创建提醒事项
                    ToolCard(
                        icon: "bell.fill",
                        iconColors: IconPalette.sunGold,
                        title: isZh ? "添加提醒" : "Add Reminder",
                        subtitle: isZh ? "写入系统日历与日程" : "Create event & reminder",
                        category: isZh ? "日程管理" : "Schedule"
                    ) {
                        actionExecutor.execute(intent: ParsedIntent(action: .addReminder, targetName: nil, subject: nil, body: nil, message: nil, title: "下午三点端侧 AI 项目会议", timeDescription: "今天下午3点", appName: nil, query: nil, targetMedia: nil, reply: nil))
                    }

                    // 8. 跨软件打开与搜索
                    ToolCard(
                        icon: "arrow.up.forward.app.fill",
                        iconColors: IconPalette.pink,
                        title: isZh ? "跨软件路由" : "App Routing",
                        subtitle: isZh ? "微信与淘宝一键跳转" : "Open WeChat & Taobao",
                        category: isZh ? "系统自动化" : "Automation"
                    ) {
                        CrossAppAutomationManager.shared.openApp(named: "淘宝", query: "无人机") { _ in }
                    }

                    // 9. 图像文字识图
                    ToolCard(
                        icon: "doc.viewfinder.fill",
                        iconColors: IconPalette.teal,
                        title: isZh ? "图片提取文字" : "Vision OCR",
                        subtitle: isZh ? "离线识别提取图片文字" : "Extract text from image",
                        category: isZh ? "多媒体处理" : "Vision"
                    ) {
                        actionExecutor.execute(intent: ParsedIntent(action: .ocrImage, targetName: nil, subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: "图片", reply: nil))
                    }

                    // 10. 多模态视频生成
                    ToolCard(
                        icon: "video.fill",
                        iconColors: IconPalette.crimson,
                        title: isZh ? "视频模型生成" : "Video Generation",
                        subtitle: isZh ? "高质量文字转视频渲染" : "Generate 4K AI Video",
                        category: isZh ? "音视频生成" : "Multimodal"
                    ) {
                        MultimodalMediaGenerator.shared.generateSeedanceVideo(prompt: "赛博全息少女") { result in
                            actionExecutor.alertMessage = isZh ? "【视频生成完成】\n画面提示：\(result.prompt)" : "[Video Generated]\nPrompt: \(result.prompt)"
                        }
                    }

                    // 11. 网页侧边栏总结
                    ToolCard(
                        icon: "safari.fill",
                        iconColors: IconPalette.cyanBlue,
                        title: isZh ? "网页总结与翻译" : "Web Summarizer",
                        subtitle: isZh ? "一键总结文章与字幕" : "Summarize web articles",
                        category: isZh ? "浏览器扩展" : "Browser"
                    ) {
                        SafariExtensionBridge.shared.summarizeWebContent(url: "https://apple.com", contentHTML: "") { summary in
                            actionExecutor.alertMessage = summary
                        }
                    }

                    // 12. 代码排错与办公诊断
                    ToolCard(
                        icon: "curlybraces.square.fill",
                        iconColors: IconPalette.slate,
                        title: isZh ? "代码与办公排错" : "Code & Office Debug",
                        subtitle: isZh ? "诊断代码问题与分析" : "Analyze code bugs",
                        category: isZh ? "日常创作" : "DevTools"
                    ) {
                        OfficeCodeAnalyzer.shared.analyzeCodeOrOffice(input: "SwiftUI UI Thread Bug") { res in
                            actionExecutor.alertMessage = res
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
            }
        }
        .fullScreenCover(isPresented: $showCameraVisionSheet) {
            CameraVisionLiveView()
        }
        .fullScreenCover(isPresented: $showTranslationSheet) {
            RealtimeTranslateView()
        }
    }
}

struct ToolCard: View {
    let icon: String
    var iconColors: [Color] = IconPalette.cyanBlue
    let title: String
    let subtitle: String
    let category: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.impactMedium()
            action()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    GlossyIconBadge(icon, colors: iconColors, size: 36)
                    Spacer()
                    Text(category)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(14)
            .pure3DGlassStyle(cornerRadius: 18) // 应用 100% 对标 f655351c61b901f311ba62c6b09c4c56.jpg 的 3D 立体玻璃质感
        }
        .buttonStyle(PlainButtonStyle())
    }
}
