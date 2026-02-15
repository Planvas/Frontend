//
//  ToDoItem.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 투두 아이템
struct ToDoItem: View {
    let todo: ToDo
    let onToggle: () -> Void
    
    var body: some View {
        // TODO: - 클릭 시 디테일 페이지 연결
        ZStack{
            HStack{
                RoundedRectangle(cornerRadius: 5)
                    .fill(todo.typeColor.color)
                    .frame(width: 3, height: 33)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading){
                    HStack(spacing: 10){
                        Text(todo.title)
                            .textStyle(.regular18)
                            .foregroundStyle(.black1)
                            .strikethrough(todo.isCompleted)
                        
                        if todo.isFixed {
                            Text("고정")
                                .textStyle(.medium14)
                                .foregroundStyle(.fff)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.subPurple, .primary1]),
                                                startPoint: UnitPoint(x: -0.1, y: 0.2),
                                                endPoint: UnitPoint(x: 0.8, y: 0.5)
                                            )
                                        )
                                )
                        }
                    }
                    .frame(height: 15)
                    
                    Text(todo.todoInfo.isEmpty ? "종일" : todo.todoInfo)
                        .textStyle(.regular14)
                        .foregroundStyle(.gray888)
                        .strikethrough(todo.isCompleted)
                }
                
                Spacer()
                
                if !todo.startTime.isEmpty {
                    Text(todo.startTime)
                        .textStyle(.regular14)
                        .foregroundStyle(.primary1)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(.primary20)
                        )
                        .padding(.trailing, 46)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.ccc60, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(todo.isCompleted ? .primary20 : .clear)
            )
            
            HStack{
                Spacer()
                Button(action: onToggle) {
                    Image(systemName: todo.isCompleted
                          ? "checkmark.circle.fill"
                          : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        todo.isCompleted ? .primary1 : .ccc
                    )
                }
                .padding(.trailing, 15)
            }
        }
    }
}
