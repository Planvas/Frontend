//
//  ToDoGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 바디 / 투두 그룹
struct ToDoGroup: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack{
                Text("오늘의 할 일")
                    .textStyle(.semibold25)
                    .foregroundStyle(.black1)
                Text("\(viewModel.todayTodos.count)")
                    .textStyle(.semibold20)
                    .foregroundStyle(.primary1)
                    .padding(8)
                    .background(
                        Circle()
                            .foregroundStyle(.primary20)
                    )
            }
            
            ForEach(viewModel.todayTodos) { todo in
                ToDoItem(
                    todo: todo,
                    onToggle: {
                        viewModel.toggleTodo(todo)
                    }
                )
            }
            
            Button(action:{
                // TODO: - 할 일 추가 시트 연결
                print("추가하기")
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
        }
        .padding()
    }
}
