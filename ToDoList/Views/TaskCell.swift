import UIKit

class TaskCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        // 添加阴影效果
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        containerView.addSubview(deadlineLabel)
        
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
            
            deadlineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            deadlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            deadlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deadlineLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        deadlineLabel.text = "[\(task.category)] 截止日期: \(dateFormatter.string(from: task.deadline))"
        
        // 根据任务完成状态设置样式
        if task.isCompleted {
            titleLabel.textColor = .systemGray
            containerView.alpha = 0.7
            containerView.backgroundColor = .systemGray6
        } else {
            titleLabel.textColor = .label
            containerView.alpha = 1.0
            containerView.backgroundColor = .white
        }
    }
} 