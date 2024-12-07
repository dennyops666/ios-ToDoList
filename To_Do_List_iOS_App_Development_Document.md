# ToDo List iOS App 开发文档

## 1. 项目概述

### 1.1 项目背景
在当今快节奏的生活中，人们需要一个简单而高效的工具来管理日常任务。本项目旨在开发一个功能完整、用户友好的iOS待办事项应用，帮助用户更好地组织和管理他们的日常任务。

### 1.2 项目目标
- 开发一个直观易用的待办事项管理应用
- 提供灵活的任务分类和筛选功能
- 支持多种主题模式，提升用户体验
- 实现任务提醒功能，避免遗漏重要事项

### 1.3 核心功能
1. 任务管理
   - 创建、编辑、删除任务
   - 标记任务完成状态
   - 设置任务截止时间
   - 添加任务描述
   
2. 分类系统
   - 默认分类（全部）
   - 自定义分类管理
   - 分类筛选
   - 分类数据持久化

3. 界面定制
   - 浅色/深色主题
   - 系统主题跟随
   - 自适应布局

4. 提醒功能
   - 本地通知提醒
   - 自定义提醒时间
   - 任务到期提醒

### 1.4 技术选型
1. 开发环境
   - Xcode 13.0+
   - iOS 14.0+
   - Swift 5.0+

2. 框架选择
   - UIKit：用户界面开发
   - CoreData：数据持久化
   - UserNotifications：本地通知
   - XCTest：单元测试和UI测试

3. 设计模式
   - MVC架构
   - 单例模式（管理器类）
   - 观察者模式（通知系统）
   - 代理模式（UI交互）

## 2. 详细设计

### 2.1 数据模型设计

#### 2.1.1 Task 模型
swift
class Task: NSManagedObject {
    @NSManaged var id: UUID                // 任务唯一标识符
    @NSManaged var title: String           // 任务标题
    @NSManaged var taskDescription: String // 任务描述
    @NSManaged var deadline: Date          // 截止时间
    @NSManaged var category: String        // 所属分类
    @NSManaged var priority: Int16         // 优先级
    @NSManaged var isCompleted: Bool       // 完成状态
    @NSManaged var createdAt: Date         // 创建时间
    @NSManaged var updatedAt: Date         // 更新时间
}
```

#### 2.1.2 Theme 枚举
```swift
enum Theme: Int {
    case light    // 浅色主题
    case dark     // 深色主题
    case system   // 跟随系统
    
    var colors: ThemeColors { ... }
}

struct ThemeColors {
    let background: UIColor            // 背景色
    let navigationBar: UIColor         // 导航栏颜色
    let cellBackground: UIColor        // 单元格背景色
    let completedCellBackground: UIColor // 已完成任务背景色
    let primaryText: UIColor           // 主要文本颜色
    let secondaryText: UIColor         // 次��文本颜色
    let completedText: UIColor         // 已完成任务文本颜色
    let accentColor: UIColor           // 强调色
}
```

### 2.2 管理器设计

#### 2.2.1 CoreDataManager
```swift
class CoreDataManager {
    static let shared = CoreDataManager()
    private let containerName = "ToDoList"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("无法加载 Core Data 存储: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("保存上下文失败: \(error)")
        }
    }
    
    // CRUD 操作
    func createTask() -> Task
    func fetchTasks(withCategory category: String?) -> [Task]
    func updateTask(_ task: Task)
    func deleteTask(_ task: Task)
}
```

#### 2.2.2 NotificationManager
```swift
class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                // 处理授权结果
            }
    }
    
    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = task.title
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: task.deadline
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

#### 2.2.3 ThemeManager
```swift
class ThemeManager {
    static let shared = ThemeManager()
    private let themeKey = "AppTheme"
    
    var currentTheme: Theme {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: themeKey)
            return Theme(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    func getCurrentColors(for traitCollection: UITraitCollection) -> ThemeColors {
        switch currentTheme {
        case .system:
            return traitCollection.userInterfaceStyle == .dark ? 
                ThemeColors.darkColors : ThemeColors.lightColors
        case .light:
            return ThemeColors.lightColors
        case .dark:
            return ThemeColors.darkColors
        }
    }
}
```

#### 2.2.4 CategoryManager
```swift
class CategoryManager {
    static let shared = CategoryManager()
    private let categoriesKey = "UserCategories"
    
    private(set) var categories: [String] = []
    
    func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: categoriesKey) as? [String] {
            categories = ["全部"] + savedCategories
        } else {
            categories = ["全部", "工作", "生活", "学习"]
            saveCategories()
        }
    }
    
    func addCategory(_ category: String)
    func deleteCategory(_ category: String)
    func saveCategories()
}
```

### 2.3 视图控制器设计

#### 2.3.1 TaskListViewController
主要职责：
- 显示任务列表
- 处理任务筛选
- 管理任务状态
- 响应主题变化

关键���法：
```swift
// 视图生命周期
override func viewDidLoad()
override func viewWillAppear(_ animated: Bool)

// UI设置
private func setupUI()
private func setupNavigationBar()
private func setupTableView()

// 数据管理
private func loadTasks()
private func deleteTask(at indexPath: IndexPath)
private func toggleTaskCompletion(_ task: Task)

// 事件处理
@objc private func addTaskTapped()
@objc private func categoryChanged()
@objc private func themeButtonTapped()
```

#### 2.3.2 TaskDetailViewController
主要职责：
- 任务创建/编辑
- 信息验证
- 日期选择
- 分类选择

关键方法：
```swift
// 初始化
init(task: Task?)

// UI设置
private func setupUI()
private func setupNavigationBar()
private func setupTextViewDelegate()

// 事件处理
@objc private func saveTapped()
@objc private func cancelTapped()

// 数据验证
private func validateInput() -> Bool
```

### 2.4 自定义视图设计

#### 2.4.1 TaskCell
主要职责：
- 显示任务信息
- 处理滑动操作
- 主题适配

关键属性和方法：
```swift
// UI组件
private let containerView: UIView
private let titleLabel: UILabel
private let descriptionLabel: UILabel
private let deadlineLabel: UILabel

// 初始化和设置
override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
private func setupUI()

// 配置方法
func configure(with task: Task)

// 主题适配
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
```

## 3. 测试规范

### 3.1 单元测试

#### 3.1.1 CategoryManagerTests
```swift
class CategoryManagerTests: XCTestCase {
    func testDefaultCategories()
    func testAddCategory()
    func testDeleteCategory()
    func testCannotDeleteAllCategory()
}
```

#### 3.1.2 ThemeManagerTests
```swift
class ThemeManagerTests: XCTestCase {
    func testDefaultTheme()
    func testThemeChange()
    func testThemePersistence()
}
```

#### 3.1.3 CoreDataManagerTests
```swift
class CoreDataManagerTests: XCTestCase {
    func testCreateTask()
    func testFetchTasks()
    func testUpdateTask()
    func testDeleteTask()
}
```

### 3.2 UI测试

#### 3.2.1 TaskManagementTests
```swift
class TaskManagementTests: XCTestCase {
    func testAddTask()
    func testDeleteTask()
    func testCompleteTask()
    func testEditTask()
}
```

#### 3.2.2 CategoryManagementTests
```swift
class CategoryManagementTests: XCTestCase {
    func testAddCategory()
    func testDeleteCategory()
    func testCategoryFilter()
}
```

## 4. 性能优化

### 4.1 数据库优化
- 使用批量操作
- 适当的索引设计
- 惰性加载策略

### 4.2 UI性能优化
- 重用单元格
- 异步图片加载
- 减少主线程阻塞

### 4.3 内存管理
- 及时释放资源
- 避免循环引用
- 监控内存使用

## 5. 安全考虑

### 5.1 数据安全
- 敏感数据加密
- 安全的数据迁移
- 错误处理机制

### 5.2 用户隐私
- 最小权限原则
- 清晰的隐私政策
- 用户数据保护

## 6. 发布流程

### 6.1 版本控制
- Git分支策略
- 版本号规范
- 代码审查流程

### 6.2 测试验证
- 单元测试覆盖
- UI测试验证
- Beta测试反馈

### 6.3 应用发布
- 证书管理
- 构建配置
- App Store 提交

## 7. 维护计划

### 7.1 日常维护
- Bug修复
- 性能监控
- 用户反馈处理

### 7.2 功能迭代
- 新功能规划
- 版本更新
- 兼容性维护

### 7.3 文档更新
- 接口文档
- 使用说明
- 更新日志

## 8. ��目时间线

### 8.1 开发阶段
- 需求分析：1周
- 架构设计：1周
- 核心功能开发：2周
- 界面优化：1周
- 测试修复：1周

### 8.2 测试阶段
- 单元测试：3天
- UI测试：3天
- Beta测试：1周
- 问题修复：3天

### 8.3 发布阶段
- 提交审核：1周
- 正式发布：1天
- 监控反馈：持续

## 9. 风险评估

### 9.1 技术风险
- CoreData迁移
- 系统版本兼容
- 性能瓶颈

### 9.2 项目风险
- 时间延误
- 需求变更
- 资源配置

### 9.3 应对策略
- 预留缓冲时间
- 灵活的架构设计
- 持续的风险评估

## 10. 附录

### 10.1 相关文档
- API文档
- 数据库设计
- UI设计稿

### 10.2 工具资源
- 开发工具清单
- 第三方库列表
- 测试工具集

### 10.3 参考资料
- Apple官方文档
- Swift编程指南
- iOS设计规范
```