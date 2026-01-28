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
    
    var body: some View {
        VStack(spacing: 6) {
            // 요일
            Text(date.weekday)
                .font(.caption)
                .foregroundColor(weekdayColor)
            
            // 날짜
            Text("\(date.day)")
                .font(.headline)
                .foregroundColor(dateTextColor)
                .frame(width: 32, height: 32)
                .background(backgroundView)
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
                Color.ccc20
            } else {
                Color.clear
            }
        }
    }
}
