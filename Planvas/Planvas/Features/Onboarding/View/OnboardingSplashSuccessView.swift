//
//  OnboardingSplashSuccessView.swift
//  Planvas
//
//  Created by 황민지 on 1/30/26.
//

import SwiftUI

struct OnboardingSplashSuccessView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    
    var body: some View {
        ZStack {
            Color.fff.ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .goal178CC9.opacity(0.85), location: 0.00),
                    .init(color: .primary1.opacity(0.63), location: 0.35),
                    .init(color: .goal883AE1.opacity(0.52), location: 0.5),
                    
                    .init(color: .fff.opacity(0.0), location: 1.00)
                ]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 750
            )
            .ignoresSafeArea()

            
            VStack(spacing: 0) {
                Text("목표기간을")
                
                Text("설정해주세요")
            }
            .textStyle(.bold35)
            .foregroundStyle(.black1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            router.push(.info)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    OnboardingSplashSuccessView()
        .environment(NavigationRouter<OnboardingRoute>())
}
