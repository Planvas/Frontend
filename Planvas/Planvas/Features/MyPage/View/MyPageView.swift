import SwiftUI
import Combine

struct MyPageView: View {
    @Environment(MyPageViewModel.self) private var viewModel
    @State private var showCalendarAlert = false
    
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    
    var body: some View {
        ZStack {
            backgroundCircle
            VStack {
                if !viewModel.goalIsLoading && !viewModel.userIsLoading {
                    ScrollView {
                        VStack(spacing: 40) {
                            ProfileView()
                            goalCardView()
                            DetailPageView(showCalendarAlert: $showCalendarAlert)
                                .environment(router)
                        }
                    }
                    .scrollIndicators(.hidden)
                } else {
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
        .alert("오류", isPresented: Binding(
            get: { viewModel.alertErrorMessage != nil },
            set: { if !$0 { viewModel.alertErrorMessage = nil } }
        )) {
            Button("확인") { viewModel.alertErrorMessage = nil }
        } message: {
            Text(viewModel.alertErrorMessage ?? "")
        }
    }
}

// MARK: - 배경 보라색 원
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
