//
//  ActivityEventSummaryViewModel.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import Foundation

@MainActor
@Observable
final class ActivityEventSummaryViewModel {
    var title: String
    var daysUntilLabel: String?
    var startDate: Date
    var endDate: Date
    /// 활동 타입 라벨 (예: "성장", "휴식"). 포인트와 함께 표시.
    var activityPointLabel: String?
    /// 활동치 포인트 (성장 또는 휴식)
    var activityPoints: Int?
    var completionMessage: String
    var editButtonTitle: String
    var completeButtonTitle: String
    var deleteButtonTitle: String

    init(
        title: String,
        daysUntilLabel: String? = nil,
        startDate: Date,
        endDate: Date,
        activityPointLabel: String? = nil,
        activityPoints: Int? = nil,
        completionMessage: String = "완료하면 목표 균형에 반영돼요!",
        editButtonTitle: String = "수정하기",
        completeButtonTitle: String = "활동 완료",
        deleteButtonTitle: String = "활동 삭제하기"
    ) {
        self.title = title
        self.daysUntilLabel = daysUntilLabel
        self.startDate = startDate
        self.endDate = endDate
        self.activityPointLabel = activityPointLabel
        self.activityPoints = activityPoints
        self.completionMessage = completionMessage
        self.editButtonTitle = editButtonTitle
        self.completeButtonTitle = completeButtonTitle
        self.deleteButtonTitle = deleteButtonTitle
    }

    /// Event(활동일정)로부터 ViewModel 생성. category가 growth/rest일 때 해당 라벨 + activityPoint 사용
    static func from(event: Event, daysUntil: Int?) -> ActivityEventSummaryViewModel {
        let label: String? = daysUntil != nil ? (daysUntil == 0 ? "D-day" : "D-\(daysUntil!)") : nil
        let activityLabel: String? = switch event.category {
        case .growth: "성장"
        case .rest: "휴식"
        case .none: nil
        }
        return ActivityEventSummaryViewModel(
            title: event.title,
            daysUntilLabel: label,
            startDate: event.startDate,
            endDate: event.endDate,
            activityPointLabel: activityLabel,
            activityPoints: event.activityPoint
        )
    }
}
