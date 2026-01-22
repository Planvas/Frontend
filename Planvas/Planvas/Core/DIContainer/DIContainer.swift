//
//  DIContainer.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import Foundation

final class DIContainer {

    // MARK: - Global States
    let appState: AppState

    // MARK: - Router
    let rootRouter: RootRouter

    init() {
        self.appState = AppState()
        self.rootRouter = RootRouter(appState: appState)
    }
}
