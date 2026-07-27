//
//  AnimatedGIFView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant
//  High-Performance Seamless GIF Renderer
//

import SwiftUI
import UIKit
import ImageIO

public struct AnimatedGIFView: UIViewRepresentable {
    public let gifURL: URL
    public var isPlaying: Bool = true
    
    public init(gifURL: URL, isPlaying: Bool = true) {
        self.gifURL = gifURL
        self.isPlaying = isPlaying
    }
    
    public func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        loadGIF(into: imageView)
        return imageView
    }
    
    public func updateUIView(_ uiView: UIImageView, context: Context) {
        if isPlaying {
            if !uiView.isAnimating { uiView.startAnimating() }
        } else {
            if uiView.isAnimating { uiView.stopAnimating() }
        }
    }
    
    private func loadGIF(into imageView: UIImageView) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: gifURL),
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
            
            var images = [UIImage]()
            var duration: Double = 0
            let count = CGImageSourceGetCount(source)
            
            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                    let frameDuration = self.getFrameDuration(from: source, index: i)
                    duration += frameDuration
                }
            }
            
            DispatchQueue.main.async {
                imageView.animationImages = images
                imageView.animationDuration = duration > 0 ? duration : 1.0
                imageView.animationRepeatCount = 0
                if self.isPlaying {
                    imageView.startAnimating()
                }
            }
        }
    }
    
    private func getFrameDuration(from source: CGImageSource, index: Int) -> Double {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else { return 0.1 }
        
        let frameDuration = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
            ?? gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double
            ?? 0.1
        return frameDuration
    }
}
