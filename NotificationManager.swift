import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("通知权限获取成功")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotification(for task: Task) {
        guard let title = task.title,
              let dueDate = task.dueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = "任务「\(title)」即将到期"
        content.sound = UNNotificationSound.default
        
        // 在截止时间前30分钟提醒
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: dueDate) ?? dueDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id?.uuidString ?? UUID().uuidString,
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("设置通知失败: \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotification(for task: Task) {
        guard let id = task.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
