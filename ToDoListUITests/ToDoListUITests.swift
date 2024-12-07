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
        let addButton = app.navigationBars["待办事项"].buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // 等待输入界面出现并输入标题
        let titleTextField = app.textFields["输入任务标题"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5))
        titleTextField.tap()
        titleTextField.typeText("测试任务")
        
        // 等待描述输入框出现并输入描述
        let descriptionTextView = app.textViews.firstMatch
        XCTAssertTrue(descriptionTextView.waitForExistence(timeout: 5))
        descriptionTextView.tap()
        descriptionTextView.typeText("这是一个测试任务")
        
        // 点击保存按钮
        let saveButton = app.navigationBars["新建任务"].buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
        
        // 等待任务出现在列表中
        let taskText = app.staticTexts["测试任务"]
        XCTAssertTrue(taskText.waitForExistence(timeout: 5), "任务未显示在列表中")
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
        
        // 找到并滑动第一个单元格
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.swipeLeft()
        
        // 等待删除按钮出现并点击
        let deleteButton = app.buttons["删除"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // 等待任务消失
        let start = Date()
        let timeout = TimeInterval(10) // 增加超时时间
        
        while taskText.exists && Date().timeIntervalSince(start) < timeout {
        }
        
        // 验证任务已被删除
        XCTAssertFalse(taskText.exists, "任务仍然存在于列表中")
        XCTAssertEqual(app.cells.count, initialTaskCount - 1, "任务数量未减少")
    }
    
    func testCompleteTask() throws {
        try addBasicTask()
        
        // 等待任务出现在列表中
        let taskText = app.staticTexts["测试任务"]
        XCTAssertTrue(taskText.waitForExistence(timeout: 5))
        
        // 找到并滑动第一个单元格
        let taskCell = app.cells.firstMatch
        XCTAssertTrue(taskCell.waitForExistence(timeout: 5))
        taskCell.swipeRight()
        
        // 等待并点击完成按钮
        let completeButton = app.buttons.matching(identifier: "完成").firstMatch
        XCTAssertTrue(completeButton.waitForExistence(timeout: 5))
        completeButton.tap()
        
        // 等待任务状态更新
        sleep(1)
        
        // 验证任务状态
        let completedCell = app.cells.firstMatch
        XCTAssertTrue(completedCell.waitForExistence(timeout: 5))
        
        // 获取完成后的任务文本
        let completedText = completedCell.staticTexts.firstMatch
        XCTAssertTrue(completedText.waitForExistence(timeout: 5))
        
        // 验证任务状态已改变
        XCTAssertNotEqual(completedText.label, "测试任务", "任务状态未改变")
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
        let listButton = app.navigationBars["待办事项"].buttons["List"]
        XCTAssertTrue(listButton.waitForExistence(timeout: 5))
        listButton.tap()
        
        // 等待分类管理菜单出现
        let sheet = app.sheets["分类管理"]
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        
        // 点击添加分类按钮
        let addButton = sheet.buttons["添加分类"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // 等待弹窗出现
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        // 输入新分类名称
        let textField = alert.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("新分类")
        
        // 点击添加按钮
        let confirmButton = alert.buttons["添加"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()
        
        // 等待新分类出现
        let newCategory = app.segmentedControls.buttons["新分类"]
        XCTAssertTrue(newCategory.waitForExistence(timeout: 5), "新分类未出现")
    }
}
