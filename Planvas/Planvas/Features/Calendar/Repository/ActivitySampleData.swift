//
//  ActivitySampleData.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//
//  TODO: 활동 일정 추가 폼 샘플 데이터. API 연동 시 Repository에서 실데이터로 교체.
//

import Foundation

enum ActivitySampleData {
    private static let calendar = Calendar.current

    /// AddActivityView 폼용 샘플 ViewModel 데이터
    static func sampleAddActivityViewModel() -> AddActivityViewModel {
        let start = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15)) ?? Date()
        let end = calendar.date(from: DateComponents(year: 2026, month: 2, day: 28)) ?? Date()
        let vm = AddActivityViewModel()
        vm.title = "패스트 캠퍼스 2026 AI 대전환 오픈 세미나"
        vm.targetPeriod = "12/15 ~ 2/28"
        vm.startDate = start
        vm.endDate = end
        vm.currentAchievementPercent = 10
        vm.activityValue = 20
        vm.recommendedPoint = 30
        vm.goalPercent = 60
        vm.growthLabel = "성장"
        return vm
    }
}
