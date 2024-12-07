class RepeatTaskTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
    }
    
    func testRepeatTaskCreation() {
        let task = Task(context: coreDataManager.context)
        task.repeatType = .daily
        
        XCTAssertEqual(task.taskRepeatType, .daily)
    }
    
    func testNextRepeatDate() {
        let task = Task(context: coreDataManager.context)
        task.deadline = Date()
        task.repeatType = .daily
        
        let nextDate = task.nextRepeatDate()
        let calendar = Calendar.current
        
        XCTAssertEqual(
            calendar.component(.day, from: nextDate),
            calendar.component(.day, from: Date()) + 1
        )
    }
    
    func testRepeatTaskCompletion() {
        let task = Task(context: coreDataManager.context)
        task.deadline = Date()
        task.repeatType = .weekly
        
        // 完成任务应该创建下一个重复任务
        task.complete()
        
        let nextTask = task.nextRepeatTask
        XCTAssertNotNil(nextTask)
        XCTAssertEqual(nextTask?.repeatType, task.repeatType)
        XCTAssertFalse(nextTask?.isCompleted ?? true)
    }
} 