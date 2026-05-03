//
//  TodoPanel.swift
//  Wisp
//

import SwiftUI

struct TodoPanel: View {
    @State private var todos: [Todo] = []
    @State private var showingAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(todos) { todo in
                    TodoRow(todo: todo)
                        .onTapGesture {
                            runTodo(todo)
                        }
                }
            }

            Divider()

            HStack {
                Button(action: { showingAddSheet = true }) {
                    Label("新建任务", systemImage: "plus")
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTodoSheet(todos: $todos)
        }
    }

    private func runTodo(_ todo: Todo) {
        // TODO: 弹出 CLI 选择浮层 + 启动终端
        print("Run todo: \(todo.title)")
    }
}

struct TodoRow: View {
    let todo: Todo

    var body: some View {
        HStack {
            Image(systemName: statusIcon)
            Text(todo.title)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var statusIcon: String {
        switch todo.status {
        case .pending: return "circle"
        case .running: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

struct AddTodoSheet: View {
    @Binding var todos: [Todo]
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var prompt: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("新建任务")
                .font(.headline)

            TextField("标题", text: $title)
            TextEditor(text: $prompt)
                .frame(minHeight: 100)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.secondary.opacity(0.2)))

            HStack {
                Spacer()
                Button("取消") { dismiss() }
                Button("创建") {
                    let todo = Todo(title: title, prompt: prompt)
                    todos.append(todo)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 250)
    }
}
