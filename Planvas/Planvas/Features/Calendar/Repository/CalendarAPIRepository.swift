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
        return dayDTO.items.map { mapToEvent(item: $0, date: dayDTO.date) }
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

    /// 일정 추가 (API 완성 후 재연결 예정)
    func addEvent(_ event: Event) async throws {
        throw CalendarRepositoryError.notImplemented(message: "일정 추가 API 연동 예정")
    }

    /// 일정 수정 (API 완성 후 재연결 예정)
    func updateEvent(_ event: Event) async throws {
        throw CalendarRepositoryError.notImplemented(message: "일정 수정 API 연동 예정")
    }

    /// 일정 삭제 (API 완성 후 재연결 예정)
    func deleteEvent(_ event: Event) async throws {
        throw CalendarRepositoryError.notImplemented(message: "일정 삭제 API 연동 예정")
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

    /// 일간 일정 DTO → 캘린더 표시용 Event (날짜+시간 조합, 서버 ID 매핑).
    /// API는 startDateTime/endDateTime(ISO8601) 또는 date+startTime/endTime(시:분)으로 옴. 종일이면 "하루종일" 표시.
    private func mapToEvent(item: CalendarItemDTO, date: String) -> Event {
        let isFixed = item.type == "FIXED"
        let serverId = item.itemId
        let id = Self.stableUUID(from: "\(item.type)-\(item.itemId)")

        let (startDate, endDate, startTime, endTime, isAllDay): (Date, Date, Time, Time, Bool)
        if let startDt = item.startDateTime, let endDt = item.endDateTime,
           !startDt.isEmpty, !endDt.isEmpty,
           let start = parseDayDateTimeAsLocal(startDt), let end = parseDayDateTimeAsLocal(endDt) {
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
        } else {
            let st = item.startTime ?? ""
            let et = item.endTime ?? ""
            let (s, e) = parseDayTime(date: date, startTime: st, endTime: et)
            let allDay = st.isEmpty && et.isEmpty
            let startDay = calendar.startOfDay(for: s)
            let endDay = calendar.startOfDay(for: e)
            (startDate, endDate, startTime, endTime, isAllDay) = (
                startDay,
                endDay,
                allDay ? .midnight : Time(from: s, calendar: calendar),
                allDay ? .endOfDay : Time(from: e, calendar: calendar),
                allDay
            )
        }

        return Event(
            id: id,
            title: item.title,
            isFixed: isFixed,
            isAllDay: isAllDay,
            color: isFixed ? .purple1 : Self.colorForServerItem(type: item.type, itemId: "\(item.itemId)"),
            type: isFixed ? .fixed : .activity,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            category: .none,
            isCompleted: item.completed ?? false,
            isRepeating: isFixed,
            fixedScheduleId: isFixed ? serverId : nil,
            myActivityId: isFixed ? nil : serverId
        )
    }

    /// startDateTime/endDateTime 기준으로 종일 일정 여부 (시작 00:00 + 종료 당일 23:59 또는 다음날 00:00)
    private func isAllDayEvent(start: Date, end: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: start)
        let isStartMidnight = start.timeIntervalSince(startOfDay) < 60
        guard isStartMidnight else { return false }
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: start) ?? start
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? start
        let isEndSameDayEOD = calendar.isDate(end, inSameDayAs: start) && end >= endOfDay
        let isEndNextDayStart = abs(end.timeIntervalSince(nextDayStart)) < 60
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

    /// 일간 API startAt/endAt: 서버가 로컬 시간을 Z로 보내는 경우를 위해, 날짜·시간을 로컬 타임존으로 해석.
    /// (예: "2026-02-19T16:10:00.000Z" → 16:10 로컬, UTC로 해석하면 KST에서 01:10으로 나옴)
    private static let dayDateTimeAsLocalFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        f.timeZone = TimeZone.current
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let dayDateTimeAsLocalFormatterNoFraction: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        f.timeZone = TimeZone.current
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private func parseDayDateTimeAsLocal(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        if let d = Self.dayDateTimeAsLocalFormatter.date(from: string) { return d }
        return Self.dayDateTimeAsLocalFormatterNoFraction.date(from: string)
    }

    /// "yyyy-MM-dd" + "HH:mm" 조합으로 해당 날짜의 시작/종료 Date 생성 (종일이면 00:00~다음날 00:00)
    private func parseDayTime(date: String, startTime: String, endTime: String) -> (Date, Date) {
        let day = Self.dateOnlyFormatter.date(from: date) ?? Date()
        if startTime.isEmpty && endTime.isEmpty {
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        }
        let start = combine(date: day, time: startTime, formatter: Self.timeFormatter) ?? day
        let end = combine(date: day, time: endTime, formatter: Self.timeFormatter) ?? day
        return (start, end)
    }

    /// 날짜에 시:분 적용해 하나의 Date 반환
    private func combine(date: Date, time: String, formatter: DateFormatter) -> Date? {
        guard let t = formatter.date(from: time) else { return nil }
        let comps = calendar.dateComponents([.hour, .minute], from: t)
        return calendar.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: date)
    }

    /// Date → "yyyy-MM-dd" (API 쿼리/키용)
    private func dateKeyString(from date: Date) -> String {
        Self.dateOnlyFormatter.string(from: date)
    }
}
