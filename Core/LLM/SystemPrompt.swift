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

    3. 未知或不支持操作 (action: "unknown")
       参数：
       - reply (String): 简短友好的回复

    【示例】：
    输入："帮我给张三打个电话"
    输出：{"action": "call", "target_name": "张三"}

    输入："给李四发封邮件，主题是开会，内容是下午两点在三楼会议室"
    输出：{"action": "send_email", "target_name": "李四", "subject": "开会", "body": "下午两点在三楼会议室"}

    输入："今天天气怎么样"
    输出：{"action": "unknown", "reply": "抱歉，目前我专注帮助您打电话和发邮件。"}

    请解析以下用户输入：
    """
}

// MARK: - Handled Intent Models
public enum ActionType: String, Codable {
    case call = "call"
    case sendEmail = "send_email"
    case unknown = "unknown"
}

public struct ParsedIntent: Codable {
    public let action: ActionType
    public let targetName: String?
    public let subject: String?
    public let body: String?
    public let reply: String?
    
    enum CodingKeys: String, CodingKey {
        case action
        case targetName = "target_name"
        case subject
        case body
        case reply
    }
}
