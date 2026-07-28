//
//  SystemPrompt.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  System Prompts & JSON Function Calling Schema Definition
//

import Foundation

public enum SystemPrompt {
    public static let functionCallingPrompt = """
    你是一个完全运行在 iPhone 本地的智能手机助手。你的任务是从用户的自然语言输入中准确提取用户的操作意图与参数，并严格输出标准的 JSON 格式，不要包含任何多余文本或 Markdown 标记。

    【可执行动作 Schema 定义】：

    1. 拨打电话 (action: "call")
       参数：
       - target_name (String): 联系人姓名

    2. 发送邮件 (action: "send_email")
       参数：
       - target_name (String): 收件人姓名
       - subject (String, 可选): 邮件主题
       - body (String, 可选): 邮件正文

    3. 创建提醒事项 (action: "create_reminder")
       参数：
       - title (String): 提醒事项标题内容

    4. 添加日历日程 (action: "create_event")
       参数：
       - title (String): 日程标题
       - start_time (String, 可选): 开始时间

    5. 未知或不支持操作 (action: "unknown")
       参数：
       - reply (String): 简短友好的回复

    【示例】：
    输入："帮我给张三打个电话"
    输出：{"action": "call", "target_name": "张三"}

    输入："提醒我明天下午三点开会"
    输出：{"action": "create_reminder", "title": "明天下午三点开会"}

    输入："今天天气怎么样"
    输出：{"action": "unknown", "reply": "抱歉，目前我专注帮助您拨打电话、发邮件和管理日程。"}

    请解析以下用户输入：
    """
}

// MARK: - Handled Intent Models
public enum ActionType: String, Codable {
    case call = "call"
    case sendEmail = "send_email"
    case createReminder = "create_reminder"
    case createEvent = "create_event"
    case unknown = "unknown"
}

public struct ParsedIntent: Codable, Equatable {
    public let action: ActionType
    public let targetName: String?
    public let subject: String?
    public let body: String?
    public let title: String?
    public let startTime: String?
    public let reply: String?
    
    enum CodingKeys: String, CodingKey {
        case action
        case targetName = "target_name"
        case subject
        case body
        case title
        case startTime = "start_time"
        case reply
    }
}

