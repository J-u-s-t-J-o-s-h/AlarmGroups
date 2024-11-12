import Foundation
import UserNotifications

@MainActor
class AlarmGroupViewModel: ObservableObject {
    @Published var alarmGroups: [AlarmGroup] = [] {
        didSet {
            saveAlarmGroups()
        }
    }
    
    private let intervalOptions: [TimeInterval] = [5, 10, 15]
    private let userDefaultsKey = "savedAlarmGroups"
    
    init() {
        loadAlarmGroups()
        requestNotificationPermissions()
    }
    
    private func loadAlarmGroups() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                let savedGroups = try decoder.decode([AlarmGroup].self, from: data)
                self.alarmGroups = savedGroups
                
                // Reschedule notifications for enabled groups
                for group in savedGroups where group.isEnabled {
                    scheduleNotifications(for: group)
                }
            } catch {
                print("Error loading alarm groups: \(error)")
            }
        }
    }
    
    private func saveAlarmGroups() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(alarmGroups)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving alarm groups: \(error)")
        }
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            }
        }
    }
    
    func createAlarmGroup(name: String, startTime: Date, endTime: Date, interval: TimeInterval) {
        let newGroup = AlarmGroup(name: name, startTime: startTime, endTime: endTime, interval: interval)
        alarmGroups.append(newGroup)
        scheduleNotifications(for: newGroup)
    }
    
    func toggleAlarmGroup(_ group: AlarmGroup) {
        if let index = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            updatedGroup.toggle()
            alarmGroups[index] = updatedGroup
            
            if updatedGroup.isEnabled {
                scheduleNotifications(for: updatedGroup)
            } else {
                cancelNotifications(for: updatedGroup)
            }
        }
    }
    
    private func scheduleNotifications(for group: AlarmGroup) {
        let center = UNUserNotificationCenter.current()
        
        for alarm in group.alarms {
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Time to wake up!"
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: alarm.id.uuidString,
                                              content: content,
                                              trigger: trigger)
            
            center.add(request)
        }
    }
    
    private func cancelNotifications(for group: AlarmGroup) {
        let center = UNUserNotificationCenter.current()
        let identifiers = group.alarms.map { $0.id.uuidString }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func deleteAlarmGroup(at indexSet: IndexSet) {
        // Cancel notifications for deleted groups
        for index in indexSet {
            let group = alarmGroups[index]
            cancelNotifications(for: group)
        }
        alarmGroups.remove(atOffsets: indexSet)
    }
    
    func updateAlarmGroup(_ group: AlarmGroup) {
        if let index = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            alarmGroups[index] = group
            if group.isEnabled {
                scheduleNotifications(for: group)
            } else {
                cancelNotifications(for: group)
            }
        }
    }
    
    func toggleIndividualAlarm(in group: AlarmGroup, at index: Int) {
        if let groupIndex = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            updatedGroup.alarms[index].isEnabled.toggle()
            alarmGroups[groupIndex] = updatedGroup
            
            // Update notifications
            if updatedGroup.alarms[index].isEnabled {
                scheduleNotification(for: updatedGroup.alarms[index])
            } else {
                cancelNotification(for: updatedGroup.alarms[index])
            }
        }
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
        content.body = formatTime(alarm.time)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("digital-alarm-clock-151920.mp3"))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString,
                                          content: content,
                                          trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for alarm: Alarm) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }
    
    func updateAlarmTime(in group: AlarmGroup, at index: Int, to newTime: Date) {
        if let groupIndex = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            
            // Cancel the old notification
            cancelNotification(for: updatedGroup.alarms[index])
            
            // Update the alarm time
            updatedGroup.alarms[index].time = newTime
            alarmGroups[groupIndex] = updatedGroup
            
            // Schedule new notification if the alarm is enabled
            if updatedGroup.alarms[index].isEnabled {
                scheduleNotification(for: updatedGroup.alarms[index])
            }
        }
    }
    
    func updateAlarm(in group: AlarmGroup, at index: Int, time: Date, label: String) {
        if let groupIndex = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            
            // Cancel the old notification
            cancelNotification(for: updatedGroup.alarms[index])
            
            // Update the alarm
            updatedGroup.alarms[index].time = time
            updatedGroup.alarms[index].label = label
            alarmGroups[groupIndex] = updatedGroup
            
            // Update notification content and reschedule if enabled
            if updatedGroup.alarms[index].isEnabled {
                scheduleNotification(for: updatedGroup.alarms[index])
            }
        }
    }
    
    func updateGroupName(_ group: AlarmGroup, newName: String) {
        if let index = alarmGroups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = group
            updatedGroup.name = newName
            alarmGroups[index] = updatedGroup
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func createTestAlarm() {
        print("Creating test alarm...")
        // Create an alarm for 30 seconds from now
        let testTime = Date().addingTimeInterval(30)
        let testAlarm = Alarm(time: testTime, label: "Test Alarm")
        
        let content = UNMutableNotificationContent()
        content.title = "Test Alarm"
        content.body = "Testing alarm sound"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("digital-alarm-clock-151920.mp3"))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        // Create a trigger that will fire in 30 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "testAlarm",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test alarm: \(error)")
            } else {
                print("Test alarm scheduled for 30 seconds from now")
            }
        }
    }
    
    func handleAlarmTrigger(for alarm: Alarm) {
        AlarmSoundService.shared.startAlarm()
    }
    
    func stopAlarm() {
        AlarmSoundService.shared.stopAlarm()
    }
} 