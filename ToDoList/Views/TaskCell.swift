import UIKit

class TaskCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)  // 稍微亮一点的背景
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        // 添加更柔和的阴影效果
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1  // 限制为单行
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2  // 限制为两行
        return label
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 添加内容容器
        let shadowContainer = UIView()
        shadowContainer.backgroundColor = .clear
        contentView.addSubview(shadowContainer)
        shadowContainer.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(deadlineLabel)
        
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            shadowContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            shadowContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            shadowContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            containerView.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            deadlineLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            deadlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            deadlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deadlineLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with task: Task) {
        // 设置标题
        titleLabel.text = task.title
        
        // 设置描述（如果有）
        if !task.taskDescription.isEmpty {
            descriptionLabel.text = task.taskDescription
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        // 配置日期格式器
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        // 根据日期设置不同的显示格式
        if Calendar.current.isDateInToday(task.deadline) {
            dateFormatter.dateFormat = "今天 HH:mm"
        } else if Calendar.current.isDateInTomorrow(task.deadline) {
            dateFormatter.dateFormat = "明天 HH:mm"
        } else if Calendar.current.isDate(task.deadline, equalTo: Date(), toGranularity: .weekOfYear) {
            dateFormatter.dateFormat = "EEEE HH:mm"
        } else {
            dateFormatter.dateFormat = "MM-dd HH:mm"
        }
        
        let dateString = dateFormatter.string(from: task.deadline)
        deadlineLabel.text = "[\(task.category)] \(dateString)"
        
        let colors = ThemeManager.shared.getCurrentColors(for: traitCollection)
        
        // 根据任务完成状态设置样式
        if task.isCompleted {
            titleLabel.textColor = colors.completedText
            descriptionLabel.textColor = colors.completedText
            containerView.alpha = 0.9
            containerView.backgroundColor = colors.completedCellBackground
        } else {
            titleLabel.textColor = colors.primaryText
            descriptionLabel.textColor = colors.secondaryText
            containerView.alpha = 1.0
            containerView.backgroundColor = colors.cellBackground
        }
        
        deadlineLabel.textColor = colors.secondaryText
        
        // 更新阴影效果
        containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.05
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // 直接更新颜色，而不是尝试重新配置整个cell
            let colors = ThemeManager.shared.getCurrentColors(for: traitCollection)
            
            if let title = titleLabel.text {
                if title.isEmpty {
                    // 未完成状态
                    titleLabel.textColor = colors.primaryText
                    descriptionLabel.textColor = colors.secondaryText
                    containerView.alpha = 1.0
                    containerView.backgroundColor = colors.cellBackground
                } else {
                    // 完成状态
                    titleLabel.textColor = colors.completedText
                    descriptionLabel.textColor = colors.completedText
                    containerView.alpha = 0.9
                    containerView.backgroundColor = colors.completedCellBackground
                }
            }
            
            deadlineLabel.textColor = colors.secondaryText
            containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.05
        }
    }
} 