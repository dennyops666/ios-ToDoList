import XCTest
@testable import ToDoList

class RepeatTaskTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
    }
    
    func testRepeatTaskCreation() {
        let task = Task(context: coreDataManager.context)
        task.repeatType = RepeatType.daily.rawValue
        
        XCTAssertEqual(task.taskRepeatType, .daily)
    }
    
    func testNextRepeatDate() {
        let task = Task(context: coreDataManager.context)
        task.deadline = Date()
        task.repeatType = RepeatType.daily.rawValue
        
        let nextDate = task.nextRepeatDate()
        let calendar = Calendar.current
        
        XCTAssertEqual(
            calendar.component(.day, from: nextDate!),
            calendar.component(.day, from: Date()) + 1
        )
    }
    
    func testRepeatTaskCompletion() {
        let task = Task(context: coreDataManager.context)
        task.deadline = Date()
        task.repeatType = RepeatType.weekly.rawValue
        
        task.complete()
        
        let nextTask = task.nextRepeatTask
        XCTAssertNotNil(nextTask)
        XCTAssertEqual(nextTask?.taskRepeatType, task.taskRepeatType)
        XCTAssertFalse(nextTask?.isCompleted ?? true)
    }
} 