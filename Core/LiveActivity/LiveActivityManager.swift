//
//  LiveActivityManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  ActivityKit & Dynamic Island State Management
//

import Foundation
import ActivityKit
import SwiftUI

// MARK: - ActivityAttributes for Dynamic Island
public struct AssistantActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public enum AssistantState: String, Codable {
            case listening = "监听中"
            case thinking = "AI 推理中"
            case executing = "执行中"
            case idle = "就绪"
        }
        
        public var state: AssistantState
        public var recognizedText: String
        public var tokensPerSecond: Double
        public var actionName: String?
    }
    
    public var assistantName: String
}

// MARK: - Live Activity Manager
public final class LiveActivityManager: ObservableObject {
    public static let shared = LiveActivityManager()
    
    @Published public var isActivityActive: Bool = false
    @Published public var currentAssistantState: AssistantActivityAttributes.ContentState.AssistantState = .idle
    
    private init() {}
    
    // MARK: - Start Dynamic Island Activity
    public func startActivity(initialText: String = "正在监听...") {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] 当前系统未开启 Live Activities 权限")
            return
        }
        
        let attributes = AssistantActivityAttributes(assistantName: "Local AI")
        let initialState = AssistantActivityAttributes.ContentState(
            state: .listening,
            recognizedText: initialText,
            tokensPerSecond: 38.5,
            actionName: nil
        )
        
        do {
            let activity = try Activity<AssistantActivityAttributes>.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            DispatchQueue.main.async {
                self.isActivityActive = true
                self.currentAssistantState = .listening
                print("[LiveActivity] 已成功拉起灵动岛卡片 (ID: \(activity.id))")
            }
        } catch {
            print("[LiveActivity Error] 启动 Activity 失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update State
    public func updateState(
        state: AssistantActivityAttributes.ContentState.AssistantState,
        text: String,
        tps: Double = 38.5,
        actionName: String? = nil
    ) {
        DispatchQueue.main.async {
            self.currentAssistantState = state
        }
        
        let updatedContent = AssistantActivityAttributes.ContentState(
            state: state,
            recognizedText: text,
            tokensPerSecond: tps,
            actionName: actionName
        )
        
        Task {
            for activity in Activity<AssistantActivityAttributes>.activities {
                await activity.update(using: updatedContent)
            }
        }
    }
    
    // MARK: - End Activity
    public func endActivity() {
        Task {
            for activity in Activity<AssistantActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            DispatchQueue.main.async {
                self.isActivityActive = false
                self.currentAssistantState = .idle
            }
        }
    }
}
