class TaskPriorityTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
    }
    
    func testTaskPriorityCreation() {
        let task = Task(context: coreDataManager.context)
        task.taskPriority = .high
        
        XCTAssertEqual(task.taskPriority, .high)
        XCTAssertEqual(task.priority, TaskPriority.high.rawValue)
    }
    
    func testPriorityColor() {
        XCTAssertEqual(TaskPriority.high.color, .systemRed)
        XCTAssertEqual(TaskPriority.medium.color, .systemOrange)
        XCTAssertEqual(TaskPriority.low.color, .systemBlue)
    }
    
    func testPrioritySorting() {
        // 创建不同优先级的任务
        let highTask = Task(context: coreDataManager.context)
        highTask.taskPriority = .high
        
        let mediumTask = Task(context: coreDataManager.context)
        mediumTask.taskPriority = .medium
        
        let lowTask = Task(context: coreDataManager.context)
        lowTask.taskPriority = .low
        
        let tasks = [lowTask, mediumTask, highTask]
        let sortedTasks = tasks.sorted { $0.taskPriority.rawValue > $1.taskPriority.rawValue }
        
        XCTAssertEqual(sortedTasks[0].taskPriority, .high)
        XCTAssertEqual(sortedTasks[1].taskPriority, .medium)
        XCTAssertEqual(sortedTasks[2].taskPriority, .low)
    }
} 