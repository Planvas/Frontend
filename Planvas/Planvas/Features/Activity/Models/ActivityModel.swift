//
//  ActivityModel.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI

// MARK: - 성장/휴식 활동 카드에 사용될 모델
struct ActivityCard: Identifiable, Hashable {
    let id = UUID()
    let imageURL: String?
    let badgeText: String   // 카드 우측 상단에 작성되는 배지 텍스트
    let badgeColor: Color   // 배지 배경 색상
    let growth: Int
    let dday: Int
    let title: String
}

// MARK: - 활동 디테일 모델
struct ActivityDetail {
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let description: String
    let thumbnailUrl: String
    let dDay: Int
    let date: String
    let startDate: Date?
    let endDate: Date?
    let minPoint: Int
    let maxPoint: Int
    let defaultPoint: Int
    let externalUrl: String

    /// D-day 표시용 문자열
    var dDayLabel: String {
        dDay == 0 ? "D-day" : (dDay > 0 ? "D-\(dDay)" : "D+\(-dDay)")
    }

    /// 헤더 타이틀 (성장 활동 / 휴식 활동)
    var headerTitle: String {
        category == .growth ? "성장 활동" : "휴식 활동"
    }

    /// 포인트 뱃지 문자열
    var pointBadge: String {
        category == .growth ? "성장 +\(point)" : "휴식 +\(point)"
    }

    /// 활동치 라벨 (성장 / 휴식)
    var growthLabel: String {
        category == .growth ? "성장" : "휴식"
    }
}

extension ActivityDetail {
    /// DTO → 도메인 모델 매핑
    init(from dto: ActivityDetailSuccess) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        self.activityId = dto.activityId
        self.title = dto.title
        self.category = dto.category
        self.point = dto.point
        self.description = dto.description
        self.thumbnailUrl = dto.thumbnailUrl ?? ""
        self.dDay = dto.dDay ?? 0
        self.minPoint = dto.minPoint ?? 0
        self.maxPoint = dto.maxPoint ?? 100
        self.defaultPoint = dto.defaultPoint ?? 20
        self.externalUrl = dto.externalUrl ?? ""
        self.startDate = dto.startDate.flatMap { dateFormatter.date(from: $0) }
        self.endDate = dto.endDate.flatMap { dateFormatter.date(from: $0) }

        if let start = dto.startDate, let end = dto.endDate {
            self.date = "\(start) ~ \(end)"
        } else {
            self.date = ""
        }
    }
}
