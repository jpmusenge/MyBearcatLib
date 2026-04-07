//
//  NotificationService.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/31/26.
//

// PURPOSE: Schedules local push notifications for book due date reminders
// Sends reminders 2 days before, 1 day before, day of, and when overdue

import Foundation
import UserNotifications

class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    /// Request notification permission from the user. Call once at app launch.
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("NotificationService: permission error - \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Check if notifications are currently authorized.
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Schedule Reminders for All Checkouts

    /// Reschedules all reminders based on current checkouts.
    /// Call this whenever checkouts change (new checkout, renewal, return).
    func scheduleReminders(for checkouts: [Checkout], enabled: Bool) {
        // Clear all existing book reminders first
        clearAllReminders()

        guard enabled else { return }

        for checkout in checkouts where !checkout.isReturned {
            scheduleRemindersForBook(checkout)
        }

        print("NotificationService: scheduled reminders for \(checkouts.count) checkouts")
    }

    // MARK: - Schedule Reminders for a Single Book

    private func scheduleRemindersForBook(_ checkout: Checkout) {
        let center = UNUserNotificationCenter.current()

        // Reminder 1: 2 days before due
        if let trigger = makeTrigger(for: checkout.dueDate, daysBefore: 2) {
            let content = makeContent(
                title: "Due in 2 Days",
                body: "\"\(checkout.title)\" is due in 2 days. Return or renew it to avoid late fees.",
                checkoutId: checkout.id
            )
            let request = UNNotificationRequest(
                identifier: "due-2d-\(checkout.id)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // Reminder 2: 1 day before due
        if let trigger = makeTrigger(for: checkout.dueDate, daysBefore: 1) {
            let content = makeContent(
                title: "Due Tomorrow",
                body: "\"\(checkout.title)\" is due tomorrow. Don't forget to return or renew it!",
                checkoutId: checkout.id
            )
            let request = UNNotificationRequest(
                identifier: "due-1d-\(checkout.id)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // Reminder 3: Day of (morning at 9 AM)
        if let trigger = makeTrigger(for: checkout.dueDate, daysBefore: 0) {
            let content = makeContent(
                title: "Due Today",
                body: "\"\(checkout.title)\" is due today. Return it to the Leontyne Price Library before closing.",
                checkoutId: checkout.id
            )
            let request = UNNotificationRequest(
                identifier: "due-0d-\(checkout.id)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // Reminder 4: 1 day overdue
        if let trigger = makeTrigger(for: checkout.dueDate, daysBefore: -1) {
            let content = makeContent(
                title: "Book Overdue",
                body: "\"\(checkout.title)\" is now overdue. Please return it as soon as possible.",
                checkoutId: checkout.id
            )
            content.sound = .defaultCritical
            let request = UNNotificationRequest(
                identifier: "overdue-1d-\(checkout.id)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    // MARK: - Helpers

    /// Creates a trigger for a specific time relative to the due date.
    /// daysBefore: positive = before due, 0 = day of, negative = after due
    private func makeTrigger(for dueDate: Date, daysBefore: Int) -> UNCalendarNotificationTrigger? {
        guard let notificationDate = Calendar.current.date(
            byAdding: .day, value: -daysBefore, to: dueDate
        ) else { return nil }

        // Set notification time to 9:00 AM
        var components = Calendar.current.dateComponents(
            [.year, .month, .day], from: notificationDate
        )
        components.hour = 9
        components.minute = 0

        // Don't schedule if the date is in the past
        guard let fireDate = Calendar.current.date(from: components),
              fireDate > Date() else { return nil }

        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    private func makeContent(title: String, body: String, checkoutId: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        content.userInfo = ["checkoutId": checkoutId]
        // Category for actionable notifications
        content.categoryIdentifier = "BOOK_DUE_REMINDER"
        return content
    }

    // MARK: - Clear

    /// Removes all scheduled book reminders.
    func clearAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Removes reminders for a specific checkout (e.g. after returning a book).
    func clearReminders(for checkoutId: String) {
        let identifiers = [
            "due-2d-\(checkoutId)",
            "due-1d-\(checkoutId)",
            "due-0d-\(checkoutId)",
            "overdue-1d-\(checkoutId)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    // MARK: - Register Notification Actions

    /// Sets up actionable notification categories (Renew / View buttons).
    func registerCategories() {
        let renewAction = UNNotificationAction(
            identifier: "RENEW_ACTION",
            title: "Renew Book",
            options: [.foreground]
        )
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Details",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: "BOOK_DUE_REMINDER",
            actions: [renewAction, viewAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
