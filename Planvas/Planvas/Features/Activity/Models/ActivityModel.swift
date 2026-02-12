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
    let activityId: Int
    let imageURL: String?
    let badgeText: String   // 카드 우측 상단에 작성되는 배지 텍스트
    let badgeColor: Color   // 배지 배경 색상
    let growth: Int
    let dday: Int
    let title: String
    
    let tip: ActivityTip?
}

struct ActivityTip: Hashable {
    let label: String      // "Tip" 또는 "주의"
    let tag: String        // "[카페 알바]" 같은 태그
    let message: String    // "일정이 있어요! ..."
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
    
    
    /// 포인트 뱃지 문자열
    var pointBadge: String {
        category == .growth ? "성장 +\(point)" : "휴식 +\(point)"
    }
    
    /// 활동치 라벨 (성장 / 휴식)
    var growthLabel: String {
        category == .growth ? "성장" : "휴식"
    }
}

extension ActivityDetailSuccess {
    func toDomain() -> ActivityDetail {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return ActivityDetail(
            activityId: activityId,
            title: title,
            category: category,
            point: point,
            description: description,
            thumbnailUrl: thumbnailUrl ?? "",
            dDay: dDay,
            date: "\(startDate) ~ \(endDate)",
            startDate: formatter.date(from: startDate),
            endDate: formatter.date(from: endDate),
            minPoint: minPoint,
            maxPoint: maxPoint,
            defaultPoint: defaultPoint,
            externalUrl: externalUrl ?? ""
        )
    }
}
