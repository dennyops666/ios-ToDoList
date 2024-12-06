import XCTest
@testable import ToDoList

class ThemeManagerTests: XCTestCase {
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "AppTheme")
        themeManager = ThemeManager.shared
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "AppTheme")
        super.tearDown()
    }
    
    func testDefaultTheme() {
        XCTAssertEqual(themeManager.currentTheme, .system)
    }
    
    func testThemeChange() {
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.currentTheme, .dark)
        
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.currentTheme, .light)
    }
    
    func testThemePersistence() {
        themeManager.currentTheme = .dark
        
        // 重新创建实例来测试持久化
        let newThemeManager = ThemeManager.shared
        XCTAssertEqual(newThemeManager.currentTheme, .dark)
    }
} 