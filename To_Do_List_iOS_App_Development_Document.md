
# ToDo List iOS App 开发文档

## 1. 项目概述

### 1.1 项目目标
开发一个功能完整的iOS待办事项应用，帮助用户管理日常任务，支持分类管理、主题切换等功能。

### 1.2 核心功能
- 任务的增删改查
- 自定义分类管理
- 主题模式切换
- 任务提醒功能

### 1.3 技术选型
- 开发语言：Swift 5.0+
- 界面框架：UIKit
- 数据存储：CoreData
- 本地通知：UserNotifications
- 测试框架：XCTest

## 2. 架构设计

### 2.1 整体架构
采用 MVC 架构模式：
- Model: 数据模型和业务逻辑
- View: 用户界面元素
- Controller: 业务流程控制

### 2.2 模块划分
```
├── Models
│   └── Task.swift (任务数据模型)
├── Views
│   └── TaskCell.swift (任务列表单元格)
├── ViewControllers
│   ├── TaskListViewController.swift (任务列表)
│   └── TaskDetailViewController.swift (任务详情)
└── Managers
    ├── CoreDataManager.swift (数据管理)
    ├── NotificationManager.swift (通知管理)
    ├── ThemeManager.swift (主题管理)
    └── CategoryManager.swift (分类管理)
```

## 3. 数据模型

### 3.1 Task 实体
```swift
class Task: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var taskDescription: String
    @NSManaged var deadline: Date
    @NSManaged var category: String
    @NSManaged var priority: Int16
    @NSManaged var isCompleted: Bool
}
```

### 3.2 CoreData Schema
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0">
    <entity name="Task" representedClassName="Task">
        <attribute name="id" attributeType="UUID"/>
        <attribute name="title" attributeType="String"/>
        <attribute name="taskDescription" attributeType="String"/>
        <attribute name="deadline" attributeType="Date"/>
        <attribute name="category" attributeType="String"/>
        <attribute name="priority" attributeType="Integer 16"/>
        <attribute name="isCompleted" attributeType="Boolean"/>
    </entity>
</model>
```

## 4. 管理器实现

### 4.1 CoreDataManager
负责数据的持久化存储和管理：
```swift
class CoreDataManager {
    static let shared = CoreDataManager()
    
    var context: NSManagedObjectContext { ... }
    
    func saveContext() { ... }
    func fetchTasks() -> [Task] { ... }
}
```

### 4.2 NotificationManager
处理本地通知相关功能：
```swift
class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() { ... }
    func scheduleNotification(for task: Task) { ... }
    func removeNotification(for task: Task) { ... }
}
```

### 4.3 ThemeManager
管理应用主题：
```swift
class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: Theme { get set }
    var colors: ThemeColors { get }
}
```

### 4.4 CategoryManager
管理任务分类：
```swift
class CategoryManager {
    static let shared = CategoryManager()
    
    var categories: [String] { get }
    
    func addCategory(_ category: String) { ... }
    func deleteCategory(_ category: String) { ... }
}
```

## 5. 视图控制器实现

### 5.1 TaskListViewController
任务列表主界面：
- 显示任务列表
- 分类筛选
- 任务状态管理
- 主题切换

### 5.2 TaskDetailViewController
任务详情界面：
- 任务信息编辑
- 分类选择
- 截止时间设置
- 任务描述编辑

## 6. 自定义视图

### 6.1 TaskCell
任务列表单元格：
- 显示任务信息
- 支持滑动操作
- 自适应主题变化

## 7. 测试规范

### 7.1 单元测试
- CategoryManager 测试
- ThemeManager 测试
- CoreDataManager 测试

### 7.2 UI测试
- 任务管理功能测试
- 分类管理测试
- 主题切换测试

## 8. 开发规范

### 8.1 代码规范
- 遵循 Swift 官方代码规范
- 使用 // MARK: 标记代码块
- 必要的注释说明

### 8.2 命名规范
- 类名：大驼峰命名
- 变量/方法：小驼峰命名
- 常量：使用 static let

### 8.3 文件组织
- 按功能模块分组
- 相关文件放在同一目录
- 清晰的目录结构

## 9. 发布流程

### 9.1 版本控制
- 使用 Git 进行版本控制
- 遵循语义化版本规范
- 保持提交信息清晰

### 9.2 测试验证
- 运行所有单元测试
- 执行 UI 测试
- 手动功能测试

### 9.3 打包发布
- 更新版本号
- 生成发布说明
- 归档项目

## 10. 维护计划

### 10.1 Bug修复
- 及时响应用户反馈
- 修复已知问题
- 更新测试用例

### 10.2 功能迭代
- 优先级功能
- 标签系统
- iCloud同步
- Widget支持

### 10.3 性能优化
- 内存使用优化
- 启动时间优化
- 数据库查询优化
