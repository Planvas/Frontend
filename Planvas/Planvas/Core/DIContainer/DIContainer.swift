//
//  DIContainer.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import Foundation
import Combine
import Moya

final class DIContainer: ObservableObject {
    // MARK: - Global States
    let appState: AppState

    // MARK: - Router
    let rootRouter: RootRouter

    // MARK: - Network
    let apiManager: APIManager
    let calendarProvider: MoyaProvider<CalendarAPI>
    
    init() {
        self.appState = AppState()
        self.rootRouter = RootRouter(appState: appState)
        
        self.apiManager = APIManager.shared
        self.calendarProvider = apiManager.createProvider(for: CalendarAPI.self)
    }
}
