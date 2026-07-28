//
//  CameraVisionLiveView.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Real-Time Camera Vision & Multi-modal Screen Understanding
//

import SwiftUI
import AVFoundation

public struct CameraVisionLiveView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cameraManager = CameraCaptureManager()

    @State private var isAnalyzing: Bool = false
    @State private var visionAnalysisResult: String? = nil

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraManager.permissionState == .authorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("AURA 实时视觉眼 (Camera Vision)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(CyberTheme.electricCyan)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                if cameraManager.permissionState == .denied {
                    permissionDeniedView
                } else {
                    // 实时视觉识别框
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [CyberTheme.electricCyan, CyberTheme.neonPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 280, height: 320)

                        if isAnalyzing {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(CyberTheme.electricCyan)
                                Text("端侧 Vision 神经网络分析画面中...")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 260, height: 300)
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(20)
                        } else if let result = visionAnalysisResult {
                            ScrollView {
                                Text(result)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(16)
                            }
                            .frame(width: 260, height: 300)
                            .background(Color.black.opacity(0.45))
                            .cornerRadius(20)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "viewfinder")
                                    .font(.system(size: 44))
                                    .foregroundColor(CyberTheme.electricCyan)
                                Text("对准目标物品、文档或画面")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                    }
                }

                Spacer()

                // 拍摄与分析按钮
                if cameraManager.permissionState == .authorized {
                    Button(action: analyzeCurrentFrame) {
                        ZStack {
                            Circle()
                                .fill(CyberTheme.electricCyan)
                                .frame(width: 70, height: 70)
                            Image(systemName: "sparkles")
                                .font(.system(size: 28))
                                .foregroundColor(.black)
                        }
                    }
                    .disabled(isAnalyzing)
                    .opacity(isAnalyzing ? 0.5 : 1.0)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            cameraManager.requestPermissionAndStart()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill.badge.ellipsis")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.7))
            Text("未获得摄像头权限，请前往「设置」开启后重试")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("前往设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(CyberTheme.electricCyan)
            .padding(.top, 4)
        }
    }

    private func analyzeCurrentFrame() {
        HapticFeedbackManager.shared.impactMedium()
        isAnalyzing = true
        visionAnalysisResult = nil

        cameraManager.capturePhoto { image in
            guard let image else {
                isAnalyzing = false
                visionAnalysisResult = "拍摄失败，请重试。"
                return
            }
            LocalVisionSceneAnalyzer.shared.analyzeScene(in: image) { summary in
                isAnalyzing = false
                visionAnalysisResult = summary
                TTSSpeechManager.shared.speak(text: "已为您识别完成。")
            }
        }
    }
}
