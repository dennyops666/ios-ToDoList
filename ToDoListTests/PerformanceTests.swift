class PerformanceTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
    }
    
    func testBatchTaskCreationPerformance() {
        measure {
            // 批量创建100个任务
            for i in 0..<100 {
                let task = Task(context: coreDataManager.context)
                task.title = "Task \(i)"
                task.taskDescription = "Description \(i)"
                task.deadline = Date()
                task.taskPriority = .medium
            }
            coreDataManager.saveContext()
        }
    }
    
    func testTaskSearchPerformance() {
        // 首先创建测试数据
        for i in 0..<100 {
            let task = Task(context: coreDataManager.context)
            task.title = "Test Task \(i)"
        }
        coreDataManager.saveContext()
        
        measure {
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", "Test")
            _ = try? coreDataManager.context.fetch(request)
        }
    }
    
    func testStatisticsCalculationPerformance() {
        // 创建测试数据
        for _ in 0..<100 {
            let task = Task(context: coreDataManager.context)
            task.isCompleted = Bool.random()
            task.taskPriority = [.low, .medium, .high].randomElement() ?? .medium
        }
        coreDataManager.saveContext()
        
        measure {
            _ = StatisticsManager.shared.calculateStatistics()
        }
    }
} 