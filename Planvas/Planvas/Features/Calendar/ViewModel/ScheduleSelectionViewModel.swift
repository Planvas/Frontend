//
//  ScheduleSelectionViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/20/26.
//

import SwiftUI
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
        // TODO: API 연동 시 이 부분을 수정
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let fetchedSchedules = try await repository.getImportableSchedules()
                schedules = fetchedSchedules
            } catch {
                errorMessage = "일정을 불러오는데 실패했습니다."
                print("일정 로드 실패: \(error)")
                // 에러 발생 시 샘플 데이터 사용
                loadSampleSchedules()
            }
            
            isLoading = false
        }
    }
    
    private func loadSampleSchedules() {
        // TODO: 샘플 데이터 (API 연동 시 제거)
        schedules = [
            ImportableSchedule(title: "카페 알바", timeDescription: "매주 수요일 18:00 - 22:00", isSelected: true),
            ImportableSchedule(title: "토익 학원", timeDescription: "매주 목요일 9:00 - 13:00", isSelected: false),
            ImportableSchedule(title: "헬스장 PT", timeDescription: "매주 토요일 17:00 - 18:00", isSelected: false),
            ImportableSchedule(title: "엄마 생신", timeDescription: "2025년 12월 13일", isSelected: true),
            ImportableSchedule(title: "베트남 여행", timeDescription: "2025년 12월 15일 - 2025년 12월 18일", isSelected: true),
            ImportableSchedule(title: "동아리 송년회", timeDescription: "2025년 12월 25일", isSelected: false)
        ]
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
