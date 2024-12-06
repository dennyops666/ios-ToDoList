import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    private init() {
        loadCategories()
    }
    
    private let defaultCategories = ["全部", "工作", "生活", "学习"]
    private let categoriesKey = "UserCategories"
    
    private(set) var categories: [String] = []
    
    // 加载分类
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: categoriesKey) as? [String] {
            categories = ["全部"] + savedCategories
        } else {
            categories = defaultCategories
            saveCategories()
        }
    }
    
    // 保存分类
    private func saveCategories() {
        // 保存时去掉"全部"分类
        let categoriesToSave = Array(categories.dropFirst())
        UserDefaults.standard.set(categoriesToSave, forKey: categoriesKey)
    }
    
    // 添加分类
    func addCategory(_ category: String) {
        guard !categories.contains(category) else { return }
        categories.append(category)
        saveCategories()
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }
    
    // 删除分类
    func deleteCategory(_ category: String) {
        guard category != "全部",
              let index = categories.firstIndex(of: category) else { return }
        categories.remove(at: index)
        saveCategories()
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }
    
    // 获取可编辑的分类（不包括"全部"）
    var editableCategories: [String] {
        Array(categories.dropFirst())
    }
}

extension Notification.Name {
    static let categoriesDidChange = Notification.Name("CategoriesDidChange")
} 