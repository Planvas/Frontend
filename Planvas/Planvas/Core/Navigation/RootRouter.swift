import SwiftUI
import Combine
import Observation

// MARK: - 최상위 라우터
@Observable
final class RootRouter {
    var root: RootRoute = .splash

    private let appState: AppState
    private let onboardingVM: OnboardingViewModel
    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState, onboardingVM: OnboardingViewModel) {
        self.appState = appState
        self.onboardingVM = onboardingVM

        // 자동 로그인 상태를 AppState에 반영
        // (토큰/세션 있으면 true)
        appState.isLoggedIn = AuthManager.shared.checkAutoLoginStatus()

        // 최초 진입 라우팅
        updateRootRoute()

        // 로그인 상태가 바뀌면 다시 라우팅 계산
        appState.$isLoggedIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateRootRoute()
            }
            .store(in: &cancellables)
    }

    // MARK: - 로그인 성공 트리거
    func triggerLoginSuccess() {
        appState.isLoggedIn = true
        updateRootRoute()
    }

    // MARK: - 화면 전환 로직
    private func updateRootRoute() {
        let hasSeenOnboarding =
            UserDefaults.standard.bool(forKey: OnboardingKeys.hasSeenOnboarding)

        if !hasSeenOnboarding {
            root = .splash
            return
        }

        if !appState.isLoggedIn {
            root = .login
            return
        }

        // 로그인 되어있으면 서버로 현재 목표 존재 여부 확인
        routeByServer()
    }

    private func routeByServer() {
        root = .loading

        onboardingVM.checkHasCurrentGoal { [weak self] hasGoal in
            guard let self else { return }

            // 기존 목표가 있는 사용자는 바로 메인
            if hasGoal {
                // 혹시 남아있는 성공 시트 플래그가 있으면 꺼버려서 깜빡임 방지
                UserDefaults.standard.set(false, forKey: "shouldShowOnboardingSuccessSheet")
                self.root = .main
            } else {
                self.root = .onboarding
            }
        }
    }
    
    func refresh() {
        // 외부에서 한 번 강제로 라우팅 재계산이 필요할 때만 호출
        updateRootRoute()
    }
}
