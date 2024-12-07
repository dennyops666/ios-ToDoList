import XCTest
@testable import ToDoList

class SubTaskTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
    }
    
    func testSubTaskCreation() {
        let parentTask = Task(context: coreDataManager.context)
        let subTask = Task(context: coreDataManager.context)
        subTask.parentTask = parentTask
        
        XCTAssertEqual(subTask.parentTask, parentTask)
        XCTAssertTrue(parentTask.subTasks.contains(subTask))
    }
    
    func testParentTaskCompletion() {
        let parentTask = Task(context: coreDataManager.context)
        
        let subTask1 = Task(context: coreDataManager.context)
        subTask1.parentTask = parentTask
        subTask1.isCompleted = true
        
        let subTask2 = Task(context: coreDataManager.context)
        subTask2.parentTask = parentTask
        subTask2.isCompleted = true
        
        // 所有子任务完成时，父任务应该自动完成
        XCTAssertTrue(parentTask.isCompleted)
    }
    
    func testSubTaskDeletion() {
        let parentTask = Task(context: coreDataManager.context)
        let subTask = Task(context: coreDataManager.context)
        subTask.parentTask = parentTask
        
        coreDataManager.context.delete(subTask)
        coreDataManager.saveContext()
        
        XCTAssertTrue(parentTask.subTasks.isEmpty)
    }
} 