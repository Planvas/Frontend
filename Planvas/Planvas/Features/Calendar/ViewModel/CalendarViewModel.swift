//
//  CalendarViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation
import Observation
import CryptoKit

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

    /// 월간 API 결과 (날짜별 메타·프리뷰). 그리드 표시용.
    private(set) var monthData: MonthlyCalendarSuccessDTO?
    /// 월간 프리뷰 기반 Event (그리드 표시 전용, 일간 조회로 덮어쓰지 않음)
    private(set) var sampleEvents: [String: [Event]] = [:]
    /// 선택된 날짜의 일간 조회 결과 (목록 표시 전용)
    private(set) var selectedDateEvents: [Event] = []

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
    /// 그 날짜의 일정. sampleEvents(월간 프리뷰 + 일간 상세 캐시)에서 반환.
    func getEvents(for date: Date) -> [Event] {
        let dateKey = dateKeyString(from: date)
        return sampleEvents[dateKey] ?? []
    }
    
    /// 그 날짜의 이벤트 이름 표시용 (바 + 일정 이름). 고정+반복만 점으로 표시하므로 제외. 멀티데이 활동은 종료일에만 여기서 표시.
    func getDisplayEvents(for date: Date, isSelected: Bool) -> [Event] {
        let singleDay = getSingleDayEvents(for: date)
            .filter { !($0.isFixed && $0.isRepeating) }
        let activityMultiDayEndingToday = getEvents(for: date)
            .filter { $0.type == .activity }
            .filter { !calendar.isDate($0.startDate, inSameDayAs: $0.endDate) }
            .filter { calendar.isDate(date, inSameDayAs: $0.endDate) }
        return Array((singleDay + activityMultiDayEndingToday).prefix(3))
    }
    
    /// 해당 날짜의 반복 일정 목록 (캘린더 날짜 옆 원 표시용)
    func getRepeatingEvents(for date: Date) -> [Event] {
        getEvents(for: date).filter(\.isRepeating)
    }
    
    /// 여러 날에 걸친 고정 일정만 막대로 표시 (시작일~종료일). 반복 고정 일정은 점으로만 표시하므로 막대/이름 제외.
    func getMultiDayEventSegments(for date: Date) -> [(event: Event, isStart: Bool, isEnd: Bool)] {
        getEvents(for: date)
            .filter { $0.isFixed && !$0.isRepeating }
            .filter { !calendar.isDate($0.startDate, inSameDayAs: $0.endDate) }
            .map { event in
                let isStart = calendar.isDate(date, inSameDayAs: event.startDate)
                let isEnd = calendar.isDate(date, inSameDayAs: event.endDate)
                return (event, isStart, isEnd)
            }
    }

    // MARK: - 멀티데이 막대 슬롯 레이아웃 (주 단위 일관성)

    /// 한 날짜의 멀티데이 막대 슬롯 배열. nil = 빈 슬롯(스페이서), non-nil = 막대 표시.
    struct MultiDayBarSlot: Identifiable {
        let id: String
        let event: Event?
        let isStart: Bool
        let isEnd: Bool
    }

    /// 주 단위로 슬롯을 배정하여, 같은 이벤트가 주 내에서 항상 같은 줄에 표시되도록 함.
    /// - 주의 모든 멀티데이 이벤트를 시작일 기준으로 정렬
    /// - 각 이벤트에 가장 낮은 빈 슬롯 배정
    /// - 해당 날짜의 슬롯 배열 반환 (빈 슬롯은 nil 이벤트)
    func getMultiDayBarLayout(for date: Date) -> [MultiDayBarSlot] {
        // 1. 이 날짜가 속한 주의 시작일 (일요일) 찾기
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
            ?? date

        // 2. 주의 7일 동안 모든 멀티데이 이벤트 수집 (중복 제거)
        var seenIds = Set<UUID>()
        var weekEvents: [Event] = []
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { continue }
            for event in getEvents(for: day) {
                guard event.isFixed && !event.isRepeating else { continue }
                guard !calendar.isDate(event.startDate, inSameDayAs: event.endDate) else { continue }
                if seenIds.insert(event.id).inserted {
                    weekEvents.append(event)
                }
            }
        }

        // 3. 시작일 빠른 순 → 같으면 종료일 늦는 순 (긴 일정 우선)
        weekEvents.sort {
            if !calendar.isDate($0.startDate, inSameDayAs: $1.startDate) {
                return $0.startDate < $1.startDate
            }
            return $0.endDate > $1.endDate
        }

        // 4. 각 이벤트에 슬롯 배정 (그리디: 가장 낮은 빈 슬롯)
        //    slotEndDates[slot] = 해당 슬롯이 점유된 마지막 날짜
        var slotEndDates: [Date] = []
        var eventSlot: [UUID: Int] = [:]

        for event in weekEvents {
            let evStart = calendar.startOfDay(for: event.startDate)
            var assigned = false
            for slot in 0..<slotEndDates.count {
                // 슬롯의 마지막 점유일 다음날부터 비어있으면 사용 가능
                if evStart > slotEndDates[slot] {
                    slotEndDates[slot] = calendar.startOfDay(for: event.endDate)
                    eventSlot[event.id] = slot
                    assigned = true
                    break
                }
            }
            if !assigned {
                let newSlot = slotEndDates.count
                slotEndDates.append(calendar.startOfDay(for: event.endDate))
                eventSlot[event.id] = newSlot
            }
        }

        let totalSlots = slotEndDates.count
        guard totalSlots > 0 else { return [] }

        // 5. 이 날짜에 해당하는 슬롯 배열 생성
        let dayStart = calendar.startOfDay(for: date)
        var slots = [MultiDayBarSlot]()

        for slot in 0..<min(totalSlots, 2) { // 최대 2줄
            // 이 슬롯에 이 날짜에 표시할 이벤트 찾기
            let matchingEvent = weekEvents.first { event in
                guard eventSlot[event.id] == slot else { return false }
                let evStart = calendar.startOfDay(for: event.startDate)
                let evEnd = calendar.startOfDay(for: event.endDate)
                return dayStart >= evStart && dayStart <= evEnd
            }

            if let event = matchingEvent {
                let isStart = calendar.isDate(date, inSameDayAs: event.startDate)
                let isEnd = calendar.isDate(date, inSameDayAs: event.endDate)
                slots.append(MultiDayBarSlot(
                    id: "slot-\(slot)-\(event.id)",
                    event: event,
                    isStart: isStart,
                    isEnd: isEnd
                ))
            } else {
                // 빈 슬롯 (스페이서로 자리 유지)
                slots.append(MultiDayBarSlot(
                    id: "slot-\(slot)-empty-\(dateKeyString(from: date))",
                    event: nil,
                    isStart: false,
                    isEnd: false
                ))
            }
        }

        // 빈 슬롯만 있으면 빈 배열 반환
        return slots.contains(where: { $0.event != nil }) ? slots : []
    }
    
    /// 하루 단위 이벤트만 (멀티데이 제외, 리스트 표시용)
    private func getSingleDayEvents(for date: Date) -> [Event] {
        getEvents(for: date)
            .filter { calendar.isDate($0.startDate, inSameDayAs: $0.endDate) }
    }
    
    func hasEvents(for date: Date) -> Bool {
        let dateKey = dateKeyString(from: date)
        if let events = sampleEvents[dateKey], !events.isEmpty { return true }
        // sampleEvents에 없더라도 monthData에 hasItems가 true면 일정이 있는 것
        return monthData?.days.first(where: { $0.date == dateKey })?.hasItems ?? false
    }
    
    func selectDate(_ date: Date) {
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        if isCurrentMonth {
            selectedDate = date
            Task { await loadEventsForDate(date) }
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

    /// 캘린더 탭 선택 시 오늘 날짜로 이동
    func moveToToday() {
        let today = Date()
        currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        selectedDate = today
        Task { await refreshEvents() }
    }

    /// 프리뷰용: 지정한 년/월/일로 이동 후 해당 월·날짜 일정 로드 (CalendarRepository 샘플 확인용)
    func prepareForPreview(year: Int, month: Int, day: Int) async {
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let dayDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return }
        currentMonth = monthDate
        selectedDate = dayDate
        await refreshEvents()
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
        // 낙관적 업데이트: id 기준으로 모든 날짜에서 제거
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
                await refreshEvents()
            } catch {
                print("이벤트 삭제 실패: \(error)")
                await refreshEvents()
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

        // 고정 일정만 PATCH 요청. 활동 일정 수정 API는 미연동.
        if event.isFixed {
            Task {
                do {
                    try await repository.updateEvent(event)
                    await refreshEvents()
                } catch {
                    print("이벤트 수정 실패: \(error)")
                    await refreshEvents()
                }
            }
        } else {
            // 활동 일정: API 미호출, 목록(selectedDateEvents)만 낙관 반영
            var list = selectedDateEvents
            if let idx = list.firstIndex(where: { $0.id == event.id }) {
                list[idx] = event
                selectedDateEvents = list
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
        // 낙관적 업데이트
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
                await refreshEvents()
            } catch {
                print("이벤트 추가 서버 오류: \(error)")
                await refreshEvents()
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
    
    /// 월간 API만 호출하여 그리드 표시용 데이터를 갱신. 상세 일정은 날짜 클릭(일간 조회) 시 로드.
    func refreshEvents() async {
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        do {
            let monthResult = try await repository.getMonthCalendar(year: year, month: month)
            monthData = monthResult
            // 월간 프리뷰에서 멀티데이 감지하여 Event로 변환 → sampleEvents에 반영
            buildMonthPreviewEvents()
            // 현재 선택된 날짜의 일간 조회도 자동 로드 (시간 정보 포함)
            await loadEventsForDate(selectedDate)
        } catch {
            print("월간 캘린더 조회 실패: \(error)")
        }
    }

    /// 월간 프리뷰에서 같은 itemId가 여러 날에 있으면 멀티데이 Event로 변환, sampleEvents에 반영.
    /// 날짜 클릭(일간 조회) 시 해당 날짜만 덮어쓰므로, 나머지 날짜에는 프리뷰 기반 Event가 유지됨.
    private func buildMonthPreviewEvents() {
        guard let monthData = monthData else { return }

        // 1. 모든 날짜의 프리뷰를 itemId로 그룹핑
        var itemDates: [String: [String]] = [:]          // itemId → [date strings]
        var itemPreview: [String: SchedulePreviewDTO] = [:] // itemId → 대표 preview

        for day in monthData.days {
            for preview in day.schedulesPreview {
                if itemDates[preview.itemId] == nil {
                    itemDates[preview.itemId] = []
                    itemPreview[preview.itemId] = preview
                }
                itemDates[preview.itemId]?.append(day.date)
            }
        }

        // 2. 각 itemId에 대해 Event 생성 (멀티데이 여부 자동 감지)
        var events: [String: [Event]] = [:]

        for (itemId, dates) in itemDates {
            guard let preview = itemPreview[itemId] else { continue }
            let sortedDates = dates.sorted()
            guard let firstStr = sortedDates.first,
                  let lastStr = sortedDates.last,
                  let firstDate = Self.previewDateFormatter.date(from: firstStr),
                  let lastDate = Self.previewDateFormatter.date(from: lastStr) else { continue }

            let startDay = calendar.startOfDay(for: firstDate)
            let isMultiDay = sortedDates.count > 1
            let endDay = isMultiDay
                ? calendar.startOfDay(for: lastDate)
                : (calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDay) ?? startDay)

            // 멀티데이: itemId만으로 UUID (모든 날에서 동일 Event)
            // 싱글데이: 날짜 포함 UUID
            let id = isMultiDay
                ? CalendarViewModel.stableUUID(from: "preview-\(itemId)")
                : CalendarViewModel.stableUUID(from: "preview-\(itemId)-\(sortedDates[0])")

            let color: EventColorType = (preview.eventColor.map { EventColorType.from(serverColor: $0) })
                ?? (preview.isFixed ? .purple1 : Self.colorForServerItem(itemId: itemId, type: preview.type))

            // category 매핑
            let category: EventCategory = {
                switch preview.category?.uppercased() {
                case "GROWTH": return .growth
                case "REST": return .rest
                default: return .none
                }
            }()

            // type 매핑
            let eventType: EventType = (preview.type == "ACTIVITY") ? .activity : .fixed

            // recurrenceRule 파싱
            let (repeatType, repeatWeekdays) = CalendarAPIRepository.parseRecurrenceRule(preview.recurrenceRule)
            let isRepeating = repeatType != nil

            let event = Event(
                id: id,
                title: preview.title,
                isFixed: preview.isFixed,
                isAllDay: true,
                color: color,
                type: eventType,
                startDate: startDay,
                endDate: endDay,
                startTime: .midnight,
                endTime: .endOfDay,
                category: category,
                isCompleted: false,
                isRepeating: isRepeating,
                repeatOption: repeatType,
                fixedScheduleId: preview.isFixed ? Int(itemId) : nil,
                myActivityId: preview.isFixed ? nil : Int(itemId),
                repeatWeekdays: repeatWeekdays
            )

            // 고정 일정: 구간 내 모든 날짜에 표시(멀티데이 막대). 활동 일정: 종료일에만 단일 일정처럼 표시
            if preview.isFixed {
                for dateStr in sortedDates {
                    if events[dateStr] == nil { events[dateStr] = [] }
                    events[dateStr]?.append(event)
                }
            } else {
                if events[lastStr] == nil { events[lastStr] = [] }
                events[lastStr]?.append(event)
            }
        }

        sampleEvents = events
    }

    /// 해당 날짜 상세 일정 로드 (GET /api/calendar/day) → 목록 표시용 selectedDateEvents만 갱신.
    /// 캘린더 그리드(sampleEvents)는 월간 프리뷰 데이터만 사용하므로 건드리지 않음.
    func loadEventsForDate(_ date: Date) async {
        do {
            let events = try await repository.getEvents(for: date)
            selectedDateEvents = events
        } catch {
            print("일간 일정 조회 실패 (\(date)): \(error)")
            selectedDateEvents = []
        }
    }
    
    /// 같은 멀티데이 일정을 하나로 묶음. 서버 ID 우선, 없으면 title+start+end+type으로 동일 이벤트 판단.
    private func deduplicateMultiDayEvents(_ events: [Event]) -> [Event] {
        func multiDayKey(_ event: Event) -> String {
            if let id = event.fixedScheduleId { return "f-\(id)" }
            if let id = event.myActivityId { return "a-\(id)" }
            let start = event.startDate.timeIntervalSince1970
            let end = event.endDate.timeIntervalSince1970
            return "\(event.title)|\(start)|\(end)|\(event.type.rawValue)"
        }
        return Array(Dictionary(grouping: events, by: multiDayKey(_:)).values.compactMap { $0.first })
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

    /// 서버에서 색을 주지 않을 때 사용하는 팔레트 (Repository와 동일한 순서로 동일 itemId → 동일 색)
    private static let serverEventColorPalette: [EventColorType] = [.purple2, .blue1, .red, .yellow, .blue2, .pink, .green, .blue3, .purple1]

    /// "yyyy-MM-dd" 문자열 → Date 변환 (월간 프리뷰 날짜 파싱용)
    private static let previewDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static func colorForServerItem(itemId: String, type: String) -> EventColorType {
        var data = Data()
        data.append(contentsOf: "\(type)-\(itemId)".utf8)
        let hash = Insecure.SHA1.hash(data: data)
        let index = hash.withUnsafeBytes { bytes in bytes.load(as: UInt64.self) }
        // UInt64에서 모듈로 연산을 먼저 수행해 abs(Int.min) 오버플로우 방지
        let paletteCount = UInt64(serverEventColorPalette.count)
        let safeIndex = Int(index % paletteCount)
        return serverEventColorPalette[safeIndex]
    }

    private static func stableUUID(from string: String) -> UUID {
        var data = Data()
        data.append(contentsOf: string.utf8)
        let hash = Insecure.SHA1.hash(data: data)
        var bytes = Array(Array(hash).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}
