import SwiftUI

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let task: Task
    @State private var isEditing = false
    @State private var title: String
    @State private var taskDescription: String
    @State private var category: String
    @State private var priority: Int16
    @State private var dueDate: Date
    
    let categories = ["工作", "生活", "学习"]
    let priorities = [1, 2, 3]
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _category = State(initialValue: task.category ?? "工作")
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())
    }
    
    var body: some View {
        Form {
            if isEditing {
                editableView
            } else {
                displayView
            }
        }
        .navigationTitle(isEditing ? "编辑任务" : "任务详情")
        .navigationBarItems(trailing: Button(isEditing ? "保存" : "编辑") {
            if isEditing {
                saveTask()
            }
            isEditing.toggle()
        })
    }
    
    private var displayView: some View {
        Group {
            Section(header: Text("任务信息")) {
                Text("标题: \(task.title ?? "")")
                Text("描述: \(task.taskDescription ?? "")")
            }
            
            Section(header: Text("任务类别")) {
                Text("类别: \(task.category ?? "")")
            }
            
            Section(header: Text("优先级")) {
                Text("优先级: \(task.priority)")
            }
            
            Section(header: Text("截止日期")) {
                Text("截止日期: \(task.dueDate ?? Date(), style: .date)")
            }
        }
    }
    
    private var editableView: some View {
        Group {
            Section(header: Text("任务信息")) {
                TextField("标题", text: $title)
                TextEditor(text: $taskDescription)
                    .frame(height: 100)
            }
            
            Section(header: Text("任务类别")) {
                Picker("类别", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }
            
            Section(header: Text("优先级")) {
                Picker("优先级", selection: $priority) {
                    ForEach(priorities, id: \.self) { priority in
                        Text("\(priority)").tag(Int16(priority))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("截止日期")) {
                DatePicker("选择日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    private func saveTask() {
        task.title = title
        task.taskDescription = taskDescription
        task.category = category
        task.priority = priority
        task.dueDate = dueDate
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("无法保存任务: \(nsError), \(nsError.userInfo)")
        }
    }
}
