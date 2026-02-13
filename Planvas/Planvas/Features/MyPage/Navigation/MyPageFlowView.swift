import SwiftUI

struct MyPageFlowView: View {
    @State private var router = NavigationRouter<MyPageRoute>()
    @State private var calendarViewModel = CalendarViewModel()
    
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
                    case .activityPage:
                        ActivityView()
                    case .goalPage:
                        OnboardingFlowView() // TODO: -  네비게이션 수정
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
