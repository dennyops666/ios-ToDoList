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
    
    private let categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["全部", "工作", "生活", "学习"])
        control.selectedSegmentIndex = 0
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
    }
    
    private func setupUI() {
        // 设置背景色为浅灰色
        view.backgroundColor = .systemGray6
        tableView.backgroundColor = .systemGray6
        
        // 设置分段控制器样式
        categorySegmentedControl.backgroundColor = .white
        categorySegmentedControl.selectedSegmentTintColor = .systemBlue
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
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
            categorySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 8),
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
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
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
        currentCategory = categorySegmentedControl.selectedSegmentIndex == 0 ? nil : categories[categorySegmentedControl.selectedSegmentIndex]
        loadTasks()
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
