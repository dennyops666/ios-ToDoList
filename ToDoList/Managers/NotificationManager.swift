import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限获取成功")
            } else if let error = error {
                print("通知权限获取失败: \(error)")
            }
        }
    }
    
    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = "任务「\(task.title)」即将到期"
        content.sound = .default
        
        // 设置在截止时间前30分钟提醒
        let triggerDate = task.deadline.addingTimeInterval(-30 * 60)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("设置通知失败: \(error)")
            }
        }
    }
    
    func removeNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
} 