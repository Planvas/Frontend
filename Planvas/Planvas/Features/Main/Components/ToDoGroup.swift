//
//  ToDoGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 바디 / 투두 그룹
struct ToDoGroup: View {
    @Bindable var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack{
                Text("오늘의 할 일")
                    .textStyle(.semibold25)
                    .foregroundStyle(.black1)
                Text("\(viewModel.selectedTodos.count)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.primary1)
                    .padding(8)
                    .background(
                        Circle()
                            .foregroundStyle(.primary20)
                    )
            }
            
            // 캘린더 스케줄 투두
            ForEach(viewModel.selectedTodos) { todo in
                ToDoItem(
                    todo: todo,
                    onToggle: {
                        viewModel.toggleTodo(todo)
                    }
                )
            }
//            // 페이지 내에서만 보이는 투두
//            ForEach(viewModel.todayTodos) { todo in
//                ToDoItem(
//                    todo: todo,
//                    onToggle: {
//                        viewModel.toggleTodo(todo)
//                    }
//                )
//            }
            
            Button(action:{
                viewModel.addTodoViewModel = AddActivityViewModel()
                viewModel.showAddTodo = true
            }){
                HStack(spacing: 8){
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray444)
                    Text("추가하기")
                        .textStyle(.regular18)
                        .foregroundStyle(.gray444)
                    Spacer()
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.ccc60, lineWidth: 1)
                )
            }
            .sheet(isPresented: $viewModel.showAddTodo) {
                if let addVM = viewModel.addTodoViewModel {
                    AddActivityView(
                        viewModel: addVM,
                        onSubmit: {
                            Task { viewModel.AddTodo() }
                        }
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .padding()
    }
}

#Preview {
    TabBar()
}
