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
    
    /// Google 캘린더 연동 여부 (일정 가져오기 알림 문구 분기용)
    @Published private(set) var isCalendarConnected: Bool = true
    
    // MARK: - Initialization
    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarRepository()
        loadSampleEvents()
    }
    
    private func loadSampleEvents() {
        // TODO : API 연동 시 이 메소드 제거하고 Repository를 통해 데이터를 가져올 거임
        // 멀티데이 일정은 동일 id의 한 Event를 여러 날짜에 넣어야 삭제/수정 시 전체 반영됨
        let vietnamTrip = Event(
            title: "베트남 여행",
            time: "1/15 - 1/18",
            isAllDay: true,
            color: .blue1,
            startDate: makeDate(year: 2026, month: 1, day: 15),
            endDate: makeDate(year: 2026, month: 1, day: 18),
            category: .rest
        )
        sampleEvents = [
            "2026-01-02": [
                Event(
                    title: "독서 모임",
                    time: "14:00 - 16:00",
                    color: .purple1,
                    startDate: makeDate(year: 2026, month: 1, day: 2, hour: 14),
                    endDate: makeDate(year: 2026, month: 1, day: 2, hour: 16),
                    category: .growth,
                    isCompleted: true
                )
            ],
            "2026-01-08": [
                Event(
                    title: "헬스장 PT",
                    time: "매주 월요일 10:00 - 11:00",
                    isFixed: true,
                    color: .green,
                    startDate: makeDate(year: 2026, month: 1, day: 8, hour: 10),
                    endDate: makeDate(year: 2026, month: 1, day: 8, hour: 11),
                    category: .rest,
                    isRepeating: true
                )
            ],
            "2026-01-13": [
                Event(
                    title: "카페 알바",
                    time: "매주 수요일 18:00 - 22:00",
                    isFixed: true,
                    color: .red,
                    startDate: makeDate(year: 2026, month: 1, day: 13, hour: 18),
                    endDate: makeDate(year: 2026, month: 1, day: 13, hour: 22),
                    category: .growth,
                    isRepeating: true
                ),
                Event(
                    title: "엄마 생신",
                    time: "하루종일",
                    isAllDay: true,
                    color: .purple2,
                    startDate: makeDate(year: 2026, month: 1, day: 13),
                    endDate: makeDate(year: 2026, month: 1, day: 13),
                    category: .none
                )
            ],
            "2026-01-15": [vietnamTrip],
            "2026-01-16": [vietnamTrip],
            "2026-01-17": [vietnamTrip],
            "2026-01-18": [
                vietnamTrip,
                Event(
                    title: "동아리 송별회",
                    time: "19:00 - 22:00",
                    color: .blue3,
                    startDate: makeDate(year: 2026, month: 1, day: 18, hour: 19),
                    endDate: makeDate(year: 2026, month: 1, day: 18, hour: 22),
                    category: .rest
                )
            ],
            "2026-01-20": [
                Event(
                    title: "토익 시험",
                    time: "09:00 - 12:00",
                    isFixed: true,
                    color: .pink,
                    startDate: makeDate(year: 2026, month: 1, day: 20, hour: 9),
                    endDate: makeDate(year: 2026, month: 1, day: 20, hour: 12),
                    category: .growth,
                    isCompleted: true
                )
            ],
            "2026-01-22": [
                Event(
                    title: "공모전 제출",
                    time: "하루종일",
                    isAllDay: true,
                    color: .yellow,
                    startDate: makeDate(year: 2026, month: 1, day: 22),
                    endDate: makeDate(year: 2026, month: 1, day: 22),
                    category: .growth
                )
            ],
            "2026-01-25": [
                Event(
                    title: "요가 클래스",
                    time: "매주 토요일 08:00 - 09:00",
                    isFixed: true,
                    color: .green,
                    startDate: makeDate(year: 2026, month: 1, day: 25, hour: 8),
                    endDate: makeDate(year: 2026, month: 1, day: 25, hour: 9),
                    category: .rest,
                    isRepeating: true
                ),
                Event(
                    title: "친구 만남",
                    time: "14:00 - 18:00",
                    color: .blue2,
                    startDate: makeDate(year: 2026, month: 1, day: 25, hour: 14),
                    endDate: makeDate(year: 2026, month: 1, day: 25, hour: 18),
                    category: .rest
                )
            ],
            "2026-01-28": [
                Event(
                    title: "프로젝트 미팅",
                    time: "15:00 - 17:00",
                    color: .red,
                    startDate: makeDate(year: 2026, month: 1, day: 28, hour: 15),
                    endDate: makeDate(year: 2026, month: 1, day: 28, hour: 17),
                    category: .growth
                )
            ]
        ]
    }
    
    /// 날짜 생성 헬퍼
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
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
        let events = getSingleDayEvents(for: date)
        // 있는 일정을 다 표시하되, 4개 이상이면 3개만 표시 (잘림)
        return Array(events.prefix(3))
    }
    
    /// 해당 날짜의 반복 일정 목록 (캘린더 날짜 옆 원 표시용)
    func getRepeatingEvents(for date: Date) -> [Event] {
        getEvents(for: date).filter(\.isRepeating)
    }
    
    /// 여러 날에 걸친 이벤트만 해당 날짜 구간으로 반환 (막대 표시용)
    func getMultiDayEventSegments(for date: Date) -> [(event: Event, isStart: Bool, isEnd: Bool)] {
        getEvents(for: date)
            .filter { !calendar.isDate($0.startDate, inSameDayAs: $0.endDate) }
            .map { event in
                let isStart = calendar.isDate(date, inSameDayAs: event.startDate)
                let isEnd = calendar.isDate(date, inSameDayAs: event.endDate)
                return (event, isStart, isEnd)
            }
    }
    
    /// 하루 단위 이벤트만 (멀티데이 제외, 리스트 표시용)
    private func getSingleDayEvents(for date: Date) -> [Event] {
        getEvents(for: date)
            .filter { calendar.isDate($0.startDate, inSameDayAs: $0.endDate) }
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
    
    /// 이전 달로 이동
    func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            // 선택된 날짜도 해당 월의 1일로 변경
            if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newMonth)) {
                selectedDate = firstDayOfMonth
            }
        }
    }
    
    /// 다음 달로 이동
    func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            // 선택된 날짜도 해당 월의 1일로 변경
            if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newMonth)) {
                selectedDate = firstDayOfMonth
            }
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
    
    func getStartDate(for event: Event) -> Date {
        return event.startDate
    }
    
    func getEndDate(for event: Event) -> Date {
        return event.endDate
    }
    
    func getDaysUntil(for event: Event) -> Int? {
        let startDate = getStartDate(for: event)
        // 시간대 오차 방지를 위해 startOfDay로 정규화
        let todayStart = calendar.startOfDay(for: Date())
        let eventStart = calendar.startOfDay(for: startDate)
        let days = calendar.dateComponents([.day], from: todayStart, to: eventStart).day ?? 0
        return days >= 0 ? days : nil
    }
    
    func deleteEvent(_ event: Event) {
        // 낙관적 업데이트: id 기준으로 모든 날짜에서 제거 (멀티데이 일정 전체 삭제)
        var newEvents = sampleEvents
        for dateKey in Array(newEvents.keys) {
            var list = newEvents[dateKey] ?? []
            list.removeAll { $0.id == event.id }
            if list.isEmpty {
                newEvents.removeValue(forKey: dateKey)
            } else {
                newEvents[dateKey] = list
            }
        }
        sampleEvents = newEvents
        
        Task {
            do {
                try await repository.deleteEvent(event)
            } catch {
                await MainActor.run { applyEventsFromRepository() }
                print("이벤트 삭제 실패: \(error)")
            }
        }
    }
    
    /// id 기준으로 이벤트 수정 (날짜 변경 시 구간 반영, 막대 다시 그림)
    func updateEvent(_ event: Event) {
        // 낙관적 업데이트: 기존 구간에서 제거 후 새 구간에 추가
        var newEvents = sampleEvents
        for dateKey in Array(newEvents.keys) {
            var list = newEvents[dateKey] ?? []
            list.removeAll { $0.id == event.id }
            if list.isEmpty {
                newEvents.removeValue(forKey: dateKey)
            } else {
                newEvents[dateKey] = list
            }
        }
        
        for dateKey in dateKeys(from: event.startDate, to: event.endDate) {
            var list = newEvents[dateKey] ?? []
            list.append(event)
            newEvents[dateKey] = list
        }
        sampleEvents = newEvents
        
        Task {
            do {
                try await repository.updateEvent(event)
            } catch {
                await MainActor.run { applyEventsFromRepository() }
                print("이벤트 수정 실패: \(error)")
            }
        }
    }
    
    /// startDate~endDate에 해당하는 날짜 키 목록
    private func dateKeys(from start: Date, to end: Date) -> [String] {
        var keys: [String] = []
        var current = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        while current <= endDay {
            keys.append(dateKeyString(from: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return keys
    }
    
    /// Repository 결과를 sampleEvents에 반영 (API 연동용 / 실패 시 롤백)
    private func applyEventsFromRepository() {
        Task {
            await refreshEvents()
        }
    }
    
    func getTargetPeriod(for event: Event) -> String? {
        // 이벤트의 시작/종료일로 목표 기간 계산
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        
        // 같은 날이면 nil 반환
        if calendar.isDate(event.startDate, inSameDayAs: event.endDate) {
            return nil
        }
        return "\(start) ~ \(end)"
    }
    
    func importSchedules(_ schedules: [ImportableSchedule]) {
        // TODO: API 연동 시 선택 일정을 서버에 전달 후 refreshEvents() 호출
        // Task {
        //     try await repository.importSchedules(schedules)
        //     await refreshEvents()
        // }
        
        // ImportableSchedule → Event 변환하여 로컬에 추가 (schedule의 startDate/endDate 반영)
        let selected = schedules.filter(\.isSelected)
        for schedule in selected {
            let event = event(from: schedule)
            for dateKey in dateKeys(from: event.startDate, to: event.endDate) {
                if sampleEvents[dateKey] == nil {
                    sampleEvents[dateKey] = []
                }
                sampleEvents[dateKey]?.append(event)
            }
        }
        if !selected.isEmpty {
            isCalendarConnected = true
        }
    }
    
    /// ImportableSchedule → Event 변환 (schedule의 startDate/endDate 사용)
    private func event(from schedule: ImportableSchedule) -> Event {
        Event(
            id: schedule.id,
            title: schedule.title,
            time: schedule.timeDescription,
            isFixed: true,
            isAllDay: false,
            color: .red,
            startDate: schedule.startDate,
            endDate: schedule.endDate,
            category: .none,
            isCompleted: false,
            isRepeating: false
        )
    }
    
    func addEvent(_ event: Event) {
        // 낙관적 업데이트: 먼저 로컬에 추가
        for dateKey in dateKeys(from: event.startDate, to: event.endDate) {
            if sampleEvents[dateKey] == nil {
                sampleEvents[dateKey] = []
            }
            sampleEvents[dateKey]?.append(event)
        }
        
        Task {
            do {
                try await repository.addEvent(event)
            } catch {
                await MainActor.run { applyEventsFromRepository() }
                print("이벤트 추가 실패: \(error)")
            }
        }
    }
    
    /// Repository에서 현재 월 이벤트를 가져와 sampleEvents에 반영 (API 연동 / 실패 시 롤백)
    private func refreshEvents() async {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return
        }
        do {
            let events = try await repository.getEvents(from: monthInterval.start, to: monthInterval.end)
            let fetchedByDate = eventsToDictionary(events)
            let monthKeys = dateKeys(from: monthInterval.start, to: monthInterval.end)
            for key in monthKeys {
                sampleEvents[key] = fetchedByDate[key] ?? []
            }
            // 빈 배열이 된 키 제거 (선택)
            sampleEvents = sampleEvents.filter { !$0.value.isEmpty }
        } catch {
            print("이벤트 새로고침 실패: \(error)")
        }
    }
    
    /// [Event]를 날짜별 [String: [Event]]로 변환 (멀티데이 이벤트는 해당하는 모든 날에 포함)
    private func eventsToDictionary(_ events: [Event]) -> [String: [Event]] {
        var result: [String: [Event]] = [:]
        for event in events {
            for key in dateKeys(from: event.startDate, to: event.endDate) {
                if result[key] == nil { result[key] = [] }
                result[key]?.append(event)
            }
        }
        return result
    }
    
    // MARK: - Helper Methods
    private func dateKeyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
