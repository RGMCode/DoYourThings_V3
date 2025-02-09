//
//  NotificationManager.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("\(NSLocalizedString("errorRequestingAuthorization", comment: "Error requesting authorization")): \(error.localizedDescription)")
            } else if granted {
                print(NSLocalizedString("notificationAuthorizationGranted", comment: "Notification authorization granted"))
            } else {
                print(NSLocalizedString("notificationAuthorizationDenied", comment: "Notification authorization denied"))
            }
            self.checkNotificationSettings()
        }
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                print(NSLocalizedString("notificationAuthorizationNotDetermined", comment: "Notification authorization not determined"))
            case .denied:
                print(NSLocalizedString("notificationAuthorizationDenied", comment: "Notification authorization denied"))
            case .authorized:
                print(NSLocalizedString("notificationAuthorizationGranted", comment: "Notification authorization granted"))
            case .provisional:
                print(NSLocalizedString("notificationAuthorizationProvisional", comment: "Notification authorization provisional"))
            case .ephemeral:
                print(NSLocalizedString("notificationAuthorizationEphemeral", comment: "Notification authorization ephemeral"))
            @unknown default:
                print(NSLocalizedString("notificationAuthorizationUnknown", comment: "Unknown notification authorization status"))
            }
        }
    }
    
    func scheduleNotification(task: DoYourThing, isReminder: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isReminder ?
            String(format: NSLocalizedString("reminderTitle", comment: "Reminder: %@"), task.dytTitel) :
            String(format: NSLocalizedString("deadlineTitle", comment: "Deadline: %@"), task.dytTitel)
        
        let localizedPriority = localizedPriority(for: task.dytPriority)
        let categoryName = task.category?.originalName ?? NSLocalizedString("uncategorized", comment: "Uncategorized")
        content.body = String(format: NSLocalizedString("notificationBody", comment: "Priority: %@ - Category: %@\nDetails: %@"), localizedPriority, categoryName, task.dytDetailtext)
        content.sound = UNNotificationSound.default
        
        // DeepLink-URL erstellen (myapp://task/<taskID>)
        let deepLinkURL = "myapp://task/\(task.id.uuidString)"
        content.userInfo = ["taskId": task.id.uuidString, "deepLink": deepLinkURL]
        
        // Trigger-Berechnung
        let baseDate = isReminder ? task.dytAlarmReminderDate : task.dytAlarmDeadlineDate
        let timeDate = isReminder ? task.dytAlarmReminderTime : task.dytAlarmDeadlineTime
        
        var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timeDate)
        triggerComponents.hour = timeComponents.hour
        triggerComponents.minute = timeComponents.minute
        
        if let triggerDate = Calendar.current.date(from: triggerComponents) {
            print("Calculated trigger date: \(triggerDate)")
            if triggerDate <= Date() {
                print("Trigger date \(triggerDate) is in the past. Notification will not fire.")
                return
            }
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let identifier = task.id.uuidString + (isReminder ? "_reminder" : "_deadline")
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("\(NSLocalizedString("errorSchedulingNotification", comment: "Error scheduling notification")): \(error.localizedDescription)")
            } else {
                print(String(format: NSLocalizedString("notificationScheduled", comment: "Notification scheduled for %@ at %@"), "\(baseDate)", "\(timeDate)"))
            }
        }
    }

    
    private func localizedPriority(for priority: String) -> String {
        switch priority {
        case NSLocalizedString("veryHigh", comment: "Very High"):
            return NSLocalizedString("veryHigh", comment: "Very High")
        case NSLocalizedString("high", comment: "High"):
            return NSLocalizedString("high", comment: "High")
        case NSLocalizedString("medium", comment: "Medium"):
            return NSLocalizedString("medium", comment: "Medium")
        case NSLocalizedString("low", comment: "Low"):
            return NSLocalizedString("low", comment: "Low")
        case NSLocalizedString("veryLow", comment: "Very Low"):
            return NSLocalizedString("veryLow", comment: "Very Low")
        default:
            return priority
        }
    }
    
    func removeNotification(task: DoYourThing) {
        let identifiers = [task.id.uuidString + "_reminder", task.id.uuidString + "_deadline"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
}

