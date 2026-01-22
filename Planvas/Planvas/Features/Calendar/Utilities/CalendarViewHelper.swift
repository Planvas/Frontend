//
//  CalendarViewHelper.swift
//  Planvas
//
//  Created on 1/22/26.
//

import SwiftUI

/// CalendarView에서 사용하는 UI 헬퍼 함수들
enum CalendarViewHelper {
    /// 날짜 텍스트 색상을 반환
    static func dayTextColor(isSelected: Bool, isCurrentMonth: Bool) -> Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return Color(.black1)
        } else {
            return Color(.calTypo80)
        }
    }
}
