//
//  ContactsManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  CNContactStore Bridge for Contact Search & Phone/Email Extraction
//

import Foundation
import Contacts

public struct ContactInfo {
    public let name: String
    public let phoneNumber: String?
    public let emailAddress: String?
}

public final class ContactsManager {
    public static let shared = ContactsManager()
    private let contactStore = CNContactStore()
    
    private init() {}
    
    // MARK: - Request Contacts Access
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        guard Bundle.main.object(forInfoDictionaryKey: "NSContactsUsageDescription") != nil else {
            print("[ContactsManager Warning] 缺少 NSContactsUsageDescription 权限配置，已进行防崩拦截")
            completion(false)
            return
        }
        
        contactStore.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Search Contact by Name
    public func searchContact(name: String, completion: @escaping ([ContactInfo]) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized else {
            requestAccess { granted in
                if granted {
                    self.searchContact(name: name, completion: completion)
                } else {
                    completion([])
                }
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor
            ]
            
            do {
                let contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                let results = contacts.map { contact -> ContactInfo in
                    let fullName = "\(contact.familyName)\(contact.givenName)".trimmingCharacters(in: .whitespaces)
                    let phone = contact.phoneNumbers.first?.value.stringValue
                    let email = contact.emailAddresses.first?.value as String?
                    return ContactInfo(name: fullName.isEmpty ? name : fullName, phoneNumber: phone, emailAddress: email)
                }
                
                DispatchQueue.main.async {
                    completion(results)
                }
            } catch {
                print("[ContactsManager Error] 检索联系人失败: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
