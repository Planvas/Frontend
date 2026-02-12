//
//  ActivityModel.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI

// MARK: - 성장/휴식 활동 카드에 사용될 모델
struct ActivityCard: Identifiable {
    let id = UUID()
    let imageURL: String?
    let badgeText: String   // 카드 우측 상단에 작성되는 배지 텍스트
    let badgeColor: Color   // 배지 배경 색상
    let growth: Int
    let dday: Int
    let title: String
}
