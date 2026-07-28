//
//  SystemActionExecutor.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  Expanded System Execution Engine (Calls, Email, SMS, Reminders, Cross-App & Vision OCR)
//

import UIKit
import MessageUI
import SwiftUI
import Combine

public struct EmailDraftModel: Identifiable {
    public let id = UUID()
    public let recipientName: String
    public let recipientEmail: String?
    public let subject: String
    public let body: String
}

public struct SMSDraftModel: Identifiable {
    public let id = UUID()
    public let recipientName: String
    public let phoneNumber: String?
    public let message: String
}

public final class SystemActionExecutor: NSObject, ObservableObject {
    @Published public var pendingEmailDraft: EmailDraftModel? = nil
    @Published public var pendingSMSDraft: SMSDraftModel? = nil
    @Published public var alertMessage: String? = nil
    
    // MARK: - Execute Parsed Intent
    public func execute(intent: ParsedIntent) {
        switch intent.action {
        case .call:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = LocalizationHelper.isChineseSystem ? "未提供联系人姓名" : "Target name is missing"
                return
            }
            executePhoneCall(targetName: name)
            
        case .sendSMS:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = LocalizationHelper.isChineseSystem ? "未提供短信接收人" : "SMS recipient is missing"
                return
            }
            executeSMSComposer(targetName: name, message: intent.message)
            
        case .sendEmail:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = LocalizationHelper.isChineseSystem ? "未提供邮件收件人" : "Email recipient is missing"
                return
            }
            executeMailComposer(targetName: name, subject: intent.subject, body: intent.body)
            
        case .addReminder:
            guard let title = intent.title, !title.isEmpty else {
                alertMessage = LocalizationHelper.isChineseSystem ? "未提供提醒内容" : "Reminder content is missing"
                return
            }
            executeAddReminder(title: title, timeDescription: intent.timeDescription)
            
        case .openApp:
            let app = intent.appName ?? "应用"
            CrossAppAutomationManager.shared.openApp(named: app, query: intent.query) { [weak self] success in
                if !success {
                    self?.alertMessage = LocalizationHelper.isChineseSystem ? "无法自动启动 \(app)，请确认软件是否安装。" : "Cannot open \(app)"
                }
            }
            
        case .ocrImage:
            let robotDemoPath = BundledMedia.heroPortraitURL.path
            if let image = UIImage(contentsOfFile: robotDemoPath) {
                LocalMediaOCRProcessor.shared.recognizeText(in: image) { [weak self] resultText in
                    DispatchQueue.main.async {
                        self?.alertMessage = "【Vision 端侧 OCR 提取结果】\n\(resultText)"
                    }
                }
            } else {
                alertMessage = "【Vision 端侧 OCR】已就绪，请选择本地图片进行识别。"
            }
            
        case .unknown:
            if let reply = intent.reply {
                alertMessage = reply
            }
        }
    }
    
    // MARK: - Phone Call Trigger
    private func executePhoneCall(targetName: String) {
        ContactsManager.shared.searchContact(name: targetName) { [weak self] contacts in
            guard let self = self else { return }
            
            if let contact = contacts.first, let phone = contact.phoneNumber {
                let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let url = URL(string: "tel://\(cleanPhone)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.alertMessage = LocalizationHelper.isChineseSystem ? "设备不支持拨打电话" : "Device cannot make calls"
                }
            } else {
                self.alertMessage = LocalizationHelper.isChineseSystem ? "通讯录中未找到名为 '\(targetName)' 的有效号码" : "No contact found matching '\(targetName)'"
            }
        }
    }
    
    // MARK: - SMS Composer Trigger
    private func executeSMSComposer(targetName: String, message: String?) {
        ContactsManager.shared.searchContact(name: targetName) { [weak self] contacts in
            guard let self = self else { return }
            
            let phone = contacts.first?.phoneNumber
            let draft = SMSDraftModel(
                recipientName: targetName,
                phoneNumber: phone,
                message: message ?? "来自 AURA 本地 AI 的消息"
            )
            
            DispatchQueue.main.async {
                if MFMessageComposeViewController.canSendText() {
                    self.pendingSMSDraft = draft
                } else {
                    let smsInfo = LocalizationHelper.isChineseSystem ?
                        "【模拟器预览 - 短信指令】\n接收人: \(targetName) (\(phone ?? "无号码"))\n内容: \(draft.message)" :
                        "[Simulator - SMS Intent]\nTo: \(targetName) (\(phone ?? "No Phone"))\nMessage: \(draft.message)"
                    self.alertMessage = smsInfo
                }
            }
        }
    }
    
    // MARK: - Mail Composer Trigger
    private func executeMailComposer(targetName: String, subject: String?, body: String?) {
        ContactsManager.shared.searchContact(name: targetName) { [weak self] contacts in
            guard let self = self else { return }
            
            let email = contacts.first?.emailAddress
            let draft = EmailDraftModel(
                recipientName: targetName,
                recipientEmail: email,
                subject: subject ?? (LocalizationHelper.isChineseSystem ? "本地 AI 智能通知" : "Local AI Notification"),
                body: body ?? (LocalizationHelper.isChineseSystem ? "您好，这是通过端侧 AI 快速生成的邮件。" : "Hello, drafted by on-device AI.")
            )
            
            DispatchQueue.main.async {
                if MFMailComposeViewController.canSendMail() {
                    self.pendingEmailDraft = draft
                } else {
                    let mailInfo = LocalizationHelper.isChineseSystem ?
                        "【模拟器预览 - 邮件指令】\n收件人: \(targetName) (\(email ?? "无邮箱"))\n主题: \(draft.subject)\n正文: \(draft.body)" :
                        "[Simulator - Email Intent]\nTo: \(targetName) (\(email ?? "No Email"))\nSubject: \(draft.subject)\nBody: \(draft.body)"
                    self.alertMessage = mailInfo
                }
            }
        }
    }
    
    // MARK: - Add Reminder Trigger
    private func executeAddReminder(title: String, timeDescription: String?) {
        ReminderManager.shared.createReminder(title: title, timeDescription: timeDescription) { [weak self] result in
            guard let self = self else { return }
            let isZh = LocalizationHelper.isChineseSystem

            switch result {
            case .success(let parsedDate):
                let timeText: String
                if let parsedDate {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: isZh ? "zh_CN" : "en_US")
                    formatter.dateFormat = isZh ? "M月d日 HH:mm" : "MMM d, HH:mm"
                    timeText = formatter.string(from: parsedDate)
                } else {
                    timeText = timeDescription ?? (isZh ? "未指定具体时间" : "No specific time")
                }
                self.alertMessage = isZh ?
                    "【提醒事项已写入系统】\n内容: \(title)\n时间: \(timeText)" :
                    "[Reminder Saved to System]\nTitle: \(title)\nTime: \(timeText)"

            case .failure(let error):
                self.alertMessage = isZh ?
                    "【提醒事项创建失败】\(error.localizedDescription)" :
                    "[Reminder Failed] \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Mail Compose Sheet Helper
public struct MailComposeView: UIViewControllerRepresentable {
    public let draft: EmailDraftModel
    @Environment(\.dismiss) var dismiss
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView
        init(_ parent: MailComposeView) { self.parent = parent }
        public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) { self.parent.dismiss() }
        }
    }
    
    public func makeCoordinator() -> Coordinator { Coordinator(self) }
    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        if let email = draft.recipientEmail { composer.setToRecipients([email]) }
        composer.setSubject(draft.subject)
        composer.setMessageBody(draft.body, isHTML: false)
        return composer
    }
    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// MARK: - SMS Compose Sheet Helper
public struct SMSComposeView: UIViewControllerRepresentable {
    public let draft: SMSDraftModel
    @Environment(\.dismiss) var dismiss
    
    public class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: SMSComposeView
        init(_ parent: SMSComposeView) { self.parent = parent }
        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) { self.parent.dismiss() }
        }
    }
    
    public func makeCoordinator() -> Coordinator { Coordinator(self) }
    public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = context.coordinator
        if let phone = draft.phoneNumber { composer.recipients = [phone] }
        composer.body = draft.message
        return composer
    }
    public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}
