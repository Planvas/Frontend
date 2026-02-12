import SwiftUI

enum ScheduleStatus {
    case available, warning, conflict
    
    var status: String {
        switch self {
        case .available: return "일정 가능"
        case .warning: return "일정 주의"
        case .conflict: return "일정 겹침"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .available: return .blue1
        case .warning: return .yellow1
        case .conflict: return .red1
        }
    }
}
