//
//  ReminderManager.swift
//  LocalAIAssistant
//
//  Created for Local AI Voice Assistant (On-Device MVP)
//  EKEventStore Bridge for Real Reminder Creation
//

import Foundation
import EventKit

public final class ReminderManager {
    public static let shared = ReminderManager()
    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Request Reminders Access
    public func requestAccess(completion: @escaping (Bool) -> Void) {
        guard Bundle.main.object(forInfoDictionaryKey: "NSRemindersUsageDescription") != nil else {
            print("[ReminderManager Warning] 缺少 NSRemindersUsageDescription 权限配置，已进行防崩拦截")
            completion(false)
            return
        }

        eventStore.requestFullAccessToReminders { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Create a Real EKReminder
    public func createReminder(title: String, timeDescription: String?, completion: @escaping (Result<Date?, Error>) -> Void) {
        guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
            requestAccess { granted in
                if granted {
                    self.createReminder(title: title, timeDescription: timeDescription, completion: completion)
                } else {
                    completion(.failure(NSError(domain: "ReminderManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "未获得提醒事项授权，请在系统设置中开启"])))
                }
            }
            return
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        let parsedDate = Self.parseDate(from: timeDescription)
        if let parsedDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: parsedDate)
            reminder.addAlarm(EKAlarm(absoluteDate: parsedDate))
        }

        do {
            try eventStore.save(reminder, commit: true)
            completion(.success(parsedDate))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Query Real Calendar Events in a Date Range
    public func fetchEvents(from start: Date, to end: Date, completion: @escaping ([EKEvent]) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
            eventStore.requestFullAccessToEvents { granted, _ in
                if granted {
                    self.fetchEvents(from: start, to: end, completion: completion)
                } else {
                    DispatchQueue.main.async { completion([]) }
                }
            }
            return
        }

        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        DispatchQueue.main.async {
            completion(events)
        }
    }

    // MARK: - Query Tomorrow's Real Calendar Events
    public func fetchTomorrowEvents(completion: @escaping ([EKEvent]) -> Void) {
        let calendar = Calendar.current
        guard let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())),
              let tomorrowEnd = calendar.date(byAdding: .day, value: 1, to: tomorrowStart) else {
            completion([])
            return
        }
        fetchEvents(from: tomorrowStart, to: tomorrowEnd, completion: completion)
    }

    // MARK: - Natural Language Time Parsing (NSDataDetector)
    // 用系统自带的自然语言日期识别器解析"今天下午3点"这类中文时间描述，
    // 而不是简单把描述文字原样塞进提醒里却不设置真正的到期时间。
    static func parseDate(from text: String?) -> Date? {
        guard let text, !text.isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = detector.firstMatch(in: text, range: range), let date = match.date else {
            return nil
        }

        // 识别出的时间若已经过去（比如晚上问"下午3点"），顺延一天，避免生成一条立刻过期的提醒
        if date < Date() {
            return Calendar.current.date(byAdding: .day, value: 1, to: date)
        }
        return date
    }
}
