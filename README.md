# ToDo List iOS App

## 最新功能

### 任务管理增强
- ✨ 支持任务优先级设置
- 🔄 任务重复周期设置
- 📑 子任务管理
- 🔍 强大的搜索功能
- 🔀 多种排序方式
- 📦 任务归档功能

### 界面优化
- 🎨 自定义主题
- 📱 列表/网格视图切换
- ✋ 拖拽排序
- 💫 流畅动画效果

### 提醒功能
- 🔔 多样化提醒方式
- 🔁 重复提醒设置
- ⏰ 提前提醒
- 📳 声音和振动

### 数据管理
- 💾 数据导入导出
- 📊 CSV格式支持
- 💫 本地备份还原
- 🔒 数据安全保护

### 统计分析
- 📈 完成率统计
- 🥧 分类分布图表
- 📊 优先级分布
- 📉 趋势分析

### Widget支持
- 📱 今日待办Widget
- 🔄 实时更新
- 🎨 主题适配
- ⚡ 快速操作

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

### 任务管理
1. 创建任务时可设置优先级
2. 支持重复任务设置
3. 可添加子任务
4. 支持多种排序方式

### 提醒设置
1. 选择提醒方式
2. 设置提醒时间
3. 配置重复规则
4. 自定义提醒声音

### 数据管理
1. 导出数据
2. 创建备份
3. 恢复备份
4. 导入数据

## 更新日志

### v2.0.0
- 新增任务优先级
- 新增重复任务
- 新增子任务支持
- 新增统计分析
- 新增Widget支持
- 性能优化

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