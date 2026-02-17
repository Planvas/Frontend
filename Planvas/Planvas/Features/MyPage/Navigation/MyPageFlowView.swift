import SwiftUI
import Moya

struct MyPageFlowView: View {
    @State private var router = NavigationRouter<MyPageRoute>()
    @State private var calendarViewModel = CalendarViewModel()
    @State private var goalViewModel = GoalSetupViewModel()
    @State private var myPageViewModel = MyPageViewModel()
    @State private var onboardingViewModel: OnboardingViewModel
    @State private var loginViewModel = LoginViewModel()
    
    init() {
        let provider = APIManager.shared.createProvider(for: OnboardingAPI.self)
        _onboardingViewModel = State(wrappedValue: OnboardingViewModel(provider: provider))
    }
    
    // MARK: - 네비게이션 추가
    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .currentGoalPage:
                        GoalEditView()
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
                    case .goalInfoSetup:
                        GoalInfoSetupView()
                    case .goalRatioInfo:
                        GoalRatioSetupView()
                    }
                }
        }
        .environment(router)
        .environment(calendarViewModel)
        .environment(goalViewModel)
        .environment(myPageViewModel)
        .environment(onboardingViewModel)
        .environment(loginViewModel)
        .environment(\.flowContext, .myPage)
    }
}

#Preview {
    MyPageFlowView()
}
