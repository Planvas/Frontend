import SwiftUI
import Combine

struct MyPageView: View {
    @State private var viewModel = MyPageViewModel()
    @State private var showCalendarAlert = false
    
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    
    var body: some View {
        ZStack {
            backgroundCircle
            
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(Color.red)
                } else if viewModel.goalData != nil {
                    ScrollView {
                        VStack(spacing: 40) {
                            ProfileView(viewModel: viewModel)
                            goalCardView(viewModel: viewModel)
                            DetailPageView(showCalendarAlert: $showCalendarAlert)
                                .environment(router)
                        }
                    }
                    .scrollIndicators(.hidden)
                } else if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
        }
        .overlay {
            if showCalendarAlert {
                if viewModel.isCalendarConnected {
                    CustomAlertView(
                        title: "캘린더를 동기화하고\n새 일정을 불러올까요?",
                        message: "현재 캘린더가 연동되어 있어요",
                        primaryButtonTitle: "Google 캘린더 동기화",
                        secondaryButtonTitle: "취소",
                        primaryButtonAction: { showCalendarAlert = false },
                        secondaryButtonAction: { showCalendarAlert = false }
                    )
                } else {
                    CustomAlertView(
                        title: "캘린더를 연동할까요?",
                        message: "현재 캘린더가 연동되어 있지 않아요",
                        messageColor: .primary1,
                        primaryButtonTitle: "Google 캘린더 연동",
                        secondaryButtonTitle: "취소",
                        primaryButtonAction: { /* 연동 API 호출 */ showCalendarAlert = false },
                        secondaryButtonAction: { showCalendarAlert = false }
                    )
                }
            }
        }
        .task {
            await viewModel.fetchMyPageData()
        }
    }
}

// MARK: - Sub Views
extension MyPageView {
    private var backgroundCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primary1,
                        Color.primary1.opacity(0.9),
                        Color.gradprimary2]),
                    startPoint: .bottomTrailing,
                    endPoint: .leading)
            )
            .frame(width: 750, height: 750)
            .offset(y: -500)
    }
}
#Preview {
    return MyPageFlowView()
}
