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
    private let onboardingVM: OnboardingViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState, onboardingVM: OnboardingViewModel) {
        self.appState = appState
        self.onboardingVM = onboardingVM

        let hasSeenOnboarding =
            UserDefaults.standard.bool(forKey: OnboardingKeys.hasSeenOnboarding)

        if !hasSeenOnboarding {
            root = .splash
        } else if !appState.isLoggedIn {
            root = .login
        } else {
            routeByServer()
        }

        appState.$isLoggedIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                guard let self else { return }
                if !isLoggedIn {
                    self.root = .login
                } else {
                    self.routeByServer()
                }
            }
            .store(in: &cancellables)
    }

    private func routeByServer() {
        root = .loading // RootRoute에 loading 추가 추천

        onboardingVM.checkHasCurrentGoal { [weak self] hasGoal in
            guard let self else { return }
            self.root = hasGoal ? .main : .onboarding
        }
    }
}
