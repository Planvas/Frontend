//
//  GoalSetupViewModel.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class GoalSetupViewModel {
    // 최종 온보딩 전송을 위한 캘린더 연동 상태
    var isCalendarConnected: Bool = false
    
    var goalName: String = ""

    // 20자 초과 체크 로직
    var isOverLimit: Bool = false

    // 확정된 날짜
    var startDate: Date?
    var endDate: Date?

    var currentMonthIndex: Int = 0

    // 현재 열려있는 섹션을 추적 (없으면 nil)
    enum ExpandedSection {
        case name, period
    }
    var expandedSection: ExpandedSection? = nil

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
        .init(emoji: "📂", title: "장기 프로젝트"),
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
    var ratioStep: Int = 5

    var growthPercent: Int { ratioStep * 10 }
    var restPercent: Int { 100 - (ratioStep * 10) }

    // 관심 분야 목록 저장
    var selectedInterestIds: Set<UUID> = []

    // 관심 분야
    let interestActivityTypes: [InterestActivityType] = [
        .init(emoji: "🖥️", title: "개발/IT"),
        .init(emoji: "📊", title: "기획/마케팅"),
        .init(emoji: "🎨", title: "예술/디자인"),
        .init(emoji: "📋", title: "인문/교육"),
        .init(emoji: "🧬", title: "과학/공학"),
        .init(emoji: "💰", title: "경영/경제"),
        .init(emoji: "🎬", title: "미디어/영상"),
        .init(emoji: "📝", title: "외국어"),
    ]

    // MARK: - 로직 함수

    // 월 단위 시작일 계산
    func startOfCurrentMonth() -> Date {
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
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }

    // ✅ 서버 전송용 날짜 포맷 (yyyy-MM-dd)
    func formatAPIDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 서버 기준이 UTC면 유지, 아니면 제거
        formatter.dateFormat = "yyyy-MM-dd"
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
        isOverLimit = goalName.count >= 20
        if goalName.count > 20 {
            goalName = String(goalName.prefix(20))
        }
    }

    // 관심 분야 토글
    func toggleInterest(_ id: UUID) {
        if selectedInterestIds.contains(id) {
            selectedInterestIds.remove(id)
            return
        }
        guard selectedInterestIds.count < 3 else { return }
        selectedInterestIds.insert(id)
    }

    func isInterestSelected(_ id: UUID) -> Bool {
        selectedInterestIds.contains(id)
    }
}
