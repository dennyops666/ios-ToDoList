import UIKit
import CoreData

class TaskListViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        return table
    }()
    
    private var tasks: [Task] = []
    private var currentCategory: String? = nil
    private let categories = ["全部", "工作", "生活", "学习"]
    
    private var categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: CategoryManager.shared.categories)
        control.selectedSegmentIndex = 0
        
        // 设置基本样式
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        
        control.setTitleTextAttributes(normalTextAttributes, for: .normal)
        control.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // 设置背景和选中状态的颜色
        control.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        control.selectedSegmentTintColor = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        
        // 设置圆角和边框
        control.layer.cornerRadius = 8
        control.layer.masksToBounds = true
        
        // 添加阴影效果
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOffset = CGSize(width: 0, height: 2)
        control.layer.shadowRadius = 4
        control.layer.shadowOpacity = 0.1
        
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadTasks()
        
        // 添加通知观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
        
        // 添加主题切换观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: .themeChanged,
            object: nil
        )
        
        // 添加分类变化观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesDidChange),
            name: .categoriesDidChange,
            object: nil
        )
    }
    
    private func setupUI() {
        // 设置背景色为深色系
        view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)  // 更深的灰色背景
        tableView.backgroundColor = view.backgroundColor
        
        view.addSubview(tableView)
        view.addSubview(categorySegmentedControl)
        
        // 设置代理
        tableView.delegate = self
        tableView.dataSource = self
        
        // 移除表格分割线
        tableView.separatorStyle = .none
        
        // 禁用自动转换约束
        tableView.translatesAutoresizingMaskIntoConstraints = false
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categorySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        title = "待办事项"
        
        // 设置导航栏样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.currentTheme.colors.navigationBar
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.currentTheme.colors.primaryText]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // 添加主题切换按钮
        let themeButton = UIBarButtonItem(
            image: UIImage(systemName: "circle.lefthalf.filled"),
            style: .plain,
            target: self,
            action: #selector(themeButtonTapped)
        )
        
        // 添加分类管理按钮
        let categoryButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(categoryManageTapped)
        )
        
        navigationItem.leftBarButtonItems = [themeButton, categoryButton]
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )
    }
    
    private func loadTasks() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let category = currentCategory {
            fetchRequest.predicate = NSPredicate(format: "category == %@", category)
        }
        
        do {
            tasks = try CoreDataManager.shared.context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("加载任务失败: \(error)")
        }
    }
    
    @objc private func addTaskTapped() {
        let addTaskVC = TaskDetailViewController(task: nil)
        let nav = UINavigationController(rootViewController: addTaskVC)
        present(nav, animated: true)
    }
    
    @objc private func contextDidSave(_ notification: Notification) {
        loadTasks()
    }
    
    @objc private func categoryChanged() {
        let selectedIndex = categorySegmentedControl.selectedSegmentIndex
        let categories = CategoryManager.shared.categories
        
        // 安全检查
        guard selectedIndex >= 0, selectedIndex < categories.count else {
            print("无效的分类索引")
            return
        }
        
        currentCategory = selectedIndex == 0 ? nil : categories[selectedIndex]
        loadTasks()
    }
    
    @objc private func themeButtonTapped() {
        let alert = UIAlertController(title: "选择主题", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "浅色", style: .default) { _ in
            ThemeManager.shared.currentTheme = .light
        })
        alert.addAction(UIAlertAction(title: "深色", style: .default) { _ in
            ThemeManager.shared.currentTheme = .dark
        })
        alert.addAction(UIAlertAction(title: "跟随系统", style: .default) { _ in
            ThemeManager.shared.currentTheme = .system
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            themeChanged()
        }
    }
    
    private func updateInterfaceStyle() {
        if ThemeManager.shared.currentTheme == .system {
            themeChanged()
        }
    }
    
    @objc private func themeChanged() {
        let colors = ThemeManager.shared.getCurrentColors(for: traitCollection)
        
        // 更新背景色
        view.backgroundColor = colors.background
        tableView.backgroundColor = colors.background
        
        // 更新分段控制器样式
        categorySegmentedControl.backgroundColor = colors.cellBackground
        categorySegmentedControl.selectedSegmentTintColor = colors.accentColor
        
        categorySegmentedControl.setTitleTextAttributes([
            .foregroundColor: colors.secondaryText,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        
        categorySegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
        
        // 更新导航栏样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.navigationBar
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: colors.primaryText]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = colors.accentColor
        
        // 刷新表格
        tableView.reloadData()
    }
    
    @objc private func categoryManageTapped() {
        let alert = UIAlertController(title: "分类管理", message: nil, preferredStyle: .actionSheet)
        
        // 添加新分类
        alert.addAction(UIAlertAction(title: "添加分类", style: .default) { [weak self] _ in
            self?.showAddCategoryAlert()
        })
        
        // 删除现有分类
        for category in CategoryManager.shared.editableCategories {
            alert.addAction(UIAlertAction(title: "删除: \(category)", style: .destructive) { [weak self] _ in
                self?.deleteCategory(category)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAddCategoryAlert() {
        let alert = UIAlertController(
            title: "添加分类",
            message: "请输入新分类名称",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "分类名称"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            if let categoryName = alert.textFields?.first?.text,
               !categoryName.isEmpty {
                CategoryManager.shared.addCategory(categoryName)
                self?.updateCategoryControl()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func deleteCategory(_ category: String) {
        // 如果删除的是当前选中的分类，切换到"全部"
        if category == CategoryManager.shared.categories[categorySegmentedControl.selectedSegmentIndex] {
            categorySegmentedControl.selectedSegmentIndex = 0
            currentCategory = nil
        }
        
        CategoryManager.shared.deleteCategory(category)
        updateCategoryControl()
        loadTasks()
    }
    
    @objc private func categoriesDidChange() {
        updateCategoryControl()
    }
    
    private func updateCategoryControl() {
        let categories = CategoryManager.shared.categories
        let currentIndex = categorySegmentedControl.selectedSegmentIndex
        
        // 重新创建分段控制器
        let newControl = UISegmentedControl(items: categories)
        newControl.selectedSegmentIndex = min(currentIndex, categories.count - 1)
        
        // 复制原有样式
        newControl.backgroundColor = categorySegmentedControl.backgroundColor
        newControl.selectedSegmentTintColor = categorySegmentedControl.selectedSegmentTintColor
        newControl.setTitleTextAttributes(
            categorySegmentedControl.titleTextAttributes(for: .normal),
            for: .normal
        )
        newControl.setTitleTextAttributes(
            categorySegmentedControl.titleTextAttributes(for: .selected),
            for: .selected
        )
        
        // 替换旧控件
        newControl.translatesAutoresizingMaskIntoConstraints = false
        newControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        
        categorySegmentedControl.removeFromSuperview()
        view.addSubview(newControl)
        
        // 重新设置约束
        NSLayoutConstraint.activate([
            newControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            newControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newControl.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 更新引用
        categorySegmentedControl = newControl
    }
    
    // 添加滑动删除和完成功能
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            guard let self = self else { return }
            let taskToDelete = self.tasks[indexPath.row]
            CoreDataManager.shared.context.delete(taskToDelete)
            CoreDataManager.shared.saveContext()
            self.loadTasks()
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        let title = task.isCompleted ? "未完成" : "完成"
        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completion in
            guard let self = self else { return }
            task.isCompleted = !task.isCompleted
            CoreDataManager.shared.saveContext()
            self.loadTasks()
            completion(true)
        }
        action.backgroundColor = task.isCompleted ? .systemOrange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
} 
