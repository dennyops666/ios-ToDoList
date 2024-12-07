import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false
    @State private var selectedCategory: String? = nil
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    let categories = ["全部", "工作", "生活", "学习"]
    
    var filteredTasks: [Task] {
        if selectedCategory == nil || selectedCategory == "全部" {
            return Array(tasks)
        }
        return tasks.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 分类筛选
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(title: category,
                                         isSelected: category == selectedCategory,
                                         action: { selectedCategory = category })
                        }
                    }
                    .padding()
                }
                
                // 任务列表
                List {
                    ForEach(filteredTasks, id: \.self) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAddTask = true }) {
                        Label("添加任务", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTasks[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("删除任务失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct TaskRow: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title ?? "")
                .font(.headline)
            
            HStack {
                Label(task.category ?? "", systemImage: "folder")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(task.dueDate?.formatted() ?? "", systemImage: "calendar")
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            
            HStack {
                ForEach(0..<Int(task.priority), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
