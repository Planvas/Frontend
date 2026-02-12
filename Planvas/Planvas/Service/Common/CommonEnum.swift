//
//  CommonEnum.swift
//  Planvas
//
//  Created by 정서영 on 2/6/26.
//

// 성장/휴식 카테고리

import SwiftUI

enum TodoCategory: String, Codable {
    case growth = "GROWTH"
    case rest = "REST"
    case manual = "MANUAL"
}

// 활동 일정 가능 여부
enum ScheduleAvailable: String, Codable {
    case available = "AVAILABLE" // 일정 가능
    case caution = "CAUTION"     // 일정 주의
    case unavailable = "UNAVAILABLE"   // 일정 마감

    // 텍스트 매핑
    var badgeText: String {
        switch self {
        case .available: return "일정 가능"
        case .caution: return "일정 주의"
        case .unavailable: return "일정 마감"
        }
    }

    // 컬러 매핑
    var badgeColor: Color {
        switch self {
        case .available: return .blue1
        case .caution: return .yellow1
        case .unavailable: return .red1
        }
    }
}

