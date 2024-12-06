import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String
    @NSManaged public var category: String
    @NSManaged public var priority: Int16
    @NSManaged public var deadline: Date
    @NSManaged public var isCompleted: Bool
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
} 