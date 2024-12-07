import Foundation
import CoreData
import UIKit

enum TaskPriority: Int16 {
    case low = 0
    case medium = 1
    case high = 2
    
    var color: UIColor {
        switch self {
        case .low: return .systemBlue
        case .medium: return .systemOrange
        case .high: return .systemRed
        }
    }
}

enum RepeatType: Int16 {
    case none = 0
    case daily
    case weekly
    case monthly
}

@objc(Task)
public class Task: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var taskDescription: String
    @NSManaged var deadline: Date
    @NSManaged var priority: Int16
    @NSManaged var repeatType: Int16
    @NSManaged var isCompleted: Bool
    @NSManaged var createdAt: Date
    @NSManaged var completedAt: Date?
    @NSManaged var parentTask: Task?
    @NSManaged var subTasks: Set<Task>
    
    var taskPriority: TaskPriority {
        get { TaskPriority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }
    
    var taskRepeatType: RepeatType {
        get { RepeatType(rawValue: repeatType) ?? .none }
        set { repeatType = newValue.rawValue }
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
} 