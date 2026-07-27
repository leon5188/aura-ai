//
//  IntentParser.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Expanded Robust JSON Extractor & Intent Parser
//

import Foundation

public final class IntentParser {
    public static func parse(rawOutput: String) -> ParsedIntent? {
        let cleanedJSON = extractJSONString(from: rawOutput)
        guard let data = cleanedJSON.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ParsedIntent.self, from: data)
        } catch {
            print("[IntentParser Error] JSON 解析失败: \(error), 尝试备用正则比对...")
            return fallbackRegexParse(from: rawOutput)
        }
    }
    
    // MARK: - Cleaning JSON String
    private static func extractJSONString(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") {
            result = String(result.dropFirst(7))
        } else if result.hasPrefix("```") {
            result = String(result.dropFirst(3))
        }
        if result.hasSuffix("```") {
            result = String(result.dropLast(3))
        }
        
        if let firstIndex = result.firstIndex(of: "{"),
           let lastIndex = result.lastIndex(of: "}") {
            result = String(result[firstIndex...lastIndex])
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Fallback Regex Pattern Extraction
    private static func fallbackRegexParse(from text: String) -> ParsedIntent? {
        let lower = text.lowercased()
        
        if lower.contains("打开") || lower.contains("启动") || lower.contains("open") {
            let app = extractAppName(from: text)
            return ParsedIntent(action: .openApp, targetName: nil, subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: app, query: nil, targetMedia: nil, reply: nil)
            
        } else if lower.contains("提取文字") || lower.contains("识图") || lower.contains("ocr") {
            return ParsedIntent(action: .ocrImage, targetName: nil, subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: "图片", reply: nil)
            
        } else if lower.contains("打电话") || lower.contains("拨打") || lower.contains("call") {
            return ParsedIntent(action: .call, targetName: extractName(from: text), subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil)
            
        } else if lower.contains("发短信") || lower.contains("短信") || lower.contains("sms") || lower.contains("message") {
            return ParsedIntent(action: .sendSMS, targetName: extractName(from: text), subject: nil, body: nil, message: text, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil)
            
        } else if lower.contains("发邮件") || lower.contains("写邮件") || lower.contains("email") {
            return ParsedIntent(action: .sendEmail, targetName: extractName(from: text), subject: "智能通知", body: text, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: nil)
            
        } else if lower.contains("提醒") || lower.contains("备忘") || lower.contains("reminder") {
            return ParsedIntent(action: .addReminder, targetName: nil, subject: nil, body: nil, message: nil, title: text, timeDescription: "时间", appName: nil, query: nil, targetMedia: nil, reply: nil)
        }
        
        return ParsedIntent(action: .unknown, targetName: nil, subject: nil, body: nil, message: nil, title: nil, timeDescription: nil, appName: nil, query: nil, targetMedia: nil, reply: "未能在文本中确定具体指令。")
    }
    
    private static func extractAppName(from text: String) -> String {
        if text.contains("微信") { return "微信" }
        if text.contains("淘宝") { return "淘宝" }
        if text.contains("相册") || text.contains("照片") { return "相册" }
        if text.contains("日历") { return "日历" }
        if text.contains("地图") { return "地图" }
        if text.contains("设置") { return "设置" }
        return "软件"
    }
    
    private static func extractName(from text: String) -> String? {
        let pattern = "给([\\u4e00-\\u9fa5a-zA-Z0-9]+)(打|发)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let nameRange = Range(match.range(at: 1), in: text) {
            return String(text[nameRange])
        }
        return nil
    }
}
