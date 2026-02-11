//
//  CalendarViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class CalendarViewModel {
    var selectedDate: Date = Date()

    var currentMonth: Date = {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
    }()

    private let calendar = Calendar.current
    private let repository: CalendarRepositoryProtocol

    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private(set) var sampleEvents: [String: [Event]] = [:]

    /// Google 캘린더 연동 여부 (Repository 연동 상태에서 로드)
    private(set) var isCalendarConnected: Bool = false
    
    // MARK: - Initialization
    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarAPIRepository()
        Task {
            await loadGoogleCalendarStatus()
            await refreshEvents()
        }
    }
    
    private func loadGoogleCalendarStatus() async {
        do {
            let status = try await repository.getGoogleCalendarStatus()
            isCalendarConnected = status.connected
        } catch {
            isCalendarConnected = false
        }
    }

    /// 구글 캘린더 연동 후 연동 상태 갱신 + 일정 목록 새로고침 (알림에서 바로 연동 시 사용)
    func refreshAfterGoogleConnect() async {
        await loadGoogleCalendarStatus()
        await refreshEvents()
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
            if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newMonth)) {
                selectedDate = firstDayOfMonth
            }
            Task { await refreshEvents() }
        }
    }
    
    /// 다음 달로 이동
    func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newMonth)) {
                selectedDate = firstDayOfMonth
            }
            Task { await refreshEvents() }
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
                // 서버 오류가 나더라도 로컬에서는 삭제된 상태 유지 (되돌리지 않음)
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

    /// 반복 일정: 시작일~종료일 구간만 계산. 매일=매일, 매주=선택 요일만, 매달/매년=해당 날짜만.
    private func dateKeysForRepeatingEvent(_ event: Event) -> [String] {
        guard event.isRepeating,
              let repeatEnd = event.repeatEndDate,
              let type = event.repeatType else {
            return [dateKeyString(from: event.startDate)]
        }
        let start = calendar.startOfDay(for: event.startDate)
        let end = calendar.startOfDay(for: repeatEnd)
        if start > end { return [dateKeyString(from: start)] }

        func weekdayIndex(from date: Date) -> Int { (calendar.component(.weekday, from: date) - 2 + 7) % 7 }
        let weekdays: [Int] = event.repeatWeekdays ?? [weekdayIndex(from: start)]

        switch type {
        case .daily:
            return dateKeys(from: start, to: end)
        case .weekly:
            var keys: [String] = []
            var current = start
            while current <= end {
                if weekdays.contains(weekdayIndex(from: current)) { keys.append(dateKeyString(from: current)) }
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }
            return keys
        case .biweekly:
            var keys: [String] = []
            var current = start
            while current <= end {
                if weekdays.contains(weekdayIndex(from: current)) {
                    let weeks = (calendar.dateComponents([.day], from: start, to: current).day ?? 0) / 7
                    if weeks % 2 == 0 { keys.append(dateKeyString(from: current)) }
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }
            return keys
        case .monthly:
            var keys: [String] = []
            var current = start
            while current <= end {
                keys.append(dateKeyString(from: current))
                guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
                current = next
            }
            return keys
        case .yearly:
            var keys: [String] = []
            var current = start
            while current <= end {
                keys.append(dateKeyString(from: current))
                guard let next = calendar.date(byAdding: .year, value: 1, to: current) else { break }
                current = next
            }
            return keys
        }
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
        let selected = schedules.filter(\.isSelected)
        guard !selected.isEmpty else { return }
        Task {
            do {
                try await repository.importSchedules(selected)
                await loadGoogleCalendarStatus()
                await refreshEvents()
            } catch {
                await refreshEvents()
            }
        }
    }
    
    func addEvent(_ event: Event) {
        // 반복: 시작일~종료일만. 비반복: 시작일~종료일.
        let keysToAdd = event.isRepeating
            ? dateKeysForRepeatingEvent(event)
            : dateKeys(from: event.startDate, to: event.endDate)
        for dateKey in keysToAdd {
            if sampleEvents[dateKey] == nil {
                sampleEvents[dateKey] = []
            }
            sampleEvents[dateKey]?.append(event)
        }
        
        Task {
            do {
                try await repository.addEvent(event)
            } catch {
                // 서버 오류 시에도 낙관적 반영은 유지 (사용자에게는 저장된 것처럼 보이게 함). 필요 시 백그라운드 재시도/토스트는 별도 구현.
                print("이벤트 추가 서버 오류 (로컬에는 유지): \(error)")
            }
        }
    }

    /// 해당 날짜 구간만 API로 가져와 sampleEvents에 반영 (일정 추가 실패 시 해당 일만 새로고침 등)
    private func refreshEventsInRange(from startDate: Date, to endDate: Date) async {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        do {
            let events = try await repository.getEvents(from: start, to: end)
            let fetchedByDate = eventsToDictionary(events)
            for key in dateKeys(from: start, to: end) {
                sampleEvents[key] = fetchedByDate[key] ?? []
            }
            sampleEvents = sampleEvents.filter { !$0.value.isEmpty }
        } catch {
            print("일정 구간 새로고침 실패: \(error)")
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
