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
    let weeklyBarSchedules: [Schedule]
    let recurringSchedules: [Schedule]
    let slotAssignment: [Int: Int]
    
    // 이 날짜에 표시할 슬롯별 일정 (slot 0,1,2 순서, nil = 빈 슬롯)
    private var slottedSchedules: [Int: Schedule] {
        var result: [Int: Schedule] = [:]
        let today = Calendar.current.startOfDay(for: date)

        for schedule in weeklyBarSchedules {
            guard schedule.dates.contains(today),
                  let slot = slotAssignment[schedule.id],
                  slot < 3 else { continue }
            result[slot] = schedule
        }
        return result
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // 요일
            Text(date.weekday)
                .textStyle(.medium14)
                .foregroundColor(weekdayColor)
            
            VStack{
                // 날짜
                ZStack(alignment: .topTrailing) {

                    Text("\(date.day)")
                        .textStyle(.medium16)
                        .foregroundColor(dateTextColor)

                    if hasRecurringSchedule {
                        Circle()
                            .fill(.primary1)
                            .frame(width: 5, height: 5)
                            .offset(x: 6, y: -2)
                    }
                }
                
                // 일정 목록
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { slot in
                        Group {
                            if let schedule = slottedSchedules[slot] {
                                ScheduleItem(schedule: schedule, date: date)
                            } else {
                                Color.clear
                            }
                        }
                        .frame(height: 15)
                    }
                }
                .clipped()
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
    
    // 반복인지 확인
    private var hasRecurringSchedule: Bool {
        recurringSchedules.contains {
            $0.dates.contains(Calendar.current.startOfDay(for: date))
        }
    }
}

