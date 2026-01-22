//
//  NavigationRouter.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI
import Observation

// MARK: - 네비게이션 라우터 기본 세팅
@Observable
final class NavigationRouter<Route: Hashable> {
    var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func reset() {
        path = NavigationPath()
    }
}
