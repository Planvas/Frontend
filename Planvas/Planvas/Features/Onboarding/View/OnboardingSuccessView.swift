//
//  OnboardingSuccessView.swift
//  Planvas
//
//  Created by 황민지 on 2/4/26.
//

import SwiftUI

struct OnboardingSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            Text("모든 준비가 끝났어요!")
                .textStyle(.semibold25)
                .foregroundStyle(.black1)
            
            HStack (spacing: 0) {
                Text("이제 ")
                    .foregroundStyle(.black1)
                
                Text("시작")
                    .foregroundStyle(.primary1)
                
                Text("해볼까요?")
                    .foregroundStyle(.black1)
            }
            .textStyle(.semibold25)
            .padding(.bottom, 30)
            
            Text("설정한 비율에 맞춰")
                .textStyle(.medium18)
                .foregroundStyle(.primary1)
            
            Text("딱 맞는 활동들을 찾아왔어요")
                .textStyle(.medium18)
                .foregroundStyle(.primary1)
                .padding(.bottom, 18)
            
            PrimaryButton(title: "추천 활동으로 채우기") {
                print("추천 활동으로 채우기")
                
                // TODO: 추천 활동 뷰로 이동
            }
            .padding(.bottom, 38)
            
            Button(action: {
                print("홈으로 가기")
                dismiss()
            }) {
                Text("홈으로 가기")
                    .textStyle(.semibold18)
                    .foregroundStyle(.black1)
                    .padding(.bottom, 0.05)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1.8)
                            .foregroundStyle(.black1)
                    }
            }
            
        }
        .padding(.horizontal, 24)
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingSuccessView()
}
