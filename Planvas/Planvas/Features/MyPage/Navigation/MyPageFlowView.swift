import SwiftUI

struct MyPageFlowView: View {
    @State private var router = NavigationRouter<MyPageRoute>()
    let goalId: Int = 12
    
    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .mypage:
                        MyPageView()
                    case .mainPage:
                        MainView()
                    case .reportPage:
                        ReportView(goalId: goalId)
                    case .pastReportPage:
                        PastReportView()
                    case .calenderPage:
                        CalendarView()
                    case .alarmPage:
                        EmptyView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    MyPageFlowView()
}
