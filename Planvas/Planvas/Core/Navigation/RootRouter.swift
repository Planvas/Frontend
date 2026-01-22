//
//  RootRouter.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI
import Combine

// MARK: - 최상위 라우터
final class RootRouter: ObservableObject {
    @Published var root: RootRoute = .splash

    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
        // 로그인 상태 확인
        appState.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                self?.root = isLoggedIn ? .main : .login
            }
            .store(in: &cancellables)
    }
}
