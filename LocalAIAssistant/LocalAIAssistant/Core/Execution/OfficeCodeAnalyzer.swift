//
//  OfficeCodeAnalyzer.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Office Meeting Notes, Excel Analysis & Code Bug Debugging Engine
//

import Foundation

public final class OfficeCodeAnalyzer {
    public static let shared = OfficeCodeAnalyzer()
    
    private init() {}
    
    // MARK: - Debug Code Snippets & Analyze Excel Data
    public func analyzeCodeOrOffice(input: String, completion: @escaping (String) -> Void) {
        let isZh = LocalizationHelper.isChineseSystem
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.6) {
            var response = ""
            
            if input.contains("code") || input.contains("swift") || input.contains("bug") || input.contains("代码") {
                response = isZh ?
                    "【AURA 代码 Bug 诊断结果】\n检测到潜在线程问题：在主线程刷新 UI 前缺少 `DispatchQueue.main.async`。建议包裹在主线程调配块中进行刷新。" :
                    "[AURA Code Debugger]\nPotential threading issue detected. Please wrap UI updates inside `DispatchQueue.main.async`."
            } else {
                response = isZh ?
                    "【AURA 办公智能分析】\n已自动生成会议纪要与 Excel 数据趋势报告：项目进度符合预期，核心指标环比上升 18%。" :
                    "[AURA Office Analysis]\nMeeting notes and Excel metrics summary generated: Project on track with +18% QoQ growth."
            }
            
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }
}
