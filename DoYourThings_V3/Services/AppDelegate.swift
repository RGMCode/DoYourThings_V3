//
//  AppDelegate.swift
//  DoYourThings_V3
//
//  Created by RGMCode on 06.02.25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Prüfe, ob die App über einen URL-Launch gestartet wurde (DeepLink)
        if let url = launchOptions?[.url] as? URL {
            if url.scheme == "myapp", url.host == "task" {
                let taskId = url.lastPathComponent
                DeepLinkManager.shared.pendingTaskId = taskId
            }
        }
        
        requestNotificationAuthorization()
        return true
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            } else if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
            self.checkNotificationSettings()
        }
    }
    
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notification authorized")
            default:
                break
            }
        }
    }
    
    // Wird aufgerufen, wenn der Benutzer auf eine Notification tippt
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let taskId = userInfo["taskId"] as? String {
            DeepLinkManager.shared.pendingTaskId = taskId
        }
        completionHandler()
    }
}
