//
//  CallContactIntent.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  App Intents Framework Integration for iOS 18 System Actions
//

import AppIntents
import UIKit

@available(iOS 16.0, *)
public struct CallContactIntent: AppIntent {
    public static var title: LocalizedStringResource = "使用本地 AI 智能呼叫联系人"
    public static var description = IntentDescription("通过端侧 AI 意图解析唤起系统电话拨号")
    
    @Parameter(title: "联系人姓名")
    var targetName: String
    
    public init() {
        self.targetName = ""
    }
    
    public init(targetName: String) {
        self.targetName = targetName
    }
    
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // App Intent 在系统快捷指令/控制中心触发
        return .result(dialog: "正在查找通讯录中的 '\(targetName)' 并发起呼叫...")
    }
}

@available(iOS 16.0, *)
public struct LocalAIAssistantShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CallContactIntent(),
            phrases: [
                "使用 \(.applicationName) 给联系人打电话",
                "用 \(.applicationName) 智能拨号"
            ],
            shortTitle: "AI 智能拨号",
            systemImageName: "phone.fill.wave.left"
        )
    }
}
