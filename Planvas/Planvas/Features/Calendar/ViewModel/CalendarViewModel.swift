//
//  CalendarViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 13
        return calendar.date(from: components) ?? Date()
    }()
    
    @Published var currentMonth: Date = {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }()
    
    private let calendar = Calendar.current
    private let repository: CalendarRepositoryProtocol
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    // 샘플 데이터 (API 연동 전까지)
    // TODO : API 연동 시 Repository를 통해 데이터를 가져오므로 이 변수 지울 거임
    @Published private(set) var sampleEvents: [String: [Event]] = [:]
    
    // MARK: - Initialization
    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarRepository()
        loadSampleEvents()
    }
    
    private func loadSampleEvents() {
        // TODO : API 연동 시 이 메소드 제거하고 Repository를 통해 데이터를 가져올 거임
        // 현재는 샘플 데이터를 로드
        sampleEvents = [
            "2026-01-02": [
                Event(title: "이벤트", time: "하루종일", color: .purple1)
            ],
            "2026-01-13": [
                Event(title: "카페 알바", time: "매주 수요일 18:00 - 22:00", isFixed: true, color: .red),
                Event(title: "엄마생신", time: "하루종일", isAllDay: true, color: .purple2)
            ],
            "2026-01-15": [
                Event(title: "베트남 여행", time: "하루종일", color: .blue1)
            ],
            "2026-01-16": [
                Event(title: "베트남 여행", time: "10:00 - 20:00", color: .blue2)
            ],
            "2026-01-18": [
                Event(title: "동아리송별", time: "하루종일", color: .blue3)
            ],
            "2026-01-20": [
                Event(title: "이벤트", time: "하루종일", isFixed: true, color: .pink)
            ]
        ]
    }
    
    // MARK: - Computed Properties
    var monthString: String {
        currentMonth.monthString()
    }
    
    var yearString: String {
        currentMonth.yearString()
    }
    
    var selectedDateFullString: String {
        selectedDate.fullDateString()
    }
    
    var daysInMonth: [Date] {
        guard let firstDayOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
            return []
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysToSubtract = (firstDayWeekday - 1) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDayOfMonth) else {
            return []
        }
        
        let weeks = calendar.range(of: .weekOfMonth, in: .month, for: currentMonth)?.count ?? 6
        let totalDays = weeks * 7
        var days: [Date] = []
        for i in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(date)
            }
        }
        return days
    }
    
    // MARK: - Methods
    func getEvents(for date: Date) -> [Event] {
        let dateKey = dateKeyString(from: date)
        return sampleEvents[dateKey] ?? []
    }
    
    func getDisplayEvents(for date: Date, isSelected: Bool) -> [Event] {
        let events = getEvents(for: date)
        // 있는 일정을 다 표시하되, 4개 이상이면 3개만 표시 (잘림)
        return Array(events.prefix(3))
    }
    
    func hasEvents(for date: Date) -> Bool {
        return !getEvents(for: date).isEmpty
    }
    
    func selectDate(_ date: Date) {
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        if isCurrentMonth {
            selectedDate = date
        }
    }
    
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func isDateToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    func dayNumber(from date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    
    func importSchedules(_ schedules: [ImportableSchedule]) {
        // ImportableSchedule을 Event로 변환하여 추가
        // TODO: API 연동 시 이 부분 수정 예정
        Task {
            do {
                try await repository.importSchedules(schedules)
                // 성공 시 이벤트 목록 새로고침
                await refreshEvents()
            } catch {
                // 에러 처리 (나중에 에러 상태를 @Published로 관리)
                print("일정 가져오기 실패: \(error)")
            }
        }
        
        // 현재는 샘플 데이터에 추가
        // API 연동 시 없앨 예정
        for _ in schedules {
            // 여기서는 샘플로 간단하게 처리
            // 실제로는 시간 정보를 파싱해서 정확한 날짜에 배치해야 함
        }
    }
    
    func addEvent(_ event: Event) {
        // Event를 선택된 날짜에 추가
        // TODO: API 연동 시 이 부분 수정
        Task {
            do {
                try await repository.addEvent(event)
                // 성공 시 이벤트 목록 새로고침
                await refreshEvents()
            } catch {
                // 에러 처리 (나중에 에러 상태를 @Published로 관리)
                print("이벤트 추가 실패: \(error)")
            }
        }
        
        // 현재는 샘플 데이터에 추가
        let dateKey = dateKeyString(from: selectedDate)
        if sampleEvents[dateKey] == nil {
            sampleEvents[dateKey] = []
        }
        sampleEvents[dateKey]?.append(event)
    }
    
    // TODO: API 연동 시 이 메서드를 사용하여 이벤트 목록을 새로고침합니다
    private func refreshEvents() async {
        // 현재 월의 시작일과 종료일 계산
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return
        }
        
        do {
            let _ = try await repository.getEvents(from: monthInterval.start, to: monthInterval.end)
            // events를 sampleEvents 형식으로 변환
            // TODO: API 연동 시 이 부분을 구현
        } catch {
            print("이벤트 새로고침 실패: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func dateKeyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
