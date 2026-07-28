//
//  IntentParser.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Robust JSON Extractor & Intent Parser
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
            print("[IntentParser Error] JSON 解析失败: \(error), 原始文本: \(rawOutput)")
            return fallbackRegexParse(from: rawOutput)
        }
    }
    
    // MARK: - Cleaning JSON String
    private static func extractJSONString(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // 移除 ```json 和 ```
        if result.hasPrefix("```json") {
            result = String(result.dropFirst(7))
        } else if result.hasPrefix("```") {
            result = String(result.dropFirst(3))
        }
        if result.hasSuffix("```") {
            result = String(result.dropLast(3))
        }
        
        // 寻找第一个 { 到最后一个 }
        if let firstIndex = result.firstIndex(of: "{"),
           let lastIndex = result.lastIndex(of: "}") {
            result = String(result[firstIndex...lastIndex])
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Fallback Regex Pattern Extraction
    private static func fallbackRegexParse(from text: String) -> ParsedIntent? {
        if text.contains("打电话") || text.contains("拨打") || text.contains("call") {
            // 简单匹配姓名
            return ParsedIntent(action: .call, targetName: extractName(from: text), subject: nil, body: nil, title: nil, startTime: nil, reply: nil)
        } else if text.contains("发邮件") || text.contains("撰写邮件") || text.contains("email") {
            return ParsedIntent(action: .sendEmail, targetName: extractName(from: text), subject: "系统智能生成邮件", body: text, title: nil, startTime: nil, reply: nil)
        } else if text.contains("提醒") || text.contains("记住") || text.contains("reminder") {
            return ParsedIntent(action: .createReminder, targetName: nil, subject: nil, body: nil, title: text, startTime: nil, reply: nil)
        } else if text.contains("日程") || text.contains("日历") || text.contains("开会") || text.contains("event") {
            return ParsedIntent(action: .createEvent, targetName: nil, subject: nil, body: nil, title: text, startTime: "今天", reply: nil)
        }
        return ParsedIntent(action: .unknown, targetName: nil, subject: nil, body: nil, title: nil, startTime: nil, reply: "未能在文本中确定操作")

    }
    
    private static func extractName(from text: String) -> String? {
        // 匹配 "给XX打电话" 中的 XX
        let pattern = "给([\\u4e00-\\u9fa5a-zA-Z0-9]+)(打|发)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let nameRange = Range(match.range(at: 1), in: text) {
            return String(text[nameRange])
        }
        return nil
    }
}
