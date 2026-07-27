//
//  CrossAppAutomationManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Cross-App Automation & DeepLink Scheme Router
//

import UIKit

public final class CrossAppAutomationManager {
    public static let shared = CrossAppAutomationManager()
    
    private init() {}
    
    // MARK: - Open App or Perform Deep Action
    public func openApp(named appName: String, query: String? = nil, completion: @escaping (Bool) -> Void) {
        let lower = appName.lowercased()
        var targetURLString: String? = nil
        
        if lower.contains("微信") || lower.contains("weixin") || lower.contains("wechat") {
            targetURLString = "weixin://"
        } else if lower.contains("淘宝") || lower.contains("taobao") {
            if let q = query, let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                targetURLString = "taobao://s.taobao.com?q=\(encoded)"
            } else {
                targetURLString = "taobao://"
            }
        } else if lower.contains("相册") || lower.contains("照片") || lower.contains("photos") {
            targetURLString = "photos-redirect://"
        } else if lower.contains("日历") || lower.contains("calendar") {
            targetURLString = "calshow://"
        } else if lower.contains("地图") || lower.contains("map") {
            targetURLString = "maps://"
        } else if lower.contains("设置") || lower.contains("setting") {
            targetURLString = UIApplication.openSettingsURLString
        } else if lower.contains("百度") || lower.contains("baidu") || lower.contains("搜索") {
            let q = query ?? appName
            if let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                targetURLString = "https://www.baidu.com/s?wd=\(encoded)"
            }
        } else {
            // 默认浏览器搜索
            let q = query ?? appName
            if let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                targetURLString = "https://www.google.com/search?q=\(encoded)"
            }
        }
        
        guard let urlStr = targetURLString, let url = URL(string: urlStr) else {
            completion(false)
            return
        }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    completion(success)
                }
            } else {
                // 如果是通用链接无法直接打开应用，走网页兜底机制
                if urlStr.hasPrefix("http") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
