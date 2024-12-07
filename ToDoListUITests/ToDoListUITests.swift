//
//  ToDoListUITests.swift
//  ToDoListUITests
//
//  Created by Django on 12/6/24.
//

import XCTest

final class ToDoListUITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    private func addBasicTask() throws {
        // 点击添加按钮
        app.navigationBars["待办事项"].buttons["Add"].tap()
        
        // 等待输入界面出现
        let titleTextField = app.textFields["输入任务标题"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5))
        
        // 输入任务标题
        titleTextField.tap()
        titleTextField.typeText("测试任务")
        
        // 输入描述
        let descriptionTextView = app.textViews.element
        XCTAssertTrue(descriptionTextView.waitForExistence(timeout: 5))
        descriptionTextView.tap()
        descriptionTextView.typeText("这是一个测试任务")
        
        // 保存任务
        app.navigationBars["新建任务"].buttons["Save"].tap()
        
        // 等待任务出现在列表中
        let taskText = app.staticTexts["测试任务"]
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: taskText)
        let result = try XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "任务添加失败")
        
        // 确保任务确实显示在列表中
        XCTAssertTrue(taskText.exists, "任务未显示在列表中")
    }
    
    private func addTaskWithCategory(title: String, category: String) throws {
        // 点击添加按钮
        app.navigationBars["待办事项"].buttons["Add"].tap()
        
        // 输入任务标题
        let titleTextField = app.textFields["输入任务标题"]
        titleTextField.tap()
        titleTextField.typeText(title)
        
        // 保存任务
        app.navigationBars["新建任务"].buttons["Save"].tap()
        
        // 等待任务出现在列表中
        let predicate = NSPredicate(format: "exists == true")
        let taskText = app.staticTexts[title]
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: taskText)
        let result = try XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
    }
    
    func testAddTask() throws {
        try addBasicTask()
        XCTAssertTrue(app.staticTexts["测试任务"].exists)
    }
    
    func testDeleteTask() throws {
        try addBasicTask()
        
        // 等待任务出现在列表中
        let taskText = app.staticTexts["测试任务"]
        XCTAssertTrue(taskText.waitForExistence(timeout: 5))
        
        // 记录当前任务数量
        let initialTaskCount = app.cells.count
        
        // 滑动删除
        let taskCell = app.cells.element(boundBy: 0)
        taskCell.swipeLeft()
        
        // 等待删除按钮出现并点击
        let deleteButton = app.buttons["删除"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // 使用 RunLoop 等待删除操作完成
        let runLoop = RunLoop.current
        let deleteDeadline = Date().addingTimeInterval(5)
        
        while taskText.exists && Date() < deleteDeadline {
            runLoop.run(until: Date().addingTimeInterval(0.1))
        }
        
        // 验证任务已被删除
        XCTAssertFalse(taskText.exists, "任务应该已被删除")
        XCTAssertEqual(app.cells.count, initialTaskCount - 1, "任务数量应该减少1")
    }
    
    func testCompleteTask() throws {
        try addBasicTask()
        
        // 滑动完成
        let taskCell = app.cells.element(boundBy: 0)
        taskCell.swipeRight()
        app.buttons["完成"].tap()
        
        // 验证任务状态
        let completedTask = app.cells.element(boundBy: 0)
        XCTAssertNotEqual(completedTask.label, "测试任务")
    }
    
    func testCategoryFilter() throws {
        // 添加两个任务
        try addTaskWithCategory(title: "第一个任务", category: "全部")
        try addTaskWithCategory(title: "第二个任务", category: "全部")
        
        // 验证在"全部"分类下可以看到所有任务
        XCTAssertTrue(app.staticTexts["第一个任务"].exists)
        XCTAssertTrue(app.staticTexts["第二个任务"].exists)
    }
    
    func testAddCategory() throws {
        // 点击分类管理按钮
        app.navigationBars["待办事项"].buttons["List"].tap()
        
        // 点击添加分类
        app.sheets["分类管理"].buttons["添加分类"].tap()
        
        // 输入新分类名称
        let alert = app.alerts["添加分类"]
        let textField = alert.textFields["分类名称"]
        textField.tap()
        textField.typeText("新分类")
        
        // 确认添加
        alert.buttons["添加"].tap()
        
        // 等待新分类出现
        let predicate = NSPredicate(format: "exists == true")
        let newCategory = app.segmentedControls.buttons["新分类"]
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: newCategory)
        let result = try XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
    }
}
