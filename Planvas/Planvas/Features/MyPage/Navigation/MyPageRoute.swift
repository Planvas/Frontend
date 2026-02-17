import Foundation

enum MyPageRoute: Hashable {
    case currentGoalPage
    case reportPage(goalId: Int)
    case pastReportPage
    case calenderPage
    case alarmPage
    case loginPage
    case activityPage
    case goalInfoSetup // 목표 이름 & 기간 설정
    case goalRatioInfo // 목표 비율 설정
}
