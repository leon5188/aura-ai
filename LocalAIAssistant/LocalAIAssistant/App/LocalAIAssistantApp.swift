//
//  LocalAIAssistantApp.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Main SwiftUI App Entry Point
//

import SwiftUI

@main
struct LocalAIAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            MainDashboardView()
                .preferredColorScheme(.dark) // 保持赛博暗黑模式
        }
    }
}
