//
//  OnboardingFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var router = NavigationRouter<OnboardingRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            OnboardingView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    OnboardingFlowView()
}
