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
    case conflict = "CONFLICT"
    
    // 화면에 보여줄 한글 텍스트
    var statusTitle: String {
        switch self {
        case .available: return "일정 가능"
        case .unavailable: return "일정 마감"
        case .caution: return "일정 주의"
        case .conflict: return "일정 겹침"
        }
    }
    
    // 상태별 테마 색상
    var themeColor: Color {
        switch self {
        case .available: return .blue1
        case .unavailable: return .red1
        case .caution: return .yellow1
        case .conflict: return .red1  
        }
    }
}

