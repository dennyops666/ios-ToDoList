import XCTest

class ThemeUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testThemeSwitch() {
        // 打开主题设置
        app.navigationBars["待办事项"].buttons["主题设置"].tap()
        
        // 切换到深色主题
        app.buttons["深色"].tap()
        
        // 验证深色主题已应用
        let darkBackground = app.otherElements["main_background"].value as? String
        XCTAssertEqual(darkBackground, "dark")
        
        // 切换到浅色主题
        app.buttons["浅色"].tap()
        
        // 验证浅色主题已应用
        let lightBackground = app.otherElements["main_background"].value as? String
        XCTAssertEqual(lightBackground, "light")
    }
    
    func testCustomThemeColors() {
        // 打开主题设置
        app.navigationBars["待办事项"].buttons["主题设置"].tap()
        
        // 选择自定义主题
        app.buttons["自定义"].tap()
        
        // 设置主色调
        let primaryColorPicker = app.colorWells["primary_color"]
        primaryColorPicker.tap()
        // 模拟选择颜色
        
        // 保存设置
        app.buttons["保存"].tap()
        
        // 验证自定义主题已应用
        XCTAssertTrue(app.otherElements["custom_theme"].exists)
    }
} 