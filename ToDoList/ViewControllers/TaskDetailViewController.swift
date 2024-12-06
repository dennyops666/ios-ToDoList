import UIKit

class TaskDetailViewController: UIViewController {
    private var task: Task?
    private let categories = ["工作", "生活", "学习"] // 预设的分类选项
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "任务标题"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    private let categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["工作", "生活", "学习"])
        control.selectedSegmentIndex = 0 // 默认选择第一个分类
        return control
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        return picker
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
        
        if let task = task {
            // 如果是编辑现有任务，填充现有数据
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            datePicker.date = task.deadline
            if let categoryIndex = categories.firstIndex(of: task.category) {
                categorySegmentedControl.selectedSegmentIndex = categoryIndex
            }
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
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        let context = CoreDataManager.shared.context
        let taskToSave = task ?? Task(context: context)
        
        taskToSave.title = titleTextField.text ?? ""
        taskToSave.taskDescription = descriptionTextView.text
        taskToSave.deadline = datePicker.date
        taskToSave.category = categories[categorySegmentedControl.selectedSegmentIndex]
        taskToSave.priority = 0
        taskToSave.isCompleted = false
        
        CoreDataManager.shared.saveContext()
        
        NotificationManager.shared.scheduleNotification(for: taskToSave)
        
        dismiss(animated: true)
    }
} 