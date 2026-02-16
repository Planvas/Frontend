import SwiftUI

// 성장/휴식 카테고리

import SwiftUI

enum TodoCategory: String, Codable {
    case growth = "GROWTH"
    case rest = "REST"
    case manual = "MANUAL"
}

// 타입 카테고리
enum TypeCategory: String, Codable {
    case normal = "NORMAL"
    case contest = "CONTEST"
}

enum ScheduleStatusCategory: String, Codable {
    case available = "AVAILABLE"
    case unavailable = "UNAVAILABLE"
    case caution = "CAUTION"
    
    // 화면에 보여줄 한글 텍스트
    var statusTitle: String {
        switch self {
        case .available: return "일정 가능"
        case .unavailable: return "일정 겹침"
        case .caution: return "일정 주의"
        }
    }
    
    // 상태별 테마 색상
    var themeColor: Color {
        switch self {
        case .available: return .blue1
        case .unavailable: return .red1
        case .caution: return .yellow1
        }
    }
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
