//
//  CalendarRepository.swift
//  Planvas
//
//  Created on 1/22/26.
//

import Foundation

/// Calendar 관련 데이터를 관리하는 repo
/// TODO : API 연동 시 이 프로토콜을 구현하는 새로운 Repository를 만들고 ViewModel에 주입 예정
protocol CalendarRepositoryProtocol {
    /// 특정 날짜의 이벤트 목록을 가져옵니다
    func getEvents(for date: Date) async throws -> [Event]
    
    /// 특정 날짜 범위의 이벤트 목록을 가져옵니다
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event]
    
    /// 이벤트를 추가합니다
    func addEvent(_ event: Event) async throws
    
    /// 이벤트를 업데이트합니다
    func updateEvent(_ event: Event) async throws
    
    /// 이벤트를 삭제합니다
    func deleteEvent(_ event: Event) async throws
    
    /// ImportableSchedule 목록을 가져옵니다
    func getImportableSchedules() async throws -> [ImportableSchedule]
    
    /// ImportableSchedule을 Event로 변환하여 추가합니다
    func importSchedules(_ schedules: [ImportableSchedule]) async throws
}

/// TODO : 현재는 샘플 데이터를 사용
final class CalendarRepository: CalendarRepositoryProtocol {
    // 샘플 데이터 (API 연동 전까지)
    private var sampleEvents: [String: [Event]] = [
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
    
    private func dateKeyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getEvents(for date: Date) async throws -> [Event] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        let dateKey = dateKeyString(from: date)
        return sampleEvents[dateKey] ?? []
    }
    
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [Event] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        var allEvents: [Event] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            let events = try await getEvents(for: currentDate)
            allEvents.append(contentsOf: events)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return allEvents
    }
    
    func addEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        // 현재는 샘플 데이터에 추가만
    }
    
    func updateEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
    }
    
    func deleteEvent(_ event: Event) async throws {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
    }
    
    func getImportableSchedules() async throws -> [ImportableSchedule] {
        // TODO : API 연동 시 이 부분을 네트워크 호출로 변경
        // 샘플 데이터 (API 연동 시 이 부분만 수정)
        return [
            ImportableSchedule(title: "카페 알바", timeDescription: "매주 수요일 18:00 - 22:00", isSelected: true),
            ImportableSchedule(title: "토익 학원", timeDescription: "매주 목요일 9:00 - 13:00", isSelected: false),
            ImportableSchedule(title: "헬스장 PT", timeDescription: "매주 토요일 17:00 - 18:00", isSelected: false),
            ImportableSchedule(title: "엄마 생신", timeDescription: "2025년 12월 13일", isSelected: true),
            ImportableSchedule(title: "베트남 여행", timeDescription: "2025년 12월 15일 - 2025년 12월 18일", isSelected: true),
            ImportableSchedule(title: "동아리 송년회", timeDescription: "2025년 12월 25일", isSelected: false)
        ]
    }
    
    func importSchedules(_ schedules: [ImportableSchedule]) async throws {
        // ImportableSchedule을 Event로 변환하여 추가
        // TODO : API 연동 시 이 부분을 수정
        for _ in schedules {
            // 여기서는 샘플로 간단하게 처리
        }
    }
}
