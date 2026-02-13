import Foundation

enum MyPageRoute: Hashable {
    case currentGoalPage
    case reportPage(goalId: Int)
    case pastReportPage
    case calenderPage
    case alarmPage
    case loginPage
    case activityPage
    case goalPage
}
