import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var category: String = "工作"
    @State private var priority: Int16 = 1
    @State private var dueDate = Date()
    
    let categories = ["工作", "生活", "学习"]
    let priorities = [1, 2, 3]
    
    var body: some View {
        NavigationView {
            Form {
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
            .navigationTitle("新增任务")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveTask()
                }
            )
        }
    }
    
    private func saveTask() {
        let newTask = Task(context: viewContext)
        newTask.title = title
        newTask.taskDescription = taskDescription
        newTask.category = category
        newTask.priority = priority
        newTask.dueDate = dueDate
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("无法保存任务: \(nsError), \(nsError.userInfo)")
        }
    }
}
