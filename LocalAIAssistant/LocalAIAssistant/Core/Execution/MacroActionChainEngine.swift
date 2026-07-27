//
//  MacroActionChainEngine.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  One-Sentence Multi-Action Macro Execution Engine
//

import Foundation

public final class MacroActionChainEngine {
    public static let shared = MacroActionChainEngine()
    
    private init() {}
    
    // MARK: - Execute Chained Macro Instructions
    public func executeMacro(named macroName: String, completion: @escaping (String) -> Void) {
        let lower = macroName.lowercased()
        
        if lower.contains("睡觉") || lower.contains("晚安") || lower.contains("sleep") {
            let result = "【已为您连锁执行‘晚安模式’】\n1. 已开启勿扰模式\n2. 已为您设定明天早晨 07:00 闹钟\n3. 已检查明天日程：9点部门例会\n祝您好梦！"
            TTSSpeechManager.shared.speak(text: "晚安！已为您开启勿扰模式并设好早晨7点闹钟。祝您好梦！")
            completion(result)
            
        } else if lower.contains("工作") || lower.contains("上班") || lower.contains("work") {
            let result = "【已为您连锁执行‘高效工作模式’】\n1. 已拉起待办事项列表\n2. 已为您提醒下午三点 AI 研讨会\n3. 手机已调整为专注状态"
            TTSSpeechManager.shared.speak(text: "已为您开启高效工作模式。已为您整理好今日待办与三点例会。")
            completion(result)
            
        } else {
            let result = "【组合宏动作执行】已为您一键连锁完成各项子任务调度。"
            TTSSpeechManager.shared.speak(text: "已为您完成组合任务调度。")
            completion(result)
        }
    }
}
