//
//  Activity.swift
//  Planvas
//
//  Created by 최우진 on 1/28/26.
//

import Foundation
import SwiftUI

struct Activity: Identifiable, Hashable {
    let id: UUID
    let title: String
    let title2: String
    let growth: Int
    let dday: String

    let badgeText: String
    let badgeType: BadgeType

    let tipTag: String?
    let tipT: String?
    let tipText: String?
    
    let imageName: String?

    enum BadgeType: Hashable {
        case available
        case caution
        case conflict

        var color: Color {
            switch self {
            case .available: return .blue1
            case .caution: return .yellow1
            case .conflict: return .red1
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        title2: String,
        growth: Int,
        dday: String,
        badgeText: String,
        badgeType: BadgeType,
        tipTag: String? = nil,
        tipT: String? = nil,
        tipText: String? = nil,
        imageName: String? = nil
        
    ) {
        self.id = id
        self.title = title
        self.title2 = title2
        self.growth = growth
        self.dday = dday
        self.badgeText = badgeText
        self.badgeType = badgeType
        self.tipTag = tipTag
        self.tipT = tipT
        self.tipText = tipText
        self.imageName = imageName
    }
}
// SwiftUI 미리보기 화면 정의
#Preview {
    // ActivityView를 프리뷰로 표시
    ActivityView()
}
