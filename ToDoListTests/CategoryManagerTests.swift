import XCTest
@testable import ToDoList

class CategoryManagerTests: XCTestCase {
    var categoryManager: CategoryManager!
    
    override func setUp() {
        super.setUp()
        // 清除之前的用户默认值
        UserDefaults.standard.removeObject(forKey: "UserCategories")
        categoryManager = CategoryManager.shared
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "UserCategories")
        super.tearDown()
    }
    
    func testDefaultCategories() {
        XCTAssertEqual(categoryManager.categories.first, "全部")
        XCTAssertTrue(categoryManager.categories.contains("工作"))
        XCTAssertTrue(categoryManager.categories.contains("生活"))
        XCTAssertTrue(categoryManager.categories.contains("学习"))
    }
    
    func testAddCategory() {
        let newCategory = "测试分类"
        categoryManager.addCategory(newCategory)
        
        XCTAssertTrue(categoryManager.categories.contains(newCategory))
        XCTAssertTrue(categoryManager.editableCategories.contains(newCategory))
    }
    
    func testDeleteCategory() {
        let categoryToDelete = "生活"
        categoryManager.deleteCategory(categoryToDelete)
        
        XCTAssertFalse(categoryManager.categories.contains(categoryToDelete))
        XCTAssertFalse(categoryManager.editableCategories.contains(categoryToDelete))
    }
    
    func testCannotDeleteAllCategory() {
        categoryManager.deleteCategory("全部")
        XCTAssertTrue(categoryManager.categories.contains("全部"))
    }
    
    func testEditableCategories() {
        XCTAssertFalse(categoryManager.editableCategories.contains("全部"))
    }
} 