//
//  LocalizationHelper.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  100% Pure Simplified Chinese Master Helper (No English Mixture)
//

import Foundation

public final class LocalizationHelper {
    // 强行锁定 100% 纯正简体中文界面
    public static var isChineseSystem: Bool {
        return true
    }
    
    // MARK: - Initial & Status Strings
    public static var initialStatusText: String {
        "轻触下方 Siri 麦克风开启端侧对话"
    }
    
    public static var listeningStatusText: String {
        "正在倾听您的指令..."
    }
    
    public static var thinkingStatusText: String {
        "端侧大模型正在思考解析..."
    }
    
    public static var unknownInstructionText: String {
        "我是 AURA 智能助手，一个完全运行在手机本地的 AI。我可以为您打电话、发短信、发邮件、加提醒以及回答各种问题。"
    }
    
    // MARK: - Generate Dynamic Pure Chinese Response Speech
    public static func generateResponseSpeech(for intent: ParsedIntent) -> String {
        let name = intent.targetName ?? "联系人"
        
        switch intent.action {
        case .call:
            return "好的，正在为您查找并拨打 \(name) 的电话。"
            
        case .sendEmail:
            return "好的，正在为您草拟发送给 \(name) 的邮件。"
            
        case .sendSMS:
            let msg = intent.message ?? "消息"
            return "好的，正在为您准备给 \(name) 发送短信：\(msg)。"
            
        case .addReminder:
            let title = intent.title ?? "事项"
            return "好的，已为您添加提醒事项：\(title)。"
            
        case .openApp:
            let app = intent.appName ?? "应用"
            return "好的，正在为您启动并跳转至 \(app)。"
            
        case .ocrImage:
            return "好的，端侧 Vision 引擎正在识别提取图片文字。"
            
        case .unknown:
            return intent.reply ?? unknownInstructionText
        }
    }
}
