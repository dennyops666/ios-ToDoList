import XCTest
@testable import ToDoList

class ThemeManagerTests: XCTestCase {
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        // 清除所有用户默认值
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.synchronize()
        themeManager = ThemeManager.shared
    }
    
    override func tearDown() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.synchronize()
        super.tearDown()
    }
    
    func testDefaultTheme() {
        // 清除所有设置
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.synchronize()
        
        // 创建新实例并验证默认主题
        let newThemeManager = ThemeManager.shared
        XCTAssertEqual(newThemeManager.currentTheme, .system, "默认主题应该是跟随系统")
        
        // 验证 UserDefaults 中没有保存值
        XCTAssertFalse(UserDefaults.standard.contains(key: "AppTheme"), "初始状态不应该有保存的��题设置")
    }
    
    func testThemeChange() {
        // 设置主题为深色
        themeManager.currentTheme = .dark
        XCTAssertEqual(themeManager.currentTheme, .dark, "主题应该被设置为深色")
        XCTAssertTrue(UserDefaults.standard.contains(key: "AppTheme"), "主题设置应该被保存")
        
        // 设置主题为浅色
        themeManager.currentTheme = .light
        XCTAssertEqual(themeManager.currentTheme, .light, "主题应该被设置为浅色")
    }
    
    func testThemePersistence() {
        // 设置主题
        themeManager.currentTheme = .dark
        UserDefaults.standard.synchronize()
        
        // 重新创建实例来测试持久化
        let newThemeManager = ThemeManager.shared
        XCTAssertEqual(newThemeManager.currentTheme, .dark, "主题设置应该被持久化")
    }
} 