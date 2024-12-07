import XCTest

class TaskManagementUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testTaskPrioritySelection() {
        // 点击添加按钮
        app.navigationBars["待办事项"].buttons["Add"].tap()
        
        // 输入任务标题
        let titleTextField = app.textFields["输入任务标题"]
        titleTextField.tap()
        titleTextField.typeText("优先级测试任务")
        
        // 选择高优先级
        app.segmentedControls["优先级"].buttons["高"].tap()
        
        // 保存任务
        app.navigationBars["新建任务"].buttons["Save"].tap()
        
        // 验证高优先级标记存在
        XCTAssertTrue(app.images["high_priority_indicator"].exists)
    }
    
    func testRepeatTaskCreation() {
        // 点击添加按钮
        app.navigationBars["待办事项"].buttons["Add"].tap()
        
        // 输入任务标题
        let titleTextField = app.textFields["输入任务标题"]
        titleTextField.tap()
        titleTextField.typeText("重复任务测试")
        
        // 设置重复类型
        app.buttons["重复设置"].tap()
        app.sheets["重复类型"].buttons["每天"].tap()
        
        // 保存任务
        app.navigationBars["新建任务"].buttons["Save"].tap()
        
        // 验证重复标记存在
        XCTAssertTrue(app.images["repeat_indicator"].exists)
    }
    
    func testSubTaskManagement() {
        // 创建主任务
        app.navigationBars["待办事项"].buttons["Add"].tap()
        let titleTextField = app.textFields["输入任务标题"]
        titleTextField.tap()
        titleTextField.typeText("主任务")
        app.navigationBars["新建任务"].buttons["Save"].tap()
        
        // 添加子任务
        app.tables.cells.firstMatch.tap()
        app.buttons["添加子任务"].tap()
        
        let subTaskTextField = app.textFields["子任务标题"]
        subTaskTextField.tap()
        subTaskTextField.typeText("子任务1")
        app.buttons["添加"].tap()
        
        // 验证子任务显示
        XCTAssertTrue(app.staticTexts["子任务1"].exists)
    }
} 