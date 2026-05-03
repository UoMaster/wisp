//
//  TodoListView.swift
//  Wisp
//

import SwiftUI

struct TodoListView: View {
    let todos: [Todo]
    let onTap: (Todo) -> Void
    let onMove: (IndexSet, Int) -> Void
    let onDelete: (IndexSet) -> Void
    let contextMenu: (Todo) -> AnyView

    @State private var hoveredTodoID: UUID? = nil

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Space.xs) {
                ForEach(todos) { todo in
                    TodoRow(todo: todo, isHovered: hoveredTodoID == todo.id)
                        .onTapGesture { onTap(todo) }
                        .onHover { isHovered in
                            hoveredTodoID = isHovered ? todo.id : nil
                        }
                        .contextMenu { contextMenu(todo) }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            .padding(.horizontal, Space.sm)
            .padding(.vertical, Space.sm)
        }
    }
}
