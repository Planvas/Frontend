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
    
    @Published var currentMonthIndex: Int = 0
        
    // 현재 열려있는 섹션을 추적 (없으면 nil) <- 이름 / 기간 카드 동시에 열리지 않게 하기 위해
    enum ExpandedSection {
        case name, period
    }
    
    @Published var expandedSection: ExpandedSection? = nil
    
    let daysInWeek = ["일", "월", "화", "수", "목", "금", "토"]
    let today = Calendar.current.startOfDay(for: Date())
    let calendar = Calendar.current
    
    // 성장 활동
    let growthActivityTypes: [ActivityType] = [
        .init(emoji: "🏆", title: "공모전"),
        .init(emoji: "📚", title: "스터디"),
        .init(emoji: "🎤", title: "진로특강"),
        .init(emoji: "💼", title: "인턴십"),
        .init(emoji: "👥", title: "학회/동아리"),
        .init(emoji: "💻", title: "웨비나"),
        .init(emoji: "📂", title: "장기프로젝트"),
        .init(emoji: "📝", title: "자격증"),
        .init(emoji: "📖", title: "관련 독서"),
    ]
    
    // 휴식 활동
    let restActivityTypes: [ActivityType] = [
        .init(emoji: "✈️", title: "여행"),
        .init(emoji: "🎶", title: "축제/콘서트"),
        .init(emoji: "🖼️", title: "전시/미술관"),
        .init(emoji: "🎨", title: "취미 레슨"),
        .init(emoji: "🛠️", title: "원데이클래스"),
        .init(emoji: "🎭", title: "연극/뮤지컬"),
        .init(emoji: "🧠", title: "심리 상담"),
        .init(emoji: "🏟️", title: "스포츠 관람"),
        .init(emoji: "🕶️", title: "방탈출/VR"),
    ]
    
    // 비율(0~10 step) 저장
    @Published var ratioStep: Int = 5
    
    var growthPercent: Int { ratioStep * 10 }
    var restPercent: Int { 100 - (ratioStep * 10) }
    

    // MARK: - 로직 함수
    
    // 월 단위 시작일 계산
    func startOfCurrentMonth() -> Date {
        // 실제 오늘(Date())을 기준으로 1일을 계산
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
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
