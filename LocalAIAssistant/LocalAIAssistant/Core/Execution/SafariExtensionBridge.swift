//
//  SafariExtensionBridge.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Safari Browser Sidebar Plugin & Web Content Summarizer
//

import Foundation

public final class SafariExtensionBridge {
    public static let shared = SafariExtensionBridge()

    private init() {}

    // MARK: - Summarize Web Page / Article (真实抓取网页内容 + 端侧 LLM 摘要，不再是固定文案)
    public func summarizeWebContent(url: String, contentHTML: String, completion: @escaping (String) -> Void) {
        let isZh = LocalizationHelper.isChineseSystem

        Task {
            let html: String
            if !contentHTML.isEmpty {
                html = contentHTML
            } else if let fetched = await Self.fetchHTML(from: url) {
                html = fetched
            } else {
                let failMsg = isZh ?
                    "【网页总结失败】无法访问该网页，请检查网络连接或链接是否正确。" :
                    "[Web Summary Failed] Could not fetch the page — check your network or the URL."
                await MainActor.run { completion(failMsg) }
                return
            }

            let plainText = Self.stripHTML(html)
            guard !plainText.isEmpty else {
                let failMsg = isZh ?
                    "【网页总结失败】未能从页面提取到有效文本内容。" :
                    "[Web Summary Failed] No readable text content extracted from the page."
                await MainActor.run { completion(failMsg) }
                return
            }

            // 端侧 1.5B 模型上下文有限，截断避免 prompt 过长
            let truncated = String(plainText.prefix(3000))
            let systemPrompt = isZh ?
                "你是一个网页内容总结助手。请阅读用户提供的网页正文，用 3-4 条要点简明总结页面的核心内容，只根据给定文本作答，不要编造原文没有的信息。" :
                "You are a web content summarizer. Read the page text and summarize its core content in 3-4 concise bullet points based only on the given text — do not invent information."

            let summary = await LLMManager.shared.generateRawText(systemPrompt: systemPrompt, userInput: truncated)
            await MainActor.run {
                completion(summary)
            }
        }
    }

    // MARK: - Real Network Fetch
    private static func fetchHTML(from urlString: String) async -> String? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            print("[SafariExtensionBridge Error] 抓取网页失败: \(error)")
            return nil
        }
    }

    // MARK: - Lightweight HTML -> Plain Text (线程安全，不依赖 WebKit)
    private static func stripHTML(_ html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: " ", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: " ", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)

        let entities: [String: String] = [
            "&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&#39;": "'"
        ]
        for (entity, replacement) in entities {
            text = text.replacingOccurrences(of: entity, with: replacement)
        }

        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
