//
//  LoopingVideoPlayerView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant
//  Infinite Seamless Looping Video Player for Holographic AI Sphere
//

import SwiftUI
import AVFoundation

public struct LoopingVideoPlayerView: UIViewRepresentable {
    public let videoURL: URL
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    public func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(videoURL: videoURL)
    }
    
    public func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

public class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    public init(videoURL: URL) {
        super.init(frame: .zero)
        setupPlayer(url: videoURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer(url: URL) {
        let asset = AVURLAsset(url: url) // 适配 iOS 18+ 现代 API
        let playerItem = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.queuePlayer = queuePlayer
        
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // 使用 AVPlayerLooper 实现 100% 无缝无限循环
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.isMuted = true // 静音播放作为动态全息背景
        queuePlayer.play()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
