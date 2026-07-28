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
                alertMessage = LanguageManager.shared.text(.alertNoContactName)
                return
            }
            executePhoneCall(targetName: name)
            
        case .sendEmail:
            guard let name = intent.targetName, !name.isEmpty else {
                alertMessage = LanguageManager.shared.text(.alertNoRecipientName)
                return
            }
            executeMailComposer(targetName: name, subject: intent.subject, body: intent.body)
            
        case .createReminder:
            let reminderTitle = intent.title ?? "新提醒事项"
            ReminderCalendarManager.shared.createReminder(title: reminderTitle) { [weak self] success, message in
                DispatchQueue.main.async {
                    self?.alertMessage = message
                    if success {
                        TextToSpeechManager.shared.speak(message)
                    }
                }
            }
            
        case .createEvent:
            let eventTitle = intent.title ?? "新日历行程"
            let now = Date()
            let endDate = now.addingTimeInterval(3600)
            ReminderCalendarManager.shared.createEvent(title: eventTitle, startDate: now, endDate: endDate) { [weak self] success, message in
                DispatchQueue.main.async {
                    self?.alertMessage = message
                    if success {
                        TextToSpeechManager.shared.speak(message)
                    }
                }
            }
            
        case .unknown:
            if let reply = intent.reply {
                alertMessage = reply
                TextToSpeechManager.shared.speak(reply)
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
                    self.alertMessage = LanguageManager.shared.text(.alertCallNotSupported)
                }
            } else {
                self.alertMessage = LanguageManager.shared.text(.alertContactNotFound(name: targetName))
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
                subject: subject ?? LanguageManager.shared.text(.emailDefaultSubject),
                body: body ?? LanguageManager.shared.text(.emailDefaultBody)
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
