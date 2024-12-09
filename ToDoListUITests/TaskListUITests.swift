import XCTest

class TaskListUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // 首先定义清理任务的方法
    private func clearExistingTasks() {
        // 获取所有任务单元格
        let cells = app.tables.cells
        
        // 循环删除所有任务
        while cells.count > 0 {
            let firstCell = cells.firstMatch
            if firstCell.exists {
                firstCell.swipeLeft()
                
                let deleteButton = app.buttons["删除"]
                if deleteButton.waitForExistence(timeout: 5) {
                    deleteButton.tap()
                    sleep(1) // 等待删除动画完成
                } else {
                    break
                }
            } else {
                break
            }
            sleep(1) // 等待UI更新
        }
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // 添加启动参数，用于清理测试数据
        app.launchArguments = ["UI-Testing"]
        
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddNewTask() {
        // 点击添加按钮
        let addButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // 等待任务编辑界面出现
        let titleTextField = app.textFields["任务名称"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5))
        
        // 输入任务信息
        titleTextField.tap()
        titleTextField.typeText("基本任务测试")
        
        // 添加备注
        let notesTextView = app.textViews.firstMatch
        notesTextView.tap()
        notesTextView.typeText("这是一个基本任务的测试备注")
        
        // 点击保存按钮
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
        
        // 验证任务是否显示在列表中
        let taskCell = app.tables.cells.containing(.staticText, identifier: "基本任务测试").firstMatch
        XCTAssertTrue(taskCell.waitForExistence(timeout: 5))
    }
    
    
    func testAddTaskWithCategory() {
        // 清理现有数据
        clearExistingTasks()
        
        // 1. 创建分类
        addCategory(name: "测试分类A")
        
        // 2. 创建任务并分配分类
        addTaskWithCategory(title: "分类A的测试任务", category: "测试分类A")
        
        // 3. 验证任务创建成功
        verifyTaskExists(title: "分类A的测试任务", category: "测试分类A")
    }
    
    // 辅助方法：添加分类
    private func addCategory(name: String) {
        // 点击分类按钮
        let categoryButton = app.navigationBars.buttons["所有分类"]
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 10), "找不到'所有分类'按钮")
        categoryButton.tap()
        
        sleep(2)
        
        // 打印所有可见按钮，帮助调试
        print("所有可见按钮:")
        app.buttons.allElementsBoundByIndex.forEach { button in
            print("Button: \(button.label)")
        }
        
        // 点击管理分类按钮
        let manageButton = app.sheets.buttons["管理分类..."].firstMatch
        XCTAssertTrue(manageButton.waitForExistence(timeout: 5), "找不到管理分类按钮")
        manageButton.tap()
        
        sleep(2)
        
        // 点击添加按钮
        let addButton = app.navigationBars["分类管理"].buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10), "找不到添加按钮")
        addButton.tap()
        
        sleep(2)
        
        // 输入分类名称
        let textField = app.textFields["分类名称"]
        XCTAssertTrue(textField.waitForExistence(timeout: 10), "找不到分类名称输入框")
        textField.tap()
        textField.typeText(name)
        
        sleep(1)
        
        // 输入分类名称后，打印当前界面的所有按钮
        print("当前界面所有按钮:")
        app.buttons.allElementsBoundByIndex.forEach { button in
            print("Button: \(button.label)")
        }
        
        // 打印导航栏按钮
        print("导航栏按钮:")
        app.navigationBars.buttons.allElementsBoundByIndex.forEach { button in
            print("Nav Button: \(button.label)")
        }
        
        // 尝试多种可能的保存按钮标识符和位置
        let saveButtons = [
            app.navigationBars.buttons["添加"],
            app.navigationBars.buttons["Add"],
            app.navigationBars.buttons["保存"],
            app.navigationBars.buttons["Save"],
            app.buttons["添加"],
            app.buttons["Add"],
            app.buttons["保存"],
            app.buttons["Save"],
            // 尝试使用索引
            app.navigationBars.buttons.element(boundBy: 1),
            // 尝试使用谓词匹配
            app.buttons.matching(NSPredicate(format: "label CONTAINS '保存' OR label CONTAINS 'Save' OR label CONTAINS '添加' OR label CONTAINS 'Add'")).firstMatch
        ]
        
        sleep(2) // 给UI一些时间来稳定
        
        var saveButton: XCUIElement?
        for (index, button) in saveButtons.enumerated() {
            print("尝试查找保存按钮选项 \(index + 1)")
            if button.waitForExistence(timeout: 2) {
                print("找到可能的保存按钮: \(button.label)")
                saveButton = button
                break
            }
        }
        
        guard let saveButton = saveButton else {
            // 如果找不到保存按钮，打印更多调试信息
            print("无法找到保存按钮。当前界面层次结构:")
            print(app.debugDescription)
            XCTFail("找不到保存按钮")
            return
        }
        
        print("准备点击保存按钮: \(saveButton.label)")
        saveButton.tap()
        sleep(2)
        
        // 等待返回到分类列表
        let categoryList = app.navigationBars["分类管理"]
        XCTAssertTrue(categoryList.waitForExistence(timeout: 10), "未能返回到分类列表")
        
        // 点击返回按钮
        let backButton = app.navigationBars["分类管理"].buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "找不到返回按钮")
        backButton.tap()
        
        sleep(2)
    }
    
    // 辅助方法：添加带分类的任务
    private func addTaskWithCategory(title: String, category: String) {
        // 点击添加任务按钮
        let addButton = app.navigationBars.buttons["Add"]
        guard addButton.waitForExistence(timeout: 10) else {
            XCTFail("找不到添加任务按钮")
            return
        }
        addButton.tap()
        sleep(1)
        
        // 输入任务标题
        let titleField = app.textFields["任务名称"]
        guard titleField.waitForExistence(timeout: 10) else {
            XCTFail("找不到任务名称输入框")
            return
        }
        titleField.tap()
        titleField.typeText(title)
        sleep(1)
        
        // 选择分类
        let categoryButton = app.buttons["选择分类"]
        guard categoryButton.waitForExistence(timeout: 10) else {
            XCTFail("找不到选择分类按钮")
            return
        }
        categoryButton.tap()
        sleep(2)
        
        // 打印所有可用的分类按钮
        print("Available categories:")
        app.sheets["选择分类"].buttons.allElementsBoundByIndex.forEach { button in
            print("Category: \(button.label)")
        }
        
        let categoryOption = app.sheets["选择分类"].buttons.matching(NSPredicate(format: "label CONTAINS %@", category)).firstMatch
        guard categoryOption.waitForExistence(timeout: 10) else {
            XCTFail("找不到指定的分类：\(category)")
            return
        }
        categoryOption.tap()
        sleep(1)
        
        // 保存任务
        let saveButton = app.navigationBars.buttons["Save"]
        guard saveButton.waitForExistence(timeout: 10) else {
            XCTFail("找不到保存按钮")
            return
        }
        saveButton.tap()
        sleep(2)
    }
    
    // 辅助方法：验证任务是否存在
    private func verifyTaskExists(title: String, category: String) {
        let taskCell = app.tables.cells.containing(.staticText, identifier: title).firstMatch
        XCTAssertTrue(taskCell.waitForExistence(timeout: 10), "找不到创建的任务：\(title)")
        
        if taskCell.exists {
            let categoryLabel = taskCell.staticTexts[category]
            XCTAssertTrue(categoryLabel.exists, "任务的分类标签未显示：\(category)")
        }
    }
    
    func testFilterTasksByCategory() {
        // 确保清理现有数据
        clearExistingTasks()
        
        // 1. 创建分类
        let categoryButton = app.navigationBars.buttons.matching(identifier: "所有分类").firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 10), "找不到'所有分类'按钮")
        categoryButton.tap()
        
        sleep(2) // 等待 sheet 显示
        
        // 打印所有可用的按钮，帮助调试
        print("Available sheet buttons:")
        app.sheets.allElementsBoundByIndex.forEach { sheet in
            print("Sheet: \(sheet.debugDescription)")
            sheet.buttons.allElementsBoundByIndex.forEach { button in
                print("Sheet Button: \(button.label)")
            }
        }
        
        // 使用更灵活的方式查找管理分类按钮
        let possibleManageButtons = [
            app.sheets.buttons["管理分类..."],
            app.sheets.buttons["管理分类"],
            app.sheets.buttons.matching(NSPredicate(format: "label CONTAINS '管理分类'")).firstMatch
        ]
        
        var manageButton: XCUIElement?
        for button in possibleManageButtons {
            if button.waitForExistence(timeout: 5) {
                manageButton = button
                break
            }
        }
        
        guard let manageButton = manageButton else {
            XCTFail("找不到任何管理分类按钮")
            return
        }
        
        manageButton.tap()
        sleep(2)
        
        // 点击添加按钮
        let addCategoryButton = app.navigationBars["分类管理"].buttons["Add"]
        XCTAssertTrue(addCategoryButton.waitForExistence(timeout: 10), "找不到添加分类按钮")
        addCategoryButton.tap()
        
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 10), "找不到分类名称输入框")
        textField.tap()
        textField.typeText("测试分类B")
        
        let addButton = app.buttons["添加"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10), "找不到'添加'按钮")
        addButton.tap()
        
        sleep(2) // 等待分类创建完成
        
        // 返回主界面
        let backButton = app.navigationBars["分类管理"].buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 10), "找不到返回按钮")
        backButton.tap()
        
        sleep(2) // 等待返回动画完成
        
        // 2. 创建测试任务
        let addTaskButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 10), "找不到添加任务按钮")
        addTaskButton.tap()
        
        let titleTextField = app.textFields["任务名称"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 10), "找不到任务名称输入框")
        titleTextField.tap()
        titleTextField.typeText("分类B的测试任务")
        
        // 选择分类
        let selectCategoryButton = app.buttons["选择分类"]
        XCTAssertTrue(selectCategoryButton.waitForExistence(timeout: 10), "找不到'选择分类'按钮")
        selectCategoryButton.tap()
        
        sleep(2) // 等待分类选择表出现
        
        // 打印所有可用的分类按钮
        print("Available category buttons:")
        app.sheets["选择分类"].buttons.allElementsBoundByIndex.forEach { button in
            print("Category Button: \(button.label)")
        }
        
        let categoryBButton = app.sheets["选择分类"].buttons.matching(NSPredicate(format: "label CONTAINS '测试分类B'")).firstMatch
        XCTAssertTrue(categoryBButton.exists, "找不到'测试分类B'按钮")
        categoryBButton.tap()
        
        sleep(1)
        
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 10), "找不到保存按钮")
        saveButton.tap()
        
        sleep(2)
        
        // 3. 测试分类筛选
        categoryButton.tap()
        
        sleep(2) // 等待分类选择表出现
        
        let filterCategoryButton = app.sheets["选择分类"].buttons.matching(NSPredicate(format: "label CONTAINS '测试分类B'")).firstMatch
        XCTAssertTrue(filterCategoryButton.exists, "找不到'测试分类B'筛选按钮")
        filterCategoryButton.tap()
        
        sleep(2)
        
        // 4. 验证筛选结果
        let taskCell = app.tables.cells.containing(.staticText, identifier: "分类B的测试任务").firstMatch
        XCTAssertTrue(taskCell.waitForExistence(timeout: 10), "找不到筛选后的任务")
        XCTAssertEqual(app.tables.cells.count, 1, "筛选后应该只显示一个任务")
    }
    
    func testDeleteTask() {
        // 首先添加一个任务
        testAddNewTask()
        
        // 获取任务cell并左滑
        let cell = app.tables.cells.containing(.staticText, identifier: "基本任务测试").firstMatch
        XCTAssertTrue(cell.exists)
        cell.swipeLeft()
        
        // 等待删除按钮出现并点击
        let deleteButton = app.buttons["删除"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        
        // 验证任务是否已被删除
        XCTAssertFalse(cell.exists)
    }
    
    func testToggleTaskCompletion() {
        // 首先添加一个任务
        testAddNewTask()
        
        // 获取任务cell并左滑
        let cell = app.tables.cells.containing(.staticText, identifier: "基本任务测试").firstMatch
        XCTAssertTrue(cell.exists)
        cell.swipeLeft()
        
        // 点击完成按钮
        let completeButton = app.buttons["完成"]
        XCTAssertTrue(completeButton.waitForExistence(timeout: 5))
        completeButton.tap()
        
        // 验证任务状态已更新
        let completedCell = app.tables.cells.containing(.staticText, identifier: "基本任务测试").firstMatch
        XCTAssertTrue(completedCell.exists)
        
        // 再次左滑并点击"未完成"
        completedCell.swipeLeft()
        let uncompleteButton = app.buttons["未完成"]
        XCTAssertTrue(uncompleteButton.waitForExistence(timeout: 5))
        uncompleteButton.tap()
    }
}

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
} 