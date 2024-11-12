import UIKit
import BackgroundTasks
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AlarmManager.shared.registerBackgroundTask()
        
        // Set the notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register notification categories
        let stopAction = UNNotificationAction(identifier: "STOP_ALARM",
                                            title: "Stop",
                                            options: .foreground)
        
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ALARM",
                                              title: "Snooze",
                                              options: .foreground)
        
        let category = UNNotificationCategory(identifier: "ALARM_CATEGORY",
                                            actions: [stopAction, snoozeAction],
                                            intentIdentifiers: [],
                                            options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AlarmManager.shared.scheduleBackgroundTask()
    }
    
    // Handle notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Start playing the alarm sound
        AlarmSoundService.shared.startAlarm()
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notifications when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "STOP_ALARM" {
            AlarmSoundService.shared.stopAlarm()
        }
        completionHandler()
    }
} 