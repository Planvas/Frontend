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

    @Environment(CalendarViewModel.self) private var calendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack{
                Text("오늘의 할 일")
                    .textStyle(.semibold25)
                    .foregroundStyle(.black1)
                Text("\(viewModel.todos.count)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.primary1)
                    .padding(8)
                    .background(
                        Circle()
                            .foregroundStyle(.primary20)
                    )
            }
            
            // 투두 아이템
            ForEach(viewModel.todos, id: \.id) { todo in
                ToDoItem(
                    todo: todo,
                    onToggle: {
                        viewModel.toggleTodo(todo)
                    },
                    onTap: {
                        Task {
                            await calendarViewModel.loadEventDetail(serverId: todo.id)
                            viewModel.showTodoDetail = true
                        }
                    }
                )
            }
            
            Button(action:{
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
            .sheet(isPresented: $viewModel.showTodoDetail) {
                if let event = calendarViewModel.loadedEventDetail {
                    EventSummaryView(
                        event: event,
                        startDate: calendarViewModel.getStartDate(for: event),
                        endDate: calendarViewModel.getEndDate(for: event),
                        daysUntil: calendarViewModel.getDaysUntil(for: event),
                        onDelete: {
                            calendarViewModel.deleteEvent(event)
                            calendarViewModel.clearLoadedEventDetail()
                            viewModel.showTodoDetail = false
                        },
                        onEdit: nil,
                        onUpdateEvent: { updatedEvent in
                            calendarViewModel.updateEvent(updatedEvent)
                            calendarViewModel.clearLoadedEventDetail()
                            viewModel.showTodoDetail = false
                        }
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $viewModel.showAddTodo) {
                AddTodoView(
                    date: viewModel.selectedDate,
                )
                .presentationDragIndicator(.visible)
            }
        }
        .padding()
    }
}

#Preview {
    TabBar()
}
