import SwiftUI
import Combine
import GoogleSignIn

struct MyPageView: View {
    @Environment(MyPageViewModel.self) private var viewModel
    @State private var showCalendarAlert = false
    @State private var syncViewModel = CalendarSyncViewModel() // 구글 캘린더 연동
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
                // 현재 연동 상태
                let isConnected = viewModel.isCalendarConnected
                
                CustomAlertView(
                    title: isConnected ? "캘린더를 동기화하고\n새 일정을 불러올까요?" : "캘린더를 연동할까요?",
                    message: isConnected ? "현재 캘린더가 연동되어 있어요" : "현재 캘린더가 연동되어 있지 않아요",
                    messageColor: isConnected ? .primary : .primary1,
                    primaryButtonTitle: isConnected ? "Google 캘린더 동기화" : "Google 캘린더 연동",
                    secondaryButtonTitle: "취소",
                    primaryButtonAction: {
                        Task {
                            if isConnected {
                                // 1. 이미 연동된 경우: 로그인 창 없이 서버 동기화만
                                await syncViewModel.syncGoogleCalendar() // (extension 함수 호출)
                            } else {
                                // 2. 연동 안 된 경우: 연동 프로세스 진행
                                syncViewModel.performGoogleCalendarConnect()
                            }
                            await viewModel.fetchMyPageData()
                            showCalendarAlert = false
                        }
                    },
                    secondaryButtonAction: { showCalendarAlert = false }
                )
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
