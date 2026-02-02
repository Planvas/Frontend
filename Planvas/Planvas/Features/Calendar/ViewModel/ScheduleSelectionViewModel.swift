//
//  ScheduleSelectionViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/20/26.
//

import Foundation
import Combine

@MainActor
class ScheduleSelectionViewModel: ObservableObject {
    @Published var schedules: [ImportableSchedule] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: CalendarRepositoryProtocol
    
    var selectedCount: Int {
        schedules.filter { $0.isSelected }.count
    }
    
    var importButtonTitle: String {
        "\(selectedCount)개 일정 가져오기"
    }
    
    // MARK: - Initialization
    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarRepository()
        loadSchedules()
    }
    
    // MARK: - Methods
    func loadSchedules() {
        // TODO: API 연동 시 repository.getImportableSchedules() 호출로 교체
        isLoading = true
        errorMessage = nil
        // API 연동 전: ScheduleSelectionViewModel 샘플 데이터 표시
        loadSampleSchedules()
        isLoading = false
    }
    
    /// API 연동 전: 일정 가져오기 시 이 샘플 데이터가 표시됨 (API 연동 시 제거)
    private func loadSampleSchedules() {
        schedules = [
            ImportableSchedule(
                title: "편의점 알바",
                timeDescription: "매주 수요일 18:00 - 22:00",
                startDate: Self.makeDate(year: 2026, month: 2, day: 4, hour: 18),
                endDate: Self.makeDate(year: 2026, month: 2, day: 4, hour: 22),
                isSelected: true
            ),
            ImportableSchedule(
                title: "컴퓨터활용능력 학원",
                timeDescription: "매주 목요일 9:00 - 13:00",
                startDate: Self.makeDate(year: 2026, month: 2, day: 5, hour: 9),
                endDate: Self.makeDate(year: 2026, month: 2, day: 5, hour: 13),
                isSelected: false
            ),
            ImportableSchedule(
                title: "헬스장 PT",
                timeDescription: "매주 토요일 17:00 - 18:00",
                startDate: Self.makeDate(year: 2026, month: 2, day: 7, hour: 17),
                endDate: Self.makeDate(year: 2026, month: 2, day: 7, hour: 18),
                isSelected: false
            ),
            ImportableSchedule(
                title: "아빠 생신",
                timeDescription: "2026년 2월 7일",
                startDate: Self.makeDate(year: 2026, month: 2, day: 7),
                endDate: Self.makeDate(year: 2026, month: 2, day: 7),
                isSelected: true
            ),
            ImportableSchedule(
                title: "겨울 국내 여행",
                timeDescription: "2/15 - 2/18",
                startDate: Self.makeDate(year: 2026, month: 2, day: 15),
                endDate: Self.makeDate(year: 2026, month: 2, day: 18),
                isSelected: true
            ),
            ImportableSchedule(
                title: "개강 전 친구 모임",
                timeDescription: "2026년 2월 25일",
                startDate: Self.makeDate(year: 2026, month: 2, day: 25),
                endDate: Self.makeDate(year: 2026, month: 2, day: 25),
                isSelected: false
            )
        ]
    }
    
    private static func makeDate(year: Int, month: Int, day: Int, hour: Int? = nil) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        if let hour = hour {
            components.hour = hour
            components.minute = 0
        }
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func toggleSelection(for schedule: ImportableSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index].isSelected.toggle()
        }
    }
    
    func importSelectedSchedules() -> [ImportableSchedule] {
        return schedules.filter { $0.isSelected }
    }
}
