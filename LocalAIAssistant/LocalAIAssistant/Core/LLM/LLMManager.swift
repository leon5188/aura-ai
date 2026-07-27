//
//  LLMManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Real On-Device LLM Neural Engine (MLX Swift / Qwen2.5-1.5B-Instruct-4bit)
//

import Foundation
import Combine
import MLXLLM
import MLXLMCommon

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

    // 对话历史记忆上下文 (Context Window)
    private var conversationContext: [String] = []

    // 已加载的端侧模型容器 (权重常驻内存，逐轮复用；不复用 KVCache，因为每轮的 prompt 都会重新拼入历史文本)
    private var modelContainer: ModelContainer?

    private let generateParameters = GenerateParameters(maxTokens: 220, temperature: 0.4)

    public init() {
        loadOnDeviceModel()
    }

    // MARK: - Load On-Device Model
    // 真机 Metal/GPU 加载 mlx-community/Qwen2.5-1.5B-Instruct-4bit，首次运行会经由 Hugging Face Hub
    // 联网下载权重（约 0.8~1GB）并缓存到设备本地，之后离线可用。
    // 注意：MLX 依赖 Metal GPU 推理，iOS 模拟器无法正确运行，需要在真机上验证。
    public func loadOnDeviceModel() {
        guard case .unloaded = modelState else { return }
        modelState = .loading(progress: 0)

        Task { [weak self] in
            do {
                let container = try await LLMModelFactory.shared.loadContainer(
                    configuration: LLMRegistry.qwen2_5_1_5b
                ) { progress in
                    let fraction = progress.fractionCompleted
                    Task { @MainActor [weak self] in
                        self?.modelState = .loading(progress: fraction)
                    }
                }

                await MainActor.run {
                    self?.modelContainer = container
                    self?.modelState = .ready
                    print("[LLMManager] AURA 端侧 Qwen2.5-1.5B-Instruct-4bit (MLX) 加载完成，真实推理引擎就绪")
                }
            } catch {
                await MainActor.run {
                    self?.modelState = .error(error.localizedDescription)
                    print("[LLMManager Error] 端侧模型加载失败: \(error)")
                }
            }
        }
    }

    // MARK: - Process User Speech / Text
    public func processUserSpeech(_ userText: String, completion: @escaping (ParsedIntent?) -> Void) {
        guard case .ready = modelState, let container = modelContainer else {
            print("[LLMManager Error] 模型尚未就绪")
            completion(nil)
            return
        }

        modelState = .inferencing
        conversationContext.append("User: \(userText)")

        let fullPrompt = SystemPrompt.functionCallingPrompt
            + "\n历史上下文：" + conversationContext.suffix(6).joined(separator: "\n")
            + "\n最新输入：\"\(userText)\"\n输出："

        Task { [weak self] in
            guard let generateParameters = self?.generateParameters else { return }
            do {
                // 每轮独立创建 ChatSession（复用已加载权重的 modelContainer），
                // 因为 fullPrompt 每次都会重新拼入最新历史，不依赖跨轮持久化的 KVCache。
                let session = ChatSession(container, generateParameters: generateParameters)
                let rawOutput = try await session.respond(to: fullPrompt)
                let intent = IntentParser.parse(rawOutput: rawOutput)

                await MainActor.run {
                    guard let self = self else { return }
                    if let reply = intent?.reply {
                        self.conversationContext.append("AURA: \(reply)")
                    }
                    self.lastRawOutput = rawOutput
                    self.lastParsedIntent = intent
                    self.modelState = .ready
                    completion(intent)
                }
            } catch {
                await MainActor.run {
                    self?.modelState = .ready
                    print("[LLMManager Error] 端侧推理失败: \(error)")
                    completion(nil)
                }
            }
        }
    }
}
