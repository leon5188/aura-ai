//
//  ReminderCalendarManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  EventKit Integration (Reminders & Calendar Events)
//

import Foundation
import EventKit

public final class ReminderCalendarManager {
    public static let shared = ReminderCalendarManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    // MARK: - Create Reminder
    public func createReminder(title: String, dueDate: Date? = nil, completion: @escaping (Bool, String) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        let handleCreate = {
            let reminder = EKReminder(eventStore: self.eventStore)
            reminder.title = title
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            
            if let due = dueDate {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: due)
                reminder.dueDateComponents = components
            }
            
            do {
                try self.eventStore.save(reminder, commit: true)
                completion(true, "已成功为您创建提醒事项：\"\(title)\"")
            } catch {
                completion(false, "创建提醒事项失败: \(error.localizedDescription)")
            }
        }
        
        if status == .authorized {
            handleCreate()
        } else {
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToReminders { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            handleCreate()
                        } else {
                            completion(false, "未获得提醒事项访问权限")
                        }
                    }
                }
            } else {
                eventStore.requestAccess(to: .reminder) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            handleCreate()
                        } else {
                            completion(false, "未获得提醒事项访问权限")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Create Calendar Event
    public func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, String) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        let handleCreate = {
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                completion(true, "已成功添加日历日程：\"\(title)\"")
            } catch {
                completion(false, "添加日历日程失败: \(error.localizedDescription)")
            }
        }
        
        if status == .authorized {
            handleCreate()
        } else {
            if #available(iOS 17.0, *) {
                eventStore.requestWriteOnlyAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            handleCreate()
                        } else {
                            completion(false, "未获得日历访问权限")
                        }
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            handleCreate()
                        } else {
                            completion(false, "未获得日历访问权限")
                        }
                    }
                }
            }
        }
    }
}
