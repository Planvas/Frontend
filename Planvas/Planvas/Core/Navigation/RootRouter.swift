//
//  RootRouter.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI
import Combine
import Observation

// MARK: - 최상위 라우터
@Observable
final class RootRouter {
    var root: RootRoute = .splash

    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState

        let hasSeenOnboarding =
            UserDefaults.standard.bool(forKey: OnboardingKeys.hasSeenOnboarding)
        let hasCompletedOnboarding =
            UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
        let hasActiveGoal =
            UserDefaults.standard.bool(forKey: OnboardingKeys.hasActiveGoal)

        if !hasSeenOnboarding {
            root = .splash
        } else if !appState.isLoggedIn {
            root = .login
        } else if hasCompletedOnboarding && hasActiveGoal {
            // 로그인 + 목표 설정 완료 → 메인
            root = .main
        } else {
            // 로그인은 했지만 목표 설정 안 함
            root = .onboarding
        }

        appState.$isLoggedIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }

                if !isLoggedIn {
                    self.root = .login
                }
            }
            .store(in: &cancellables)
    }
}
