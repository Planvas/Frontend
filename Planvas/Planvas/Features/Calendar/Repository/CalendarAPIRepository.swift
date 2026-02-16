//
//  CalendarAPIRepository.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//

import Foundation
import CryptoKit

/// API 기반 캘린더 Repository. 월간/일간 조회, 일정 추가·수정·삭제, 구글 캘린더 연동.
final class CalendarAPIRepository: CalendarRepositoryProtocol {
    private let networkService: CalendarNetworkService
    private let calendar = Calendar.current

    init(networkService: CalendarNetworkService = CalendarNetworkService()) {
        self.networkService = networkService
    }

    /// 월간 캘린더 조회
    /// - API: `GET /api/calendar/month?year=&month=`
    /// - 사용처: `CalendarViewModel.refreshEvents()`
    /// - 시점: 앱 진입, 달 이동, 오늘로 이동, 일정 추가/수정/삭제 후
    /// - 결과: monthData → buildMonthPreviewEvents() → sampleEvents → 캘린더 그리드(날짜별 점·막대·일정명)
    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO {
        try await networkService.getMonthCalendar(year: year, month: month)
    }

    /// 특정 날짜의 일정 목록 조회 (날짜 셀 탭 시 호출)
    /// - API: `GET /api/calendar/day?date=YYYY-MM-DD` → 응답 `todayTodos`를 `Event[]`로 매핑
    /// - 사용처: `CalendarViewModel.loadEventsForDate(_ date)`
    /// - 결과: selectedDateEvents → 선택일 일정 카드 리스트. 상세/수정 시 이 Event 그대로 사용(별도 상세 조회 API 없음)
    func getEvents(for date: Date) async throws -> [Event] {
        let dateKey = dateKeyString(from: date)
        let dayDTO = try await networkService.getDayCalendar(date: dateKey)
        return dayDTO.todayTodos.map { mapToEvent(item: $0, date: dayDTO.date) }
    }

    /// 날짜 범위 내 일정 조회 (여러 일간 조회 병렬 호출)
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        var dates: [Date] = []
        var current = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        while current <= endDay {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return try await withThrowingTaskGroup(of: [Event].self) { group in
            for date in dates {
                group.addTask { try await self.getEvents(for: date) }
            }
            var allEvents: [Event] = []
            for try await list in group {
                allEvents.append(contentsOf: list)
            }
            return allEvents
        }
    }

    /// 일정 추가 (직접 추가)
    /// - API: `POST /api/calendar/event`
    /// - Body: title, startAt, endAt, type: "FIXED", category, eventColor, recurrenceRule, recurrenceEndAt(반복일 때)
    /// - 사용처: AddEventView "저장" → viewModel.addEvent(event)
    /// - 후처리: 성공 시 ViewModel에서 refreshEvents()로 월간·일간 재조회
    func addEvent(_ event: Event) async throws {
        let (startAt, endAt) = formatEventTimes(event)
        let categoryStr = event.category == .none ? "GROWTH" : event.category.rawValue
        let colorInt = event.color.serverColor
        let rule = Self.buildRecurrenceRule(from: event)
        let recurrenceEndAt: String? = (event.isRepeating && event.repeatEndDate != nil)
            ? dateKeyString(from: event.repeatEndDate!)
            : nil
        _ = try await networkService.createEvent(
            title: event.title, startAt: startAt, endAt: endAt, type: "FIXED",
            category: categoryStr, eventColor: colorInt, recurrenceRule: rule, recurrenceEndAt: recurrenceEndAt
        )
    }

    /// 일정 수정
    /// - API: `PATCH /api/calendar/event/{id}` (id = itemId)
    /// - 사용처: FixedEventDetailView/EditEventView, ActivityEventDetailView "저장" → viewModel.updateEvent(updatedEvent)
    /// - 고정 일정: title, startAt, endAt, type: "FIXED", category, eventColor, recurrenceRule, recurrenceEndAt(반복 시). 활동치 켬(활동 전환) 시 type: "ACTIVITY" + point, category, status 추가.
    /// - 활동 일정: startAt, endAt, type: "ACTIVITY", point, category, status 등.
    /// - 후처리: 성공 시 refreshEvents() 호출
    func updateEvent(_ event: Event) async throws {
        guard let serverId = event.fixedScheduleId ?? event.myActivityId else {
            throw CalendarRepositoryError.missingServerId(message: "서버 일정 ID가 없어 수정할 수 없습니다.")
        }
        let (startAt, endAt) = formatEventTimes(event)
        let categoryStr = event.category == .none ? "GROWTH" : event.category.rawValue
        let colorInt = event.color.serverColor
        let rule = Self.buildRecurrenceRule(from: event)
        let recurrenceEndAtStr: String? = event.repeatEndDate.map { dateKeyString(from: $0) }

        if event.isFixed {
            try await networkService.updateEvent(
                id: serverId, title: event.title, startAt: startAt, endAt: endAt, type: "FIXED",
                category: categoryStr, eventColor: colorInt, recurrenceRule: rule, recurrenceEndAt: recurrenceEndAtStr,
                point: nil, status: nil
            )
        } else {
            let point = event.activityPoint ?? 20
            let statusStr = event.isCompleted ? "DONE" : "TODO"
            try await networkService.updateEvent(
                id: serverId, title: event.title, startAt: startAt, endAt: endAt, type: "ACTIVITY",
                category: categoryStr, eventColor: colorInt, recurrenceRule: rule ?? "", recurrenceEndAt: recurrenceEndAtStr,
                point: point, status: statusStr
            )
        }
    }

    /// 일정 삭제
    /// - API: `DELETE /api/calendar/event/{id}`
    /// - 사용처: EventSummaryView / FixedEventDetailView / ActivityEventSummaryView 등 "삭제" 버튼 → viewModel.deleteEvent(event)
    /// - 시점: 사용자가 일정 상세에서 삭제 선택 시
    /// - 후처리: 성공 시 refreshEvents() 호출
    func deleteEvent(_ event: Event) async throws {
        guard let serverId = event.fixedScheduleId ?? event.myActivityId else {
            throw CalendarRepositoryError.missingServerId(message: "서버 일정 ID가 없어 삭제할 수 없습니다.")
        }
        try await networkService.deleteEvent(id: serverId)
    }

    /// 구글 캘린더에서 가져올 수 있는 일정 목록 (GET events → ImportableSchedule, 일정 선택 화면용)
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        let events = try await networkService.getGoogleCalendarEvents(timeMin: nil, timeMax: nil)
        return events.map { mapToImportableSchedule($0) }
    }

    /// 선택 일정 서버 동기화 (POST sync, 가져오기 확정 시). TODO: 현재 서버 API는 선택 목록 미지원, 전체 동기화만 수행. schedules 파라미터 미사용.
    func importSchedules(_ schedules: [ImportableSchedule]) async throws {
        _ = try await networkService.syncGoogleCalendar()
    }

    /// 구글 캘린더 연동 여부·연동일·마지막 동기화 시각 (GET status → 도메인 모델)
    func getGoogleCalendarStatus() async throws -> GoogleCalendarStatus {
        let dto = try await networkService.getGoogleCalendarStatus()
        return GoogleCalendarStatus(
            connected: dto.connected,
            connectedAt: parseISO8601(dto.connectedAt),
            lastSyncedAt: parseISO8601(dto.lastSyncedAt)
        )
    }

    /// 구글 캘린더 연동 (로그인 후 받은 serverAuthCode로 POST connect 호출)
    func connectGoogleCalendar(code: String) async throws {
        try await networkService.connectGoogleCalendar(code: code)
    }

    // MARK: - Event → ISO 변환 (일정 추가/수정 요청용)

    /// Event의 isAllDay 여부에 따라 ISO 문자열 포맷 분기.
    /// - 하루종일: UTC 자정 기준 ("2026-02-02T00:00:00Z" ~ "2026-02-02T23:59:00Z") → 서버가 UTC 날짜로 매칭
    /// - 일반: 로컬 타임존 포함 ("2026-02-02T18:21:00+09:00")
    private func formatEventTimes(_ event: Event) -> (startAt: String, endAt: String) {
        let cal = Calendar.current
        if event.isAllDay {
            let startDay = cal.startOfDay(for: event.startDate)
            let endDay = cal.startOfDay(for: event.endDate)
            let compsStart = cal.dateComponents([.year, .month, .day], from: startDay)
            let compsEnd = cal.dateComponents([.year, .month, .day], from: endDay)
            guard let utcStart = Self.utcCalendar.date(from: compsStart),
                  let utcEndDay = Self.utcCalendar.date(from: compsEnd),
                  let utcEnd = Self.utcCalendar.date(bySettingHour: 23, minute: 59, second: 0, of: utcEndDay) else {
                return (Self.localISO8601Formatter.string(from: event.startDateTime(calendar: cal)),
                        Self.localISO8601Formatter.string(from: event.endDateTime(calendar: cal)))
            }
            return (Self.utcISO8601Formatter.string(from: utcStart),
                    Self.utcISO8601Formatter.string(from: utcEnd))
        }
        let startDt = event.startDateTime(calendar: cal)
        let endDt = event.endDateTime(calendar: cal)
        return (Self.localISO8601Formatter.string(from: startDt), Self.localISO8601Formatter.string(from: endDt))
    }

    // MARK: - DTO → 도메인 매핑

    /// 일간 일정 DTO → 캘린더 표시용 Event (api: itemId, startAt/endAt ISO, eventColor, point 등)
    private func mapToEvent(item: CalendarItemDTO, date: String) -> Event {
        let isFixed = item.isFixed ?? (item.type == "FIXED")
        let serverIdInt = Int(item.itemId)
        let id = Self.stableUUID(from: "\(item.type)-\(item.itemId)")

        let (startDate, endDate, startTime, endTime, isAllDay): (Date, Date, Time, Time, Bool)
        if let startDt = item.startAt, let endDt = item.endAt,
           !startDt.isEmpty, !endDt.isEmpty,
           let start = parseISO8601Date(startDt), let end = parseISO8601Date(endDt) {

            let utcCal = Self.utcCalendar
            let isUTCAllDay = utcCal.component(.hour, from: start) == 0
                && utcCal.component(.minute, from: start) == 0
                && utcCal.component(.hour, from: end) == 23
                && utcCal.component(.minute, from: end) >= 59

            if isUTCAllDay {
                let startComps = utcCal.dateComponents([.year, .month, .day], from: start)
                let endComps = utcCal.dateComponents([.year, .month, .day], from: end)
                let localStart = calendar.date(from: startComps).flatMap { calendar.startOfDay(for: $0) }
                    ?? calendar.startOfDay(for: start)
                let localEnd = calendar.date(from: endComps).flatMap { calendar.startOfDay(for: $0) }
                    ?? calendar.startOfDay(for: end)
                (startDate, endDate, startTime, endTime, isAllDay) = (
                    localStart, localEnd, .midnight, .endOfDay, true
                )
            } else {
                let allDay = isAllDayEvent(start: start, end: end)
                let startDay = calendar.startOfDay(for: start)
                let endDay = calendar.startOfDay(for: end)
                (startDate, endDate, startTime, endTime, isAllDay) = (
                    startDay,
                    endDay,
                    allDay ? .midnight : Time(from: start, calendar: calendar),
                    allDay ? .endOfDay : Time(from: end, calendar: calendar),
                    allDay
                )
            }
        } else {
            let day = Self.dateOnlyFormatter.date(from: date) ?? Date()
            let startDay = calendar.startOfDay(for: day)
            (startDate, endDate, startTime, endTime, isAllDay) = (
                startDay, startDay, .midnight, .endOfDay, true
            )
        }

        let color: EventColorType = item.eventColor.map { EventColorType.from(serverColor: $0) }
            ?? (isFixed ? .purple1 : Self.colorForServerItem(type: item.type, itemId: item.itemId))

        let category: EventCategory = {
            switch item.category?.uppercased() {
            case "GROWTH": return .growth
            case "REST": return .rest
            default: return .none
            }
        }()

        let eventType: EventType = (item.type == "ACTIVITY") ? .activity : .fixed
        let isCompleted = item.status?.uppercased() == "DONE"
        let (repeatType, repeatWeekdays) = Self.parseRecurrenceRule(item.recurrenceRule)
        let isRepeating = repeatType != nil
        let activityPointValue = item.point ?? (isFixed ? nil : 20)

        return Event(
            id: id,
            title: item.title,
            isFixed: isFixed,
            isAllDay: isAllDay,
            color: color,
            type: eventType,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            category: category,
            isCompleted: isCompleted,
            isRepeating: isRepeating,
            repeatOption: repeatType,
            fixedScheduleId: isFixed ? serverIdInt : nil,
            myActivityId: isFixed ? nil : serverIdInt,
            repeatWeekdays: repeatWeekdays,
            activityPoint: activityPointValue
        )
    }

    /// startDateTime/endDateTime 기준 종일 여부 (시작 00:00 + 종료 당일 23:59 또는 다음날 00:00)
    private func isAllDayEvent(start: Date, end: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: start)
        guard start.timeIntervalSince(startOfDay) < 60 else { return false }
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: start) ?? start
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? start
        return (calendar.isDate(end, inSameDayAs: start) && end >= endOfDay)
            || abs(end.timeIntervalSince(nextDayStart)) <= 60
    }

    /// 서버에서 색을 주지 않을 때 itemId 기준 동일 색이 나오도록 하는 팔레트
    private static let serverEventColorPalette: [EventColorType] = [.purple2, .blue1, .red, .yellow, .blue2, .pink, .green, .blue3, .purple1]

    /// 서버 일정용 색 (type+itemId 해시로 동일 일정은 항상 같은 색). UInt64 모듈로로 abs(Int.min) 오버플로우 방지.
    private static func colorForServerItem(type: String, itemId: String) -> EventColorType {
        var data = Data()
        data.append(contentsOf: "\(type)-\(itemId)".utf8)
        let hash = Insecure.SHA1.hash(data: data)
        let index = hash.withUnsafeBytes { bytes in bytes.load(as: UInt64.self) }
        let paletteCount = UInt64(serverEventColorPalette.count)
        let safeIndex = Int(index % paletteCount)
        return serverEventColorPalette[safeIndex]
    }

    /// itemId 등 문자열로부터 동일 입력에 대해 항상 같은 UUID 생성 (서버 항목 식별용). UUID v5(SHA-1 기반) 사용.
    private static func stableUUID(from string: String) -> UUID {
        let namespace = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")!
        var data = Data()
        withUnsafeBytes(of: namespace.uuid) { data.append(contentsOf: $0) }
        data.append(contentsOf: string.utf8)
        let hash = Insecure.SHA1.hash(data: data)
        var bytes = Array(Array(hash).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }

    // MARK: - recurrenceRule ↔ RepeatType 변환

    private static let bydayMap: [(index: Int, code: String)] = [
        (0, "MO"), (1, "TU"), (2, "WE"), (3, "TH"), (4, "FR"), (5, "SA"), (6, "SU")
    ]

    static func parseRecurrenceRule(_ rule: String?) -> (repeatType: RepeatType?, weekdays: [Int]?) {
        guard let rule = rule, !rule.isEmpty else { return (nil, nil) }
        var parts: [String: String] = [:]
        for component in rule.split(separator: ";") {
            let kv = component.split(separator: "=", maxSplits: 1)
            if kv.count == 2 { parts[String(kv[0])] = String(kv[1]) }
        }
        guard let freq = parts["FREQ"] else { return (nil, nil) }
        let interval = parts["INTERVAL"].flatMap { Int($0) } ?? 1
        var weekdays: [Int]?
        if let byDay = parts["BYDAY"] {
            weekdays = byDay.split(separator: ",").compactMap { code in
                bydayMap.first(where: { $0.code == code })?.index
            }
        }
        switch freq {
        case "DAILY": return (.daily, nil)
        case "WEEKLY":
            if interval >= 2 { return (.biweekly, weekdays) }
            return (.weekly, weekdays)
        case "MONTHLY": return (.monthly, nil)
        case "YEARLY": return (.yearly, nil)
        default: return (nil, nil)
        }
    }

    static func buildRecurrenceRule(from event: Event) -> String? {
        guard event.isRepeating, let repeatType = event.repeatOption else { return nil }
        switch repeatType {
        case .daily: return "FREQ=DAILY;INTERVAL=1"
        case .weekly:
            let byday = buildByday(event.repeatWeekdays)
            return byday != nil ? "FREQ=WEEKLY;\(byday!)" : "FREQ=WEEKLY;INTERVAL=1"
        case .biweekly:
            let byday = buildByday(event.repeatWeekdays)
            return byday != nil ? "FREQ=WEEKLY;INTERVAL=2;\(byday!)" : "FREQ=WEEKLY;INTERVAL=2"
        case .monthly: return "FREQ=MONTHLY;INTERVAL=1"
        case .yearly: return "FREQ=YEARLY;INTERVAL=1"
        }
    }

    private static func buildByday(_ weekdays: [Int]?) -> String? {
        guard let weekdays = weekdays, !weekdays.isEmpty else { return nil }
        let codes = weekdays.sorted().compactMap { idx in bydayMap.first(where: { $0.index == idx })?.code }
        guard !codes.isEmpty else { return nil }
        return "BYDAY=\(codes.joined(separator: ","))"
    }

    // MARK: - Google Calendar (가져오기 선택용)

    private func mapToImportableSchedule(_ dto: GoogleCalendarEventDTO) -> ImportableSchedule {
        let start = parseGoogleDate(dto.startAt)
        let end = parseGoogleDate(dto.endAt)
        let timeDesc = buildTimeDescription(allDay: dto.allDay, start: start, end: end, recurrence: dto.recurrence)
        return ImportableSchedule(
            id: dto.externalEventId,
            title: dto.title,
            timeDescription: timeDesc,
            startDate: start,
            endDate: end,
            isSelected: false
        )
    }

    private func buildTimeDescription(allDay: Bool, start: Date, end: Date, recurrence: String?) -> String {
        if allDay {
            if calendar.isDate(start, inSameDayAs: end) {
                return Self.monthDayFormatter.string(from: start)
            }
            return "\(Self.monthDayFormatter.string(from: start)) - \(Self.monthDayFormatter.string(from: end))"
        }
        let startStr = Self.timeFormatter.string(from: start)
        let endStr = Self.timeFormatter.string(from: end)
        if let r = recurrence, !r.isEmpty { return "\(startStr) - \(endStr) (반복)" }
        return "\(startStr) - \(endStr)"
    }

    private func parseGoogleDate(_ string: String) -> Date {
        if let d = Self.iso8601WithFraction.date(from: string) { return d }
        if let d = Self.iso8601NoFraction.date(from: string) { return d }
        return Self.dateOnlyFormatter.date(from: String(string.prefix(10))) ?? Date()
    }

    /// ISO8601 문자열 → Date (연동일·마지막 동기화일 파싱)
    private func parseISO8601(_ string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }
        if let d = Self.iso8601WithFraction.date(from: string) { return d }
        if let d = Self.iso8601NoFraction.date(from: string) { return d }
        return Self.dateOnlyFormatter.date(from: String(string.prefix(10)))
    }

    // MARK: - Formatters (일간 조회·구글 일정·ISO 파싱용)

    private static let utcCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    private static let utcISO8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    /// 일반 일정 요청용 (로컬 타임존, 예: 2026-02-12T14:00:00+09:00)
    private static let localISO8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone.current
        return f
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private static let iso8601WithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso8601NoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// ISO8601 또는 yyyy-MM-dd 날짜 문자열 파싱 (일간 item startAt/endAt, Google events)
    private func parseISO8601Date(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        if let d = Self.iso8601WithFraction.date(from: string) { return d }
        if let d = Self.iso8601NoFraction.date(from: string) { return d }
        return Self.dateOnlyFormatter.date(from: String(string.prefix(10)))
    }

    /// Date → "yyyy-MM-dd" (API 쿼리/키용)
    private func dateKeyString(from date: Date) -> String {
        Self.dateOnlyFormatter.string(from: date)
    }
}
