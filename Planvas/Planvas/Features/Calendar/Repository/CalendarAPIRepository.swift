//
//  CalendarAPIRepository.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//
//  Repository: NetworkService(DTO) → 도메인 매핑. ViewModel은 네트워크를 모름.
//

import Foundation

/// API 기반 캘린더 Repository (CalendarNetworkService + SchedulesNetworkService)
final class CalendarAPIRepository: CalendarRepositoryProtocol {
    private let networkService: CalendarNetworkService
    private let schedulesService: SchedulesNetworkService
    private let calendar = Calendar.current

    init(
        networkService: CalendarNetworkService = CalendarNetworkService(),
        schedulesService: SchedulesNetworkService = SchedulesNetworkService()
    ) {
        self.networkService = networkService
        self.schedulesService = schedulesService
    }

    /// 특정 날짜의 일정 목록 조회 (GET /api/calendar/day → Event 배열)
    func getEvents(for date: Date) async throws -> [Event] {
        let dateKey = dateKeyString(from: date)
        let dayDTO = try await networkService.getDayCalendar(date: dateKey)
        return dayDTO.items.map { mapToEvent(item: $0, date: dayDTO.date) }
    }

    /// 날짜 범위 내 모든 일정 조회 (구간 내 날짜별 getDay 호출 후 합침)
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        var allEvents: [Event] = []
        var current = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        while current <= endDay {
            let events = try await getEvents(for: current)
            allEvents.append(contentsOf: events)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return allEvents
    }

    /// 일정 추가: 고정 일정(반복) → fixed-schedules, 반복 없음 → my-activities
    func addEvent(_ event: Event) async throws {
        if event.isRepeating {
            // 고정 일정 = 반복 일정
            let dto = buildCreateScheduleRequest(from: event)
            _ = try await schedulesService.postAddSchedule(dto)
        } else {
            // 반복하지 않는 일정 = 내 활동
            let dto = buildCreateMyActivityRequest(from: event)
            _ = try await schedulesService.postMyActivity(dto)
        }
    }

    /// 일정 수정: fixedScheduleId → PATCH fixed-schedules, myActivityId → PATCH my-activities
    func updateEvent(_ event: Event) async throws {
        if let id = event.fixedScheduleId {
            let dto = buildEditScheduleRequest(from: event)
            try await schedulesService.patchSchedule(id: id, dto)
        } else if let id = event.myActivityId {
            let dto = buildEditMyActivityRequest(from: event)
            try await schedulesService.patchMyActivity(id: id, dto)
        }
        // 서버 ID 없으면 수정 API 호출 불가 (로컬 전용이면 no-op)
    }

    /// 일정 삭제: fixedScheduleId → DELETE fixed-schedules, myActivityId → DELETE my-activities
    func deleteEvent(_ event: Event) async throws {
        if let id = event.fixedScheduleId {
            try await schedulesService.deleteSchedule(id: id)
        } else if let id = event.myActivityId {
            try await schedulesService.deleteMyActivity(id: id)
        }
    }

    /// 구글 캘린더에서 가져올 수 있는 일정 목록 (GET events → ImportableSchedule, 일정 선택 화면용)
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        let events = try await networkService.getGoogleCalendarEvents(timeMin: nil, timeMax: nil)
        return events.map { mapToImportableSchedule($0) }
    }

    /// 선택 일정 서버 동기화 (POST sync 호출, 가져오기 확정 시)
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

    /// ISO8601 문자열 → Date (연동일·마지막 동기화일 파싱)
    private func parseISO8601(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = full.date(from: string) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: string)
    }

    /// 구글 일정 DTO → 가져오기 선택용 ImportableSchedule
    private func mapToImportableSchedule(_ dto: GoogleCalendarEventDTO) -> ImportableSchedule {
        let start = parseISO8601Date(dto.startAt) ?? Date()
        let end = parseISO8601Date(dto.endAt) ?? Date()
        let timeDesc = buildTimeDescription(allDay: dto.allDay, start: start, end: end, recurrence: dto.recurrence)
        let id = UUID(uuidString: dto.externalEventId) ?? UUID()
        return ImportableSchedule(
            id: id,
            title: dto.title,
            timeDescription: timeDesc,
            startDate: start,
            endDate: end,
            isSelected: false
        )
    }

    /// 일간 일정 DTO → 캘린더 표시용 Event (날짜+시간 조합, 서버 ID 매핑)
    private func mapToEvent(item: CalendarItemDTO, date: String) -> Event {
        let (startDate, endDate) = parseDayTime(date: date, startTime: item.startTime, endTime: item.endTime)
        let timeString = item.startTime.isEmpty && item.endTime.isEmpty
            ? "하루종일"
            : "\(item.startTime) - \(item.endTime)"
        let id = UUID(uuidString: item.itemId) ?? UUID()
        let isFixed = item.type == "FIXED_SCHEDULE"
        let serverId = Int(item.itemId)
        return Event(
            id: id,
            title: item.title,
            time: timeString,
            isFixed: isFixed,
            isAllDay: item.startTime.isEmpty && item.endTime.isEmpty,
            color: .red,
            startDate: startDate,
            endDate: endDate,
            category: .none,
            isCompleted: item.completed,
            isRepeating: isFixed,
            fixedScheduleId: isFixed ? serverId : nil,
            myActivityId: isFixed ? nil : serverId
        )
    }

    // MARK: - Event → Schedules DTO (고정 일정 / 내 활동)

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

    /// 0=월…6=일 → DayOfWeek
    private static func dayOfWeek(from index: Int) -> DayOfWeek {
        switch index {
        case 0: return .mon
        case 1: return .tue
        case 2: return .wed
        case 3: return .thu
        case 4: return .fri
        case 5: return .sat
        case 6: return .sun
        default: return .mon
        }
    }

    private func buildCreateScheduleRequest(from event: Event) -> CreateScheduleRequestDTO {
        let startDateStr = dateKeyString(from: event.startDate)
        let endDateStr = dateKeyString(from: event.endDate)
        let defaultWeekday = (calendar.component(.weekday, from: event.startDate) - 2 + 7) % 7
        let weekdays = (event.repeatWeekdays ?? [defaultWeekday]).map { Self.dayOfWeek(from: $0) }
        let (startTime, endTime) = event.isAllDay ? ("", "") : (Self.timeFormatter.string(from: event.startDate), Self.timeFormatter.string(from: event.endDate))
        return CreateScheduleRequestDTO(
            title: event.title,
            startDate: startDateStr,
            endDate: endDateStr,
            daysOfWeek: weekdays.isEmpty ? [Self.dayOfWeek(from: defaultWeekday)] : weekdays,
            startTime: startTime,
            endTime: endTime
        )
    }

    private func buildCreateMyActivityRequest(from event: Event) -> CreateMyActivityRequestDTO {
        let startDateStr = dateKeyString(from: event.startDate)
        let endDateStr = dateKeyString(from: event.endDate)
        let (startTime, endTime) = event.isAllDay ? ("", "") : (Self.timeFormatter.string(from: event.startDate), Self.timeFormatter.string(from: event.endDate))
        return CreateMyActivityRequestDTO(
            activityId: nil,
            title: event.title,
            category: eventCategoryToTodoCategory(event.category),
            point: event.activityPoint ?? 10,
            startDate: startDateStr,
            endDate: endDateStr,
            startTime: startTime,
            endTime: endTime
        )
    }

    private func buildEditScheduleRequest(from event: Event) -> EditScheduleRequestDTO {
        let (startTime, endTime) = event.isAllDay ? ("", "") : (Self.timeFormatter.string(from: event.startDate), Self.timeFormatter.string(from: event.endDate))
        let weekdays = (event.repeatWeekdays ?? []).map { Self.dayOfWeek(from: $0) }
        return EditScheduleRequestDTO(
            title: event.title,
            startDate: dateKeyString(from: event.startDate),
            endDate: dateKeyString(from: event.endDate),
            daysOfWeek: weekdays.isEmpty ? nil : weekdays,
            startTime: startTime,
            endTime: endTime
        )
    }

    private func buildEditMyActivityRequest(from event: Event) -> EditMyActivityRequestDTO {
        let (startTime, endTime) = event.isAllDay ? ("", "") : (Self.timeFormatter.string(from: event.startDate), Self.timeFormatter.string(from: event.endDate))
        return EditMyActivityRequestDTO(
            title: event.title,
            category: eventCategoryToTodoCategory(event.category),
            point: event.activityPoint,
            startDate: dateKeyString(from: event.startDate),
            endDate: dateKeyString(from: event.endDate),
            startTime: startTime,
            endTime: endTime
        )
    }

    private func eventCategoryToTodoCategory(_ category: EventCategory) -> TodoCategory {
        switch category {
        case .growth: return .growth
        case .rest: return .rest
        case .none: return .growth
        }
    }

    /// 종일/시간형·반복 여부에 따라 표시용 시간 문자열 생성 (예: "09:00 - 18:00", "M/d - M/d (반복)")
    private func buildTimeDescription(allDay: Bool, start: Date, end: Date, recurrence: String?) -> String {
        if allDay {
            let f = DateFormatter()
            f.dateFormat = "M/d"
            f.locale = Locale(identifier: "ko_KR")
            if Calendar.current.isDate(start, inSameDayAs: end) {
                return f.string(from: start)
            }
            return "\(f.string(from: start)) - \(f.string(from: end))"
        }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let startStr = f.string(from: start)
        let endStr = f.string(from: end)
        if let r = recurrence, !r.isEmpty { return "\(startStr) - \(endStr) (반복)" }
        return "\(startStr) - \(endStr)"
    }

    /// ISO8601 또는 yyyy-MM-dd 날짜 문자열 파싱 (Google events start/end: dateTime 또는 date)
    private func parseISO8601Date(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = full.date(from: string) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        if let d = fallback.date(from: string) { return d }
        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        return dateOnly.date(from: string)
    }

    /// "yyyy-MM-dd" + "HH:mm" 조합으로 해당 날짜의 시작/종료 Date 생성 (종일이면 00:00~다음날 00:00)
    private func parseDayTime(date: String, startTime: String, endTime: String) -> (Date, Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        let day = dateFormatter.date(from: date) ?? Date()
        if startTime.isEmpty && endTime.isEmpty {
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        }
        let start = combine(date: day, time: startTime, formatter: timeFormatter) ?? day
        let end = combine(date: day, time: endTime, formatter: timeFormatter) ?? day
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
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
