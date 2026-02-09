//
//  RootView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        switch container.rootRouter.root {
        case .splash:
            SplashView()
        case .login:
            LoginView()
        case .main:
            TabBar()
        }
    }
}
