# LocalAIAssistant - 比 Siri 更聪明的端侧 AI 手机助理 (iOS MVP)

> **定位**：100% 本地设备算力运行（On-Device AI）、零延迟、隐私安全，专为打电话、发邮件等高频场景打造的赛博风格 AI 语音助手。

---

## 🎨 视觉风格 (UI Design System)

本项目界面全面参考并重构了最顶级的**赛博全息与半透明玻璃拟态 (Cyberpunk Holographic & Glassmorphism)** 设计规范：
- **配色**：深空太空黑与深蓝背景 (`#080C19` ~ `#0D1326`)，配以电光青 (`#00F0FF`)、皇家宝蓝 (`#3A82F6`) 和霓虹紫 (`#A855F7`)。
- **3D 全息 AI 光球**：包含动态旋转多重微光环、音频振幅联动粒子与加载状态动画。
- **声音波形**：基于 `AVAudioEngine` 实时捕捉麦克风振幅（RMS）并反馈至界面。
- **JSON Inspector 卡片**：实时展示端侧大模型如何无缝把自然语音解析为强类型系统动作 JSON。

---

## 🏗️ 架构分层设计

```text
┌───────────────────────────────────────────────────────┐
│               用户语音输入 (User Voice)                 │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 1. 语音感知层 (Speech Platform)                        │
│    - SpeechRecognizerManager.swift (SFSpeechRecognizer)│
│    - 开启 requiresOnDeviceRecognition 100% 离线识别    │
│    - 内置 VAD 静音断句检测                               │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 2. 端侧认知层 (On-Device Cognitive Core)                │
│    - LLMManager.swift (MLX Swift / Core ML 适配器)    │
│    - Qwen-2.5-1.5B-Instruct (4-bit 量化，显存 ~1.3GB) │
│    - SystemPrompt.swift & IntentParser.swift          │
│    - 输出 JSON: {"action":"call", "target_name":"张三"} │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ 3. 系统执行层 (System Execution Platform)              │
│    - ContactsManager.swift (CNContactStore 匹配号码)  │
│    - SystemActionExecutor.swift (tel:// & MailSheet)  │
│    - CallContactIntent.swift (App Intents iOS 18)      │
└───────────────────────────────────────────────────────┘
```

---

## ⚙️ Xcode 工程配置指南与 App Store 上架合规

### 1. 必需的 Info.plist 隐私权限 Keys (Privacy Keys)
为了确保通过 App Store 官方审核，必须在项目的 `Info.plist` 中添加以下字段：

| Key | Value (提示文字) |
|---|---|
| `NSSpeechRecognitionUsageDescription` | "本应用需要使用离线语音识别功能，将您的语音转为文字控制指令，过程完全在本地完成。" |
| `NSMicrophoneUsageDescription` | "本应用需要使用麦克风以接收您的语音输入。" |
| `NSContactsUsageDescription` | "本应用需要访问通讯录，以根据您的语音指令查找联系人电话号码或邮箱。" |

### 2. 内存限制配置 (Increased Memory Limit)
由于端侧加载 1.5B 4-bit 量化大模型需占用约 1.2GB~1.5GB RAM：
1. 在 Xcode 中打开 target 的 **Signing & Capabilities**。
2. 点击 **+ Capability**，添加 **Increased Memory Limit**。

### 3. 集成 MLX Swift 官方推理引擎 (可选升级)
在 Xcode 的 **Package Dependencies** 中导入官方仓库：
```text
https://github.com/ml-explore/mlx-swift
```
在 `LLMManager.swift` 中取消注释并引入 `import MLX` 和 `import MLXLLM` 即可接入本地 HuggingFace Qwen2.5-1.5B-Instruct-4bit 权重文件！

---

## 🚀 项目文件目录说明

```text
LocalAIAssistant/
├── App/
│   └── LocalAIAssistantApp.swift          // SwiftUI 应用入口
├── Core/
│   ├── Audio/
│   │   └── SpeechRecognizerManager.swift // 离线 STT + VAD 音频管理
│   ├── LLM/
│   │   ├── SystemPrompt.swift           // Function Calling Prompt & Schema
│   │   ├── IntentParser.swift           // 容错 JSON 解析器
│   │   └── LLMManager.swift             // 端侧大模型推理调度器
│   ├── Execution/
│   │   ├── ContactsManager.swift        // 通讯录检索与权限
│   │   └── SystemActionExecutor.swift   // 电话与邮件草稿唤起引擎
│   └── AppIntents/
│       └── CallContactIntent.swift      // App Intents iOS 18 适配
└── UI/
    ├── Theme/
    │   └── DesignSystem.swift           // 赛博霓虹配色与玻璃拟态 Modifier
    └── Views/
        ├── HolographicAICoreView.swift  // 3D 全息 AI 光球与动效
        ├── ActionInspectorView.swift    // 实时 JSON 动作监控面板
        ├── SmartShortcutCard.swift      // 快捷操作卡片
        ├── FloatingTabBar.swift         // 悬浮胶囊导航栏
        └── MainDashboardView.swift      // 主控制台大盘
```
# aura-ai
