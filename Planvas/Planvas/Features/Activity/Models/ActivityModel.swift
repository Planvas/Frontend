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
    let title: String
    let dDay: Int
    let date: String
    let category: TodoCategory
    let point: Int
    let description: String
    let thumbnailUrl: String
}
