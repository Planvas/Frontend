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
    @StateObject private var container = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
        }
    }
    
    init() {
        let config = GIDConfiguration(clientID: Config.ClientId)
        GIDSignIn.sharedInstance.configuration = config
    }
}
