//
//  CalendarAPIRepository.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//
//  Repository: NetworkService(DTO) → 도메인 매핑. ViewModel은 네트워크를 모름.
//

import Foundation
import CryptoKit

/// API 기반 캘린더 Repository. 월간/일간 조회 + 구글 캘린더 연동만 연동. 일정 추가/수정/삭제는 API 완성 후 재연결용 구조만 둠.
final class CalendarAPIRepository: CalendarRepositoryProtocol {
    private let networkService: CalendarNetworkService
    private let calendar = Calendar.current

    init(networkService: CalendarNetworkService = CalendarNetworkService()) {
        self.networkService = networkService
    }

    /// 월간 캘린더 조회 (GET /api/calendar/month) - 해당 월 날짜별 메타·프리뷰만
    func getMonthCalendar(year: Int, month: Int) async throws -> MonthlyCalendarSuccessDTO {
        try await networkService.getMonthCalendar(year: year, month: month)
    }

    /// 특정 날짜의 일정 목록 조회 (GET /api/calendar/day) - 날짜 클릭 시 호출
    func getEvents(for date: Date) async throws -> [Event] {
        let dateKey = dateKeyString(from: date)
        let dayDTO = try await networkService.getDayCalendar(date: dateKey)
        return dayDTO.todayTodos.map { mapToEvent(item: $0, date: dayDTO.date) }
    }

    /// 날짜 범위 내 일정 조회 (여러 일간 조회용)
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
            for try await events in group {
                allEvents.append(contentsOf: events)
            }
            return allEvents
        }
    }

    /// 일정 추가 (POST /api/calendar/event)
    func addEvent(_ event: Event) async throws {
        let (startAt, endAt) = formatEventTimes(event)
        let categoryStr = event.category == .none ? "GROWTH" : event.category.rawValue
        let colorInt = event.color.serverColor
        let rule = Self.buildRecurrenceRule(from: event)
        _ = try await networkService.createEvent(
            title: event.title, startAt: startAt, endAt: endAt, type: "FIXED",
            category: categoryStr, eventColor: colorInt, recurrenceRule: rule
        )
    }

    /// 일정 수정 (PATCH /api/calendar/event/{id}) — 고정 일정만 해당. 활동 일정 수정 API는 미완성이라 호출하지 않음.
    func updateEvent(_ event: Event) async throws {
        guard event.isFixed else { return }
        guard let serverId = event.fixedScheduleId ?? event.myActivityId else {
            throw CalendarRepositoryError.missingServerId(message: "서버 일정 ID가 없어 수정할 수 없습니다.")
        }
        let (startAt, endAt) = formatEventTimes(event)
        let categoryStr = event.category == .none ? "GROWTH" : event.category.rawValue
        let colorInt = event.color.serverColor
        let rule = Self.buildRecurrenceRule(from: event)
        try await networkService.updateEvent(
            id: serverId, title: event.title, startAt: startAt, endAt: endAt, type: "FIXED",
            category: categoryStr, eventColor: colorInt, recurrenceRule: rule
        )
    }

    /// 일정 삭제 (DELETE /api/calendar/event/{id})
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

    /// 선택 일정 서버 동기화 (POST sync 호출, 가져오기 확정 시).
    /// TODO: 현재 서버 API는 선택 일정 목록을 받지 않고 전체 동기화만 지원합니다. schedules 파라미터는 미사용이며, 호출 시 전체 sync가 수행됩니다.
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

    // MARK: - DTO → 도메인 매핑

    /// ISO8601 문자열 → Date (연동일·마지막 동기화일 파싱). static formatter 재사용.
    private func parseISO8601(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        if let d = Self.iso8601WithFraction.date(from: string) { return d }
        return Self.iso8601NoFraction.date(from: string)
    }

    /// 구글 일정 DTO → 가져오기 선택용 ImportableSchedule (Google 이벤트 ID는 UUID가 아니므로 String으로 보존)
    private func mapToImportableSchedule(_ dto: GoogleCalendarEventDTO) -> ImportableSchedule {
        let start = parseISO8601Date(dto.startAt) ?? Date()
        let end = parseISO8601Date(dto.endAt) ?? Date()
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

    /// 서버에서 색을 주지 않을 때 itemId 기준으로 항상 같은 색이 나오도록 사용하는 팔레트
    private static let serverEventColorPalette: [EventColorType] = [.purple2, .blue1, .red, .yellow, .blue2, .pink, .green, .blue3, .purple1]

    /// 서버 일정용 색 결정 (type+itemId 해시로 동일 일정은 항상 같은 색)
    private static func colorForServerItem(type: String, itemId: String) -> EventColorType {
        var data = Data()
        data.append(contentsOf: "\(type)-\(itemId)".utf8)
        let hash = Insecure.SHA1.hash(data: data)
        let index = hash.withUnsafeBytes { bytes in bytes.load(as: UInt64.self) }
        // UInt64에서 모듈로 연산을 먼저 수행해 abs(Int.min) 오버플로우 방지
        let paletteCount = UInt64(serverEventColorPalette.count)
        let safeIndex = Int(index % paletteCount)
        return serverEventColorPalette[safeIndex]
    }

    /// 일간 일정 DTO → 캘린더 표시용 Event (api.md 기준: itemId String, startAt/endAt ISO, eventColor)
    private func mapToEvent(item: CalendarItemDTO, date: String) -> Event {
        let isFixed = item.isFixed ?? (item.type == "FIXED")
        let serverIdInt = Int(item.itemId)
        let id = Self.stableUUID(from: "\(item.type)-\(item.itemId)")

        let (startDate, endDate, startTime, endTime, isAllDay): (Date, Date, Time, Time, Bool)
        if let startDt = item.startAt, let endDt = item.endAt,
           !startDt.isEmpty, !endDt.isEmpty,
           let start = parseISO8601Date(startDt), let end = parseISO8601Date(endDt) {

            // 1) UTC 하루종일 패턴 감지: start=00:00Z, end=23:59Z → UTC 날짜를 로컬 날짜로 변환
            let utcCal = Self.utcCalendar
            let isUTCAllDay = utcCal.component(.hour, from: start) == 0
                && utcCal.component(.minute, from: start) == 0
                && utcCal.component(.hour, from: end) == 23
                && utcCal.component(.minute, from: end) >= 59

            if isUTCAllDay {
                // UTC 날짜 숫자를 로컬 캘린더에 그대로 적용 (2/2 UTC → 2/2 로컬)
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
                // 2) 로컬 시간 기준 하루종일 감지 (기존 +09:00 형식으로 저장된 일정 호환)
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
            // startAt/endAt 없으면 해당 날짜의 종일 일정으로 처리
            let day = Self.dateOnlyFormatter.date(from: date) ?? Date()
            let startDay = calendar.startOfDay(for: day)
            let endDay = startDay
            (startDate, endDate, startTime, endTime, isAllDay) = (
                startDay, endDay, .midnight, .endOfDay, true
            )
        }

        let color: EventColorType = item.eventColor.map { EventColorType.from(serverColor: $0) }
            ?? (isFixed ? .purple1 : Self.colorForServerItem(type: item.type, itemId: item.itemId))

        // category 매핑
        let category: EventCategory = {
            switch item.category?.uppercased() {
            case "GROWTH": return .growth
            case "REST": return .rest
            default: return .none
            }
        }()

        // type 매핑: ACTIVITY → .activity, FIXED/MANUAL → .fixed
        let eventType: EventType = (item.type == "ACTIVITY") ? .activity : .fixed

        // status 매핑: "DONE" → true
        let isCompleted = item.status?.uppercased() == "DONE"

        // recurrenceRule 파싱
        let (repeatType, repeatWeekdays) = Self.parseRecurrenceRule(item.recurrenceRule)
        let isRepeating = repeatType != nil

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
            repeatWeekdays: repeatWeekdays
        )
    }

    /// startDateTime/endDateTime 기준으로 종일 일정 여부 (시작 00:00 + 종료 당일 23:59 또는 다음날 00:00)
    private func isAllDayEvent(start: Date, end: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: start)
        let isStartMidnight = start.timeIntervalSince(startOfDay) < 60
        guard isStartMidnight else { return false }
        // 종료가 같은 날 23:59(:00 이상) 이거나 다음날 자정 부근(±60초)이면 종일
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: start) ?? start
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? start
        let isEndSameDayEOD = calendar.isDate(end, inSameDayAs: start) && end >= endOfDay
        let isEndNextDayStart = abs(end.timeIntervalSince(nextDayStart)) <= 60
        return isEndSameDayEOD || isEndNextDayStart
    }

    /// itemId 등 문자열로부터 동일 입력에 대해 항상 같은 UUID 생성 (서버 항목 식별용).
    /// Hasher는 프로세스별 시드로 앱 재시작 시 값이 바뀌므로, UUID v5(SHA-1 기반) 사용.
    private static func stableUUID(from string: String) -> UUID {
        let namespace = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")! // RFC 4122 DNS namespace
        var data = Data()
        withUnsafeBytes(of: namespace.uuid) { data.append(contentsOf: $0) }
        data.append(contentsOf: string.utf8)
        let hash = Insecure.SHA1.hash(data: data)
        var bytes = Array(Array(hash).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50  // version 5
        bytes[8] = (bytes[8] & 0x3F) | 0x80  // variant RFC 4122
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }

    // MARK: - Event → ISO 변환 (일정 추가/수정 요청용)

    /// Event의 isAllDay 여부에 따라 ISO 문자열 포맷을 분기.
    /// - 하루종일: UTC 자정 기준으로 전송 ("2026-02-02T00:00:00Z" ~ "2026-02-02T23:59:00Z")
    ///   → 서버가 UTC 날짜로 매칭하므로 날짜가 밀리지 않음
    /// - 일반: 로컬 타임존 포함 ("2026-02-02T18:21:00+09:00")
    private func formatEventTimes(_ event: Event) -> (startAt: String, endAt: String) {
        if event.isAllDay {
            // 로컬 날짜의 year/month/day를 UTC 자정으로 변환
            let startComps = calendar.dateComponents([.year, .month, .day], from: event.startDate)
            let endComps = calendar.dateComponents([.year, .month, .day], from: event.endDate)
            guard let utcStart = Self.utcCalendar.date(from: startComps),
                  let utcEndDay = Self.utcCalendar.date(from: endComps),
                  let utcEnd = Self.utcCalendar.date(bySettingHour: 23, minute: 59, second: 0, of: utcEndDay) else {
                // fallback: 로컬 포맷
                return (formatToISO(event.startDateTime()), formatToISO(event.endDateTime()))
            }
            return (Self.utcISO8601Formatter.string(from: utcStart),
                    Self.utcISO8601Formatter.string(from: utcEnd))
        } else {
            return (formatToISO(event.startDateTime()), formatToISO(event.endDateTime()))
        }
    }

    /// Date → "2026-02-12T18:10:00+09:00" (로컬 타임존 포함 ISO 8601)
    private func formatToISO(_ date: Date) -> String {
        Self.localISO8601Formatter.string(from: date)
    }

    private static let localISO8601Formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    /// UTC ISO 8601 포맷터 (하루종일 일정 전송용)
    private static let utcISO8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(identifier: "UTC")!
        return f
    }()

    /// UTC 기준 Calendar (하루종일 날짜 변환용)
    private static let utcCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    // MARK: - Formatters (일간 조회·구글 일정 매핑용)

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

    /// 종일/시간형·반복 여부에 따라 표시용 시간 문자열 생성 (구글 일정 → ImportableSchedule)
    private func buildTimeDescription(allDay: Bool, start: Date, end: Date, recurrence: String?) -> String {
        if allDay {
            if Calendar.current.isDate(start, inSameDayAs: end) {
                return Self.monthDayFormatter.string(from: start)
            }
            return "\(Self.monthDayFormatter.string(from: start)) - \(Self.monthDayFormatter.string(from: end))"
        }
        let startStr = Self.timeFormatter.string(from: start)
        let endStr = Self.timeFormatter.string(from: end)
        if let r = recurrence, !r.isEmpty { return "\(startStr) - \(endStr) (반복)" }
        return "\(startStr) - \(endStr)"
    }

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

    /// ISO8601 또는 yyyy-MM-dd 날짜 문자열 파싱 (Google events start/end: dateTime 또는 date)
    private func parseISO8601Date(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        if let d = Self.iso8601WithFraction.date(from: string) { return d }
        if let d = Self.iso8601NoFraction.date(from: string) { return d }
        return Self.dateOnlyFormatter.date(from: string)
    }

    /// Date → "yyyy-MM-dd" (API 쿼리/키용)
    private func dateKeyString(from date: Date) -> String {
        Self.dateOnlyFormatter.string(from: date)
    }

    // MARK: - recurrenceRule ↔ RepeatType 변환

    /// 요일 인덱스 (앱 내부: 0=월 ~ 6=일) ↔ BYDAY 약자
    private static let bydayMap: [(index: Int, code: String)] = [
        (0, "MO"), (1, "TU"), (2, "WE"), (3, "TH"), (4, "FR"), (5, "SA"), (6, "SU")
    ]

    /// 서버 recurrenceRule → (RepeatType, weekdays)
    /// 예: "FREQ=WEEKLY;BYDAY=MO,WE" → (.weekly, [0, 2])
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
        case "DAILY":
            return (.daily, nil)
        case "WEEKLY":
            if interval >= 2 { return (.biweekly, weekdays) }
            return (.weekly, weekdays)
        case "MONTHLY":
            return (.monthly, nil)
        case "YEARLY":
            return (.yearly, nil)
        default:
            return (nil, nil)
        }
    }

    /// Event의 반복 설정 → 서버 recurrenceRule 문자열
    /// 예: (.weekly, [0, 2]) → "FREQ=WEEKLY;BYDAY=MO,WE"
    static func buildRecurrenceRule(from event: Event) -> String? {
        guard event.isRepeating, let repeatType = event.repeatOption else { return nil }
        switch repeatType {
        case .daily:
            return "FREQ=DAILY;INTERVAL=1"
        case .weekly:
            let byday = buildByday(event.repeatWeekdays)
            return byday != nil ? "FREQ=WEEKLY;\(byday!)" : "FREQ=WEEKLY;INTERVAL=1"
        case .biweekly:
            let byday = buildByday(event.repeatWeekdays)
            return byday != nil ? "FREQ=WEEKLY;INTERVAL=2;\(byday!)" : "FREQ=WEEKLY;INTERVAL=2"
        case .monthly:
            return "FREQ=MONTHLY;INTERVAL=1"
        case .yearly:
            return "FREQ=YEARLY;INTERVAL=1"
        }
    }

    private static func buildByday(_ weekdays: [Int]?) -> String? {
        guard let weekdays = weekdays, !weekdays.isEmpty else { return nil }
        let codes = weekdays.sorted().compactMap { idx in
            bydayMap.first(where: { $0.index == idx })?.code
        }
        guard !codes.isEmpty else { return nil }
        return "BYDAY=\(codes.joined(separator: ","))"
    }
}
