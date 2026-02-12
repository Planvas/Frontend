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
    
    let tip: ActivityTip?
}

struct ActivityTip: Hashable {
    let label: String      // "Tip" 또는 "주의"
    let tag: String        // "[카페 알바]" 같은 태그
    let message: String    // "일정이 있어요! ..."
    let labelColor: Color  // Tip/주의 색
}

// MARK: - 활동 디테일 모델
struct ActivityDetail {
    let title: String
    let dDay: Int
    let date: String
    let category: TodoCategory
    let point: Int
    let description: String
    let thumbnailUrl: String
}
