//
//  CalendarGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 바디 / 캘린더 그룹
struct CalendarGroup: View {
    let monthText: String
    let weekDates: [Date]
    @Binding var selectedDate: Date 
    
    var body: some View {
        VStack(alignment: .leading){
            Text("이번 주")
                .textStyle(.semibold25)
                .padding(.top, 29)
                .padding(.leading, 29)
            
            VStack(alignment: .leading){
                Text(monthText)
                    .textStyle(.semibold20)
                    .foregroundStyle(.black1)
                    .padding(.bottom)
                
                HStack(spacing: 16) {
                    ForEach(weekDates, id: \.self) { date in
                        DateItem(
                            date: date,
                            isSelected: selectedDate == date
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [.subPurple, .primary1],
                            startPoint: UnitPoint(x: -0.1, y: -0.1),
                            endPoint: UnitPoint(x: 0.2, y: 0.7)
                        ),
                        lineWidth: 1
                    )
            )
            .frame(maxWidth: .infinity)
        }
    }
}
