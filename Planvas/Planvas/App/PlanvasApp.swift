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
    @StateObject private var container = DIContainer()
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
              if hasSeenOnboarding {
                RootView()
              } else {
                SplashView()
              }
          }
          .environmentObject(container)
        }
    }
}
