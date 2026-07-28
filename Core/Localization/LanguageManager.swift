//
//  LanguageManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Global Dynamic Localization Engine (Bilingual Chinese & English)
//

import Foundation
import Combine

public enum AppLanguage: String, CaseIterable {
    case zhHans = "zh-Hans"
    case english = "en"
    
    public var buttonTitle: String {
        switch self {
        case .zhHans: return "中"
        case .english: return "EN"
        }
    }
}

public enum LocalizedKey {
    case headerTitle
    case headerSubtitle
    case statusDefault
    case statusListening
    case statusThinking
    case statusSuccess
    case statusFailed
    
    case tabHome
    case tabChat
    case tabAI
    case tabTools
    case tabProfile
    
    case inspectorTitle
    case inspectorBadge
    case inspectorPlaceholder
    
    case smartShortcutsTitle
    case callDemoTitle
    case callDemoSub
    case callDemoCmd
    case emailDemoTitle
    case emailDemoSub
    case emailDemoCmd
    
    case alertTitle
    case alertOK
    case alertNoContactName
    case alertNoRecipientName
    case alertCallNotSupported
    case alertContactNotFound(name: String)
    case emailDefaultSubject
    case emailDefaultBody
}

public final class LanguageManager: ObservableObject {
    public static let shared = LanguageManager()
    
    @Published public var currentLanguage: AppLanguage = .zhHans
    
    private init() {}
    
    public func toggleLanguage() {
        if currentLanguage == .zhHans {
            currentLanguage = .english
        } else {
            currentLanguage = .zhHans
        }
    }
    
    public func text(_ key: LocalizedKey) -> String {
        switch currentLanguage {
        case .zhHans:
            return chineseText(for: key)
        case .english:
            return englishText(for: key)
        }
    }
    
    private func chineseText(for key: LocalizedKey) -> String {
        switch key {
        case .headerTitle: return "AURA AI"
        case .headerSubtitle: return "端侧离线语音与意图控制"
        case .statusDefault: return "轻按麦克风或喊'Hey Aura'唤醒"
        case .statusListening: return "正在倾听指令..."
        case .statusThinking: return "端侧神经网络推理中..."
        case .statusSuccess: return "意图解析与工具调用完成"
        case .statusFailed: return "未能匹配到操作意图"
            
        case .tabHome: return "主页"
        case .tabChat: return "对话"
        case .tabAI: return "AI核心"
        case .tabTools: return "工具"
        case .tabProfile: return "我的"
            
        case .inspectorTitle: return "LIVE FUNCTION CALLING INSPECTOR"
        case .inspectorBadge: return "100% OFF-DEVICE"
        case .inspectorPlaceholder: return "等待语音输入中，输出格式：JSON"
            
        case .smartShortcutsTitle: return "智能快捷功能示范"
        case .callDemoTitle: return "呼叫联系人"
        case .callDemoSub: return "给张三打个电话"
        case .callDemoCmd: return "帮我给张三打个电话"
        case .emailDemoTitle: return "撰写邮件"
        case .emailDemoSub: return "发邮件给李四"
        case .emailDemoCmd: return "给李四发封邮件，主题是开会"
            
        case .alertTitle: return "系统响应"
        case .alertOK: return "确定"
        case .alertNoContactName: return "未指定呼叫对象联系人"
        case .alertNoRecipientName: return "未指定收件人姓名"
        case .alertCallNotSupported: return "当前设备或模拟器不支持直接拨打电话"
        case .alertContactNotFound(let name): return "通讯录中未找到联系人：\"\(name)\""
        case .emailDefaultSubject: return "来自智能助手的操作申请"
        case .emailDefaultBody: return "您好，这是通过端侧 AI 智能生成的邮件草稿。"
        }
    }
    
    private func englishText(for key: LocalizedKey) -> String {
        switch key {
        case .headerTitle: return "AURA AI"
        case .headerSubtitle: return "On-Device Offline Voice Control"
        case .statusDefault: return "Tap mic or say 'Hey Aura' to start"
        case .statusListening: return "Listening for commands..."
        case .statusThinking: return "On-Device Neural Inferencing..."
        case .statusSuccess: return "Function Calling Complete"
        case .statusFailed: return "Failed to resolve intent"
            
        case .tabHome: return "Home"
        case .tabChat: return "Chat"
        case .tabAI: return "AI Core"
        case .tabTools: return "Tools"
        case .tabProfile: return "Profile"
            
        case .inspectorTitle: return "LIVE FUNCTION CALLING INSPECTOR"
        case .inspectorBadge: return "100% OFF-DEVICE"
        case .inspectorPlaceholder: return "Awaiting voice input, Output: JSON"
            
        case .smartShortcutsTitle: return "Smart Action Shortcuts"
        case .callDemoTitle: return "Call Contact"
        case .callDemoSub: return "Call Zhang San"
        case .callDemoCmd: return "Call Zhang San"
        case .emailDemoTitle: return "Send Email"
        case .emailDemoSub: return "Email Li Si"
        case .emailDemoCmd: return "Send email to Li Si subject Meeting"
            
        case .alertTitle: return "System Response"
        case .alertOK: return "OK"
        case .alertNoContactName: return "No contact specified"
        case .alertNoRecipientName: return "No email recipient specified"
        case .alertCallNotSupported: return "Device or Simulator does not support phone calls"
        case .alertContactNotFound(let name): return "Contact not found in address book: \"\(name)\""
        case .emailDefaultSubject: return "Action Request from Aura Assistant"
        case .emailDefaultBody: return "Hello, this draft was generated via On-Device AI."
        }
    }
}
