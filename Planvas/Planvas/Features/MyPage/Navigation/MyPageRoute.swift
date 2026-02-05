import Foundation

enum MyPageRoute: Hashable {
    case mypage
    case mainPage
    case reportPage(goalId: Int)
    case pastReportPage
    case calenderPage
    case alarmPage
}
