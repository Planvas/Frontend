//
//  Untitled.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import Foundation
import Moya
import Combine

class GoalSetupViewModel: ObservableObject {
    @Published var goalName: String = ""
    
    // 20자 초과 체크 로직
    @Published var isOverLimit: Bool = false

    // 확정된 날짜
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    // 현재 보고 있는 달 (오늘)
    @Published var currentMonth: Date = Date()
    
    let daysInWeek = ["일", "월", "화", "수", "목", "금", "토"]
    let today = Calendar.current.startOfDay(for: Date())
    let calendar = Calendar.current
    
    

    // MARK: - 로직 함수
    
    // 월 단위 시작일 계산
    func startOfCurrentMonth() -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
    }

    // 날짜 선택
    func handleDateSelection(_ date: Date) {
        if startDate == nil || (startDate != nil && endDate != nil) {
            startDate = date
            endDate = nil
        } else if let start = startDate, date > start {
            endDate = date
        } else {
            startDate = date
        }
    }

    // 날짜 포맷팅 (M월 d일)
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }

    // 년/월 포맷팅 (2026년 1월)
    func formatYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    // 날짜 배열 생성
    func makeDays(for month: Date) -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: month),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        while days.count < 42 { days.append(nil) }
        return days
    }
    
    // GoalName 글자 수 제한 및 에러 로직
    func validateGoalName() {
        // 20자 넘었는지 체크해서 에러 메시지
        if goalName.count >= 20 {
            isOverLimit = true
        } else {
            isOverLimit = false
        }
        
        // 20자가 넘어가면 잘라내기
        if goalName.count > 20 {
            goalName = String(goalName.prefix(20))
        }
    }
    
}
