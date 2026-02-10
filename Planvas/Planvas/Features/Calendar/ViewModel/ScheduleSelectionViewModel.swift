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
        self.repository = repository ?? CalendarAPIRepository()
    }
    
    // MARK: - Methods
    /// 일정 목록 로드 (연동 완료 후 ScheduleSelectionView onAppear에서 호출 → GET /api/integrations/google-calendar/events 로 일정 표시)
    func loadSchedules() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                schedules = try await repository.getImportableSchedules()
            } catch {
                errorMessage = (error as? CalendarAPIError)?.reason ?? error.localizedDescription
                schedules = []
            }
            isLoading = false
        }
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
