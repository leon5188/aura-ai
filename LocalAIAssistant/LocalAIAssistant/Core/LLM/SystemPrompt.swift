//
//  SystemPrompt.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Expanded System Prompts & Multi-Action Function Calling Schema Definition
//

import Foundation

public enum SystemPrompt {
    public static let functionCallingPrompt = """
    你是一个完全运行在 iPhone 本地的智能手机助手 AURA。你的任务是从用户的自然语言输入中准确提取用户的操作意图与参数，并严格输出标准的 JSON 格式。

    【可执行动作 Schema 定义】：

    1. 拨打电话 (action: "call")
       参数：
       - target_name (String): 联系人姓名

    2. 发送邮件 (action: "send_email")
       参数：
       - target_name (String): 收件人姓名
       - subject (String, 可选): 邮件主题
       - body (String, 可选): 邮件正文

    3. 发送短信 (action: "send_sms")
       参数：
       - target_name (String): 接收人姓名
       - message (String): 短信内容

    4. 创建提醒事项 (action: "add_reminder")
       参数：
       - title (String): 提醒内容
       - time_description (String, 可选): 时间描述

    5. 跨 App 自动打开或搜索 (action: "open_app")
       参数：
       - app_name (String): 软件名称（如“微信”、“淘宝”、“相册”、“日历”、“百度”）
       - query (String, 可选): 搜索关键字

    6. 提取图片文字 OCR (action: "ocr_image")
       参数：
       - target_media (String, 可选): 图片说明

    7. 未知或普通问候 (action: "unknown")
       参数：
       - reply (String): 简短友好的回复

    请解析以下用户输入：
    """
}

// MARK: - Handled Intent Models
public enum ActionType: String, Codable {
    case call = "call"
    case sendEmail = "send_email"
    case sendSMS = "send_sms"
    case addReminder = "add_reminder"
    case openApp = "open_app"
    case ocrImage = "ocr_image"
    case unknown = "unknown"
}

public struct ParsedIntent: Codable {
    public let action: ActionType
    public let targetName: String?
    public let subject: String?
    public let body: String?
    public let message: String?
    public let title: String?
    public let timeDescription: String?
    public let appName: String?
    public let query: String?
    public let targetMedia: String?
    public let reply: String?
    
    enum CodingKeys: String, CodingKey {
        case action
        case targetName = "target_name"
        case subject
        case body
        case message
        case title
        case timeDescription = "time_description"
        case appName = "app_name"
        case query
        case targetMedia = "target_media"
        case reply
    }
}
