import XCTest
@testable import ToDoList

class StatisticsTests: XCTestCase {
    var statisticsManager: StatisticsManager!
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        statisticsManager = StatisticsManager.shared
        coreDataManager = CoreDataManager.shared
        setupTestData()
    }
    
    private func setupTestData() {
        // 创建测试任务数据
        let task1 = Task(context: coreDataManager.context)
        task1.taskPriority = .high
        task1.isCompleted = true
        
        let task2 = Task(context: coreDataManager.context)
        task2.taskPriority = .medium
        task2.isCompleted = false
        
        coreDataManager.saveContext()
    }
    
    func testCompletionRate() {
        let stats = statisticsManager.calculateStatistics()
        XCTAssertEqual(stats.completionRate, 0.5) // 1/2 = 0.5
    }
    
    func testPriorityDistribution() {
        let stats = statisticsManager.calculateStatistics()
        XCTAssertEqual(stats.priorityDistribution[.high], 1)
        XCTAssertEqual(stats.priorityDistribution[.medium], 1)
        XCTAssertEqual(stats.priorityDistribution[.low], 0)
    }
} 