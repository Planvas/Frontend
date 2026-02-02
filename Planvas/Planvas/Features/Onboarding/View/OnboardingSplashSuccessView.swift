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

            Image("BackgroundGradientShape")
            .renderingMode(.original)
            .resizable()
            .scaledToFill()
            .offset(y: 60) 
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
            print("다음 화면으로 이동")
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
