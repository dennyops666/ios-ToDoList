import UIKit

class TaskDetailViewController: UIViewController {
    private var task: Task?
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "输入任务标题"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 5
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "添加任务描述（可选）"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private let categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: CategoryManager.shared.editableCategories)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    private let prioritySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["低", "中", "高"])
        control.selectedSegmentIndex = 1 // 默认中优先级
        return control
    }()
    
    init(task: Task?) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTextViewDelegate()
        
        if let task = task {
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            datePicker.date = task.deadline
            
            if let categoryIndex = CategoryManager.shared.editableCategories.firstIndex(of: task.category) {
                categorySegmentedControl.selectedSegmentIndex = categoryIndex
            }
            placeholderLabel.isHidden = !task.taskDescription.isEmpty
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleTextField)
        view.addSubview(categorySegmentedControl)
        view.addSubview(descriptionTextView)
        view.addSubview(datePicker)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            categorySegmentedControl.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            datePicker.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupNavigationBar() {
        title = task == nil ? "新建任务" : "编辑任务"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func setupTextViewDelegate() {
        descriptionTextView.delegate = self
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            let alert = UIAlertController(
                title: "错误",
                message: "请输入任务标题",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        let context = CoreDataManager.shared.context
        let taskToSave = task ?? Task(context: context)
        
        taskToSave.title = title
        taskToSave.taskDescription = descriptionTextView.text
        taskToSave.deadline = datePicker.date
        
        let selectedIndex = categorySegmentedControl.selectedSegmentIndex
        let editableCategories = CategoryManager.shared.editableCategories
        
        guard selectedIndex >= 0, selectedIndex < editableCategories.count else {
            taskToSave.category = editableCategories.first ?? "工作"
            CoreDataManager.shared.saveContext()
            NotificationManager.shared.scheduleNotification(for: taskToSave)
            dismiss(animated: true)
            return
        }
        
        taskToSave.category = editableCategories[selectedIndex]
        taskToSave.priority = Int16(prioritySegmentedControl.selectedSegmentIndex)
        taskToSave.isCompleted = false
        
        CoreDataManager.shared.saveContext()
        NotificationManager.shared.scheduleNotification(for: taskToSave)
        
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
} 