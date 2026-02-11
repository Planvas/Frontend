import SwiftUI

struct MyPageFlowView: View {
    @State private var router = NavigationRouter<MyPageRoute>()
    @State private var calendarViewModel = CalendarViewModel()
    let goalId: Int = 12
    
    // MARK: - 네비게이션 추가
    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .currentGoalPage:
                        MainView()
                    case .reportPage(let goalId):
                        ReportView(goalId: goalId)
                    case .pastReportPage:
                        PastReportView()
                    case .calenderPage:
                        CalendarView()
                    case .alarmPage:
                        NotificationView()
                    case .loginPage:
                        LoginView()
                    }
                }
        }
        .environment(router)
        .environment(calendarViewModel)
    }
}

#Preview {
    MyPageFlowView()
}
