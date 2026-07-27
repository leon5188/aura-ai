//
//  LLMManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  On-Device LLM Inference Manager (MLX / CoreML Bridge)
//

import Foundation
import Combine

public enum LLMModelState {
    case unloaded
    case loading(progress: Double)
    case ready
    case inferencing
    case error(String)
}

public final class LLMManager: ObservableObject {
    @Published public var modelState: LLMModelState = .unloaded
    @Published public var lastRawOutput: String = ""
    @Published public var lastParsedIntent: ParsedIntent? = nil
    
    public init() {
        // 初始化时自动加载本地权重要素
        loadOnDeviceModel()
    }
    
    // MARK: - Load On-Device Model (Qwen2.5-1.5B-4bit / Llama-3.2-1B)
    public func loadOnDeviceModel() {
        modelState = .loading(progress: 0.2)
        
        // 模拟端侧 Core ML / MLX Swift 模型加载过程
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) { [weak self] in
            DispatchQueue.main.async {
                self?.modelState = .loading(progress: 0.8)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.modelState = .ready
                print("[LLMManager] 端侧 1.5B 4-bit 量化模型已就绪 (RAM 占用 ~1.3GB)")
            }
        }
    }
    
    // MARK: - Inference (自然语言 -> JSON Function Calling)
    public func processUserSpeech(_ userText: String, completion: @escaping (ParsedIntent?) -> Void) {
        guard case .ready = modelState else {
            print("[LLMManager Error] 模型尚未就绪")
            completion(nil)
            return
        }
        
        modelState = .inferencing
        
        // 构建带 System Prompt 约束的推理上下文
        let fullPrompt = SystemPrompt.functionCallingPrompt + "\n输入：\"\(userText)\"\n输出："
        
        // 在后台线程执行端侧 ANE / GPU 计算
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            
            // 生成结果（核心端侧推理模拟/MLX 真实输出）
            let rawOutput = self.simulateMLXInference(for: userText)
            let intent = IntentParser.parse(rawOutput: rawOutput)
            
            DispatchQueue.main.async {
                self.lastRawOutput = rawOutput
                self.lastParsedIntent = intent
                self.modelState = .ready
                completion(intent)
            }
        }
    }
    
    // MARK: - Simulated MLX Swift / Core ML Local Inference Rule
    private func simulateMLXInference(for input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.contains("打电话") || trimmed.contains("呼叫") || trimmed.contains("拨打") {
            let name = IntentParser.parse(rawOutput: trimmed)?.targetName ?? "联系人"
            return """
            {
                "action": "call",
                "target_name": "\(name)"
            }
            """
        } else if trimmed.contains("发邮件") || trimmed.contains("写邮件") || trimmed.contains("邮寄") {
            let name = IntentParser.parse(rawOutput: trimmed)?.targetName ?? "联系人"
            return """
            {
                "action": "send_email",
                "target_name": "\(name)",
                "subject": "来自智能助手的操作申请",
                "body": "您好，这是通过端侧 AI 智能生成的邮件草稿。"
            }
            """
        } else {
            return """
            {
                "action": "unknown",
                "reply": "我已经听到：'\(trimmed)'。目前我支持打电话和发邮件。"
            }
            """
        }
    }
}
