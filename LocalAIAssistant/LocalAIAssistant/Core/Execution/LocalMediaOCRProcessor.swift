//
//  LocalMediaOCRProcessor.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Native Apple Vision OCR & Local Media Processing Engine
//

import UIKit
import Vision

public final class LocalMediaOCRProcessor {
    public static let shared = LocalMediaOCRProcessor()
    
    private init() {}
    
    // MARK: - Local Image OCR Text Recognition (Vision Framework)
    public func recognizeText(in image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("无法读取图片图层数据。")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion("OCR 文字识别未找到明显文字内容。")
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            completion(fullText.isEmpty ? "图片中未检测到有效文本。" : fullText)
        }
        
        // 设置中文与英文高精度识别模式
        request.recognitionLanguages = ["zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion("Vision OCR 引擎执行失败: \(error.localizedDescription)")
                }
            }
        }
    }
}
