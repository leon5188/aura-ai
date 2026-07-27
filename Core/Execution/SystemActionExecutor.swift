//
//  SystemActionExecutor.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  System Level Execution Engine (Calls & Email Composer)
//

import UIKit
import MessageUI

public struct EmailDraftModel: Identifiable {
    public let id = UUID()
    public let recipientName: String
    public let recipientEmail: String?
    public let subject: String
    public let body: String
}

public final class SystemActionExecutor: NSObject, ObservableObject {
    @Published public var pendingEmailDraft: EmailDraftModel? = nil
    @Published public var alertMessage: String? = nil
    
    // MARK: - Execute Parsed Intent
    public func execute(intent: ParsedIntent) {
        switch intent.action {
        case .call:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = "未提供联系人姓名"
                return
            }
            executePhoneCall(targetName: name)
            
        case .sendEmail:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = "未提供收件人姓名"
                return
            }
            executeMailComposer(targetName: name, subject: intent.subject, body: intent.body)
            
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
                    self.alertMessage = "设备不支持拨打电话功能"
                }
            } else {
                self.alertMessage = "通讯录中未找到名为 '\(targetName)' 的有效电话号码"
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
                subject: subject ?? "本地 AI 智能通知",
                body: body ?? "您好，这是通过 iPhone 端侧 AI 快速生成的邮件。"
            )
            
            DispatchQueue.main.async {
                self.pendingEmailDraft = draft
            }
        }
    }
}

// MARK: - Mail Compose UIKit Sheet Helper
public struct MailComposeView: UIViewControllerRepresentable {
    public let draft: EmailDraftModel
    @Environment(\.dismiss) var dismiss
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.dismiss()
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        if let email = draft.recipientEmail {
            composer.setToRecipients([email])
        }
        composer.setSubject(draft.subject)
        composer.setMessageBody(draft.body, isHTML: false)
        return composer
    }
    
    public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
