import Foundation

class StatisticsManager {
    static let shared = StatisticsManager()
    
    struct TaskStatistics {
        var totalTasks: Int = 0
        var completedTasks: Int = 0
        var completionRate: Double = 0
        var priorityDistribution: [TaskPriority: Int] = [:]
        var categoryDistribution: [String: Int] = [:]
        var weeklyCompletion: [Date: Int] = [:]
    }
    
    func calculateStatistics() -> TaskStatistics {
        let tasks = CoreDataManager.shared.fetchAllTasks()
        var stats = TaskStatistics()
        
        stats.totalTasks = tasks.count
        stats.completedTasks = tasks.filter { $0.isCompleted }.count
        stats.completionRate = tasks.isEmpty ? 0 : Double(stats.completedTasks) / Double(stats.totalTasks)
        
        // 计算优先级分布
        for task in tasks {
            stats.priorityDistribution[task.taskPriority, default: 0] += 1
        }
        
        return stats
    }
} 