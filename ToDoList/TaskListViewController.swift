import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    private var tasks: [Task] = []
    private var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTasks()
    }
    
    private func setupUI() {
        title = "所有任务"
        
        // 添加任务按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskButtonTapped)
        )
        
        // 添加分类按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: selectedCategory?.name ?? "所有分类",
            style: .plain,
            target: self,
            action: #selector(categoryButtonTapped)
        )
        
        // 注册cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }
    
    private func loadTasks() {
        if let category = selectedCategory {
            // 获取特定分类的任务
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == %@", category)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "dueDate", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            do {
                tasks = try CoreDataManager.shared.context.fetch(fetchRequest)
            } catch {
                print("Error fetching tasks: \(error)")
                tasks = []
            }
        } else {
            // 获取所有任务
            tasks = CoreDataManager.shared.fetchTasks()
        }
        tableView.reloadData()
        
        // 更新标题
        title = selectedCategory?.name ?? "所有任务"
    }
    
    @objc private func addTaskButtonTapped() {
        let taskDetailVC = TaskDetailViewController()
        taskDetailVC.delegate = self
        let navigationController = UINavigationController(rootViewController: taskDetailVC)
        present(navigationController, animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        let actionSheet = UIAlertController(title: "选择分类", message: nil, preferredStyle: .actionSheet)
        
        // 添加"所有任务"选项
        actionSheet.addAction(UIAlertAction(title: "所有任务", style: .default) { [weak self] _ in
            self?.selectedCategory = nil
            self?.loadTasks()
        })
        
        // 添加现有分类
        let categories = CoreDataManager.shared.fetchCategories()
        for category in categories {
            actionSheet.addAction(UIAlertAction(title: category.name, style: .default) { [weak self] _ in
                self?.selectedCategory = category
                self?.loadTasks()
            })
        }
        
        // 添加管理分类选项
        actionSheet.addAction(UIAlertAction(title: "管理分类...", style: .default) { [weak self] _ in
            let categoryVC = CategoryListViewController()
            self?.navigationController?.pushViewController(categoryVC, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 对于iPad，需要设置弹出位置
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.leftBarButtonItem
        }
        
        present(actionSheet, animated: true)
    }
}

// MARK: - TaskDetailViewControllerDelegate
extension TaskListViewController: TaskDetailViewControllerDelegate {
    func taskDetailViewController(_ controller: TaskDetailViewController, didSaveTask task: Task) {
        if let selectedCategory = selectedCategory {
            // 如果有选中的分类，只有当任务属于该分类时才显示
            if task.category == selectedCategory {
                tasks.insert(task, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        } else {
            // 如果没有选中分类，直接显示新任务
            tasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
}

// MARK: - UITableView DataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        if let category = task.category {
            content.secondaryText = category.name
        }
        cell.contentConfiguration = content
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableView Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        let detailVC = TaskDetailViewController(task: task)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 删除操作
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            self?.deleteTask(at: indexPath)
            completion(true)
        }
        
        // 完成操作
        let task = tasks[indexPath.row]
        let completeTitle = task.isCompleted ? "未完成" : "完成"
        let completeAction = UIContextualAction(style: .normal, title: completeTitle) { [weak self] (_, _, completion) in
            self?.toggleTaskCompletion(at: indexPath)
            completion(true)
        }
        completeAction.backgroundColor = task.isCompleted ? .systemOrange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        CoreDataManager.shared.deleteTask(task)
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.isCompleted.toggle()
        CoreDataManager.shared.updateTask(task)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
