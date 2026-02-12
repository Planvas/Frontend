//
//  ActivityEventSampleData.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//
//  TODO: 활동일정(ActivityEvent) 및 활동 완료 알림 샘플 데이터. API 연동 시 Repository에서 실데이터로 교체.
//

import Foundation

enum ActivityEventSampleData {
    private static let calendar = Calendar.current

    /// 샘플 활동일정 Event (성장 활동, D-day, 12/18~12/20)
    static func sampleActivityEvent() -> Event {
        let start = calendar.date(from: DateComponents(year: 2025, month: 12, day: 18)) ?? Date()
        let end = calendar.date(from: DateComponents(year: 2025, month: 12, day: 20)) ?? Date()
        return Event(
            title: "삼성전자 대학생 프로그래밍 경진 대회",
            isAllDay: true,
            color: .purple2,
            type: .activity,
            startDate: start,
            endDate: end,
            startTime: .midnight,
            endTime: .endOfDay,
            category: .growth,
            isCompleted: false,
            isRepeating: false,
            activityPoint: 30
        )
    }

    /// 샘플 활동 완료 알림 ViewModel용 데이터
    static func sampleCompleteAlertViewModel() -> ActivityCompleteAlertViewModel {
        ActivityCompleteAlertViewModel(
            category: "성장",
            growthValue: 30,
            progressMinPercent: 10,
            goalPercent: 70,
            currentPercent: 40,
            confirmButtonTitle: "확인"
        )
    }
}
