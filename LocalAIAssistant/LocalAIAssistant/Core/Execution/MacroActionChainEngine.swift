//
//  MacroActionChainEngine.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  One-Sentence Multi-Action Macro Execution Engine
//

import Foundation
import EventKit

public final class MacroActionChainEngine {
    public static let shared = MacroActionChainEngine()

    private init() {}

    // MARK: - Execute Chained Macro Instructions
    public func executeMacro(named macroName: String, completion: @escaping (String) -> Void) {
        let lower = macroName.lowercased()

        if lower.contains("睡觉") || lower.contains("晚安") || lower.contains("sleep") {
            executeSleepMacro(completion: completion)
        } else if lower.contains("工作") || lower.contains("上班") || lower.contains("work") {
            executeWorkMacro(completion: completion)
        } else {
            let result = "【组合宏动作执行】暂未识别到具体宏动作，可尝试说“晚安”或“开始工作”。"
            completion(result)
        }
    }

    // MARK: - 晚安模式：真实写入明早 07:00 提醒 + 真实查询明天日程
    // 注：iOS 没有对第三方 App 开放"切换系统勿扰/专注模式"的公开 API，
    // 所以这里不再谎称"已开启勿扰模式"——这一步只能引导用户自己在控制中心打开。
    private func executeSleepMacro(completion: @escaping (String) -> Void) {
        ReminderManager.shared.createReminder(title: "早安！新的一天开始了", timeDescription: "明天早晨7点") { reminderResult in
            ReminderManager.shared.fetchTomorrowEvents { events in
                var lines = ["【晚安模式】"]

                switch reminderResult {
                case .success:
                    lines.append("✅ 已在系统提醒事项中创建明早 07:00 的起床提醒")
                case .failure(let error):
                    lines.append("⚠️ 起床提醒创建失败：\(error.localizedDescription)")
                }

                if events.isEmpty {
                    lines.append("📅 明天日历里暂无日程安排")
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let scheduleText = events.prefix(3).map { "\(formatter.string(from: $0.startDate)) \($0.title ?? "未命名日程")" }.joined(separator: "、")
                    lines.append("📅 明天日程：\(scheduleText)")
                }

                lines.append("勿扰模式需要您自己在控制中心开启，App 无法代为切换系统设置。")
                lines.append("祝您好梦！")

                let result = lines.joined(separator: "\n")
                TTSSpeechManager.shared.speak(text: "晚安！已经帮您在系统里设好明早7点的起床提醒。祝您好梦！")
                completion(result)
            }
        }
    }

    // MARK: - 工作模式：真实查询今天剩余日程
    private func executeWorkMacro(completion: @escaping (String) -> Void) {
        let calendar = Calendar.current
        guard let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) else {
            completion("【高效工作模式】已就绪。")
            return
        }

        ReminderManager.shared.fetchEvents(from: Date(), to: todayEnd) { events in
            var lines = ["【高效工作模式】"]
            if events.isEmpty {
                lines.append("📅 今天日历里暂无剩余日程")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let scheduleText = events.prefix(3).map { "\(formatter.string(from: $0.startDate)) \($0.title ?? "未命名日程")" }.joined(separator: "、")
                lines.append("📅 今天剩余日程：\(scheduleText)")
            }
            let result = lines.joined(separator: "\n")
            TTSSpeechManager.shared.speak(text: "已为您查询今天剩余的日程安排，开始高效工作吧！")
            completion(result)
        }
    }
}
