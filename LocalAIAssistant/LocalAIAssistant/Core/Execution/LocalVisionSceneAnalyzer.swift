//
//  LocalVisionSceneAnalyzer.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  On-Device Scene Classification + OCR Fusion via Apple Vision
//

import UIKit
import Vision

public final class LocalVisionSceneAnalyzer {
    public static let shared = LocalVisionSceneAnalyzer()

    private init() {}

    public func analyzeScene(in image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("无法读取画面数据。")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let classifyRequest = VNClassifyImageRequest()
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            var classificationLabels: [String] = []
            do {
                try requestHandler.perform([classifyRequest])
                classificationLabels = (classifyRequest.results ?? [])
                    .filter { $0.confidence > 0.15 }
                    .prefix(3)
                    .map { "\($0.identifier)（\(Int($0.confidence * 100))%）" }
            } catch {
                classificationLabels = []
            }

            LocalMediaOCRProcessor.shared.recognizeText(in: image) { recognizedText in
                let hasText = !recognizedText.contains("未检测到") && !recognizedText.contains("未找到")

                var summary = "【AURA 画面分析结果】\n"
                summary += classificationLabels.isEmpty
                    ? "识别目标：未获得明确分类结果\n"
                    : "识别目标：\(classificationLabels.joined(separator: "、"))\n"
                summary += hasText ? "画面文字：\n\(recognizedText)" : "画面文字：未检测到有效文本"

                completion(summary)
            }
        }
    }
}
