//
//  PlanvasApp.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI
import GoogleSignIn

@main
struct PlanvasApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                LoginView()
            } else {
                InitOnboardingView()
            }
        }
    }
}
