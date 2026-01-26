//
//  CalendarSyncViewModel.swift
//  Planvas
//
//  Created on 1/22/26.
//

import Foundation
import Combine

@MainActor
class CalendarSyncViewModel: ObservableObject {
    // 캘린더 타이틀 텍스트 (View에서 스타일 적용)
    let calendarTitleText = "캘린더 연동으로"
    let highlightedText = "캘린더 연동"
}
