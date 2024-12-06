# iOS ToDo List App

一个功能完整的iOS待办事项应用，支持任务管理、分类筛选、深色模式等特性。

## 功能特点

### 任务管理
- 创建新任务，包含标题、描述、截止时间等信息
- 标记任务完成/未完成状态
- 删除任务
- 任务到期提醒功能

### 分类系统
- 内置"全部"分类视图
- 支持自定义添加/删除分类
- 分类筛选功能
- 分类持久化存储

### 用户界面
- 支持浅色/深色/跟随系统三种主题模式
- 自适应布局，支持各种屏幕尺寸
- 流畅的动画效果
- 直观的手势操作（滑动删除/完成）

### 数据持久化
- 使用 CoreData 存储任务数据
- 使用 UserDefaults 存储用户偏好设置
- 数据迁移和版本控制

## 技术栈

- Swift 5.0+
- UIKit
- CoreData
- UserNotifications
- XCTest (单元测试和UI测试)

## 系统要求

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## 安装说明

1. 克隆仓库：
```bash
git clone https://github.com/yourusername/ToDoList.git
```

2. 打开项目：
```bash
cd ToDoList
open ToDoList.xcodeproj
```

3. 运行项目：
- 选择目标设备或模拟器
- 按下 Cmd + R 运行项目

## 项目结构

```
ToDoList/
├── Managers/
│   ├── CoreDataManager.swift    // CoreData管理器
│   ├── NotificationManager.swift // 通知管理器
│   ├── ThemeManager.swift       // 主题管理器
│   └── CategoryManager.swift    // 分类管理器
├── Models/
│   └── Task.swift              // 任务数据模型
├── Views/
│   └── TaskCell.swift          // 任务列表单元格视图
├── ViewControllers/
│   ├── TaskListViewController.swift    // 任务列表视图控制器
│   └── TaskDetailViewController.swift  // 任务详情视图控制器
└── Supporting Files/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Info.plist
```

## 使用说明

### 添加任务
1. 点击右上角"+"按钮
2. 输入任务标题（必填）
3. 选择任务分类
4. 添加任务描述（可选）
5. 设置截止时间
6. 点击"保存"

### 管理任务
- 左滑任务项显示删除选项
- 右滑任务项显示完成选项
- 点击任务项进入详情编辑界面

### 分类管理
1. 点击左上角列表图标
2. 选择"添加分类"新建分类
3. 选择"删除分类"移除已有分类
4. 使用顶部分段控制器切换分类视图

### 主题切换
1. 点击左上角主题图标
2. 选择需要的主题模式：
   - 浅色
   - 深色
   - 跟随系统

## 测试

项目包含完整的单元测试和UI测试：

```bash
# 运行所有测试
Cmd + U

# 运行特定测试
在测试导航器中选择并运行特定测试用例
```

### 测试覆盖范围
- 单元测试
  - CategoryManager 测试
  - ThemeManager 测试
  - 数据持久化测试
  
- UI测试
  - 任务添加测试
  - 任务删除测试
  - 任务完成状态测试
  - 分类管理测试
  - 主题切换测试

## 贡献指南

1. Fork 项目
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交改动：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

## 版本历史

- 1.0.0
  - 初始版本发布
  - 基本任务管理功能
  - 分类系统
  - 主题切换

## 待办功能

- [ ] iCloud 同步支持
- [ ] 任务优先级设置
- [ ] 任务标签系统
- [ ] 数据导入导出
- [ ] Widget 支持

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE.md](LICENSE.md) 了解详情

## 联系方式

作者：[Your Name]
邮箱：[your.email@example.com]
项目链接：https://github.com/yourusername/ToDoList

## 致谢

- [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) 