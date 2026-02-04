//
//  DateItem.swift
//  Planvas
//
//  Created by 정서영 on 1/27/26.
//

import SwiftUI

// MARK: - 위클리 캘린더 하루 아이템
struct DateItem: View {
    let date: Date
    let isSelected: Bool
    @Binding var selectedDate: Date
    let schedules: [Schedule]
    
    var body: some View {
        VStack(spacing: 6) {
            // 요일
            Text(date.weekday)
                .textStyle(.medium14)
                .foregroundColor(weekdayColor)
            
            VStack{
                // 날짜
                Text("\(date.day)")
                    .textStyle(.medium16)
                    .foregroundColor(dateTextColor)
                
                // 일정 목록
                VStack(spacing: 4) {
                    ForEach(schedules) { schedule in
                        ScheduleItem(schedule: schedule, date: date)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 5)
            .frame(width: 50, height: 93)
            .background(backgroundView)
        }
        .onTapGesture {
            selectedDate = date
        }
    }
    
    // MARK: - 색상 로직
    // 요일 주말 색상
    private var weekdayColor: Color {
        if date.isSunday { return .red1 }
        if date.isSaturday { return .blue1 }
        return .gray888
    }
    
    // 날짜 주말, 선택된 날짜 색상
    private var dateTextColor: Color {
        if isSelected { return .gray888 }
        if date.isSunday { return .red1 }
        if date.isSaturday { return .blue1 }
        return .black1
    }
    
    // 선택된 날짜 배경색
    private var backgroundView: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 7.5)
                    .foregroundStyle(.ccc60)
            } else {
                Color.clear
            }
        }
    }
}
   

#Preview {
    MainView()
}
