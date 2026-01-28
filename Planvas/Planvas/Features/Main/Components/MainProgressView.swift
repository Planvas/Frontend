//
//  MainProgressView.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 메인에서 사용되는 프로그레스바 컴포넌트
struct MainProgressView: View {
    //사용자가 설정한 목표 퍼센트
    let goal: Int
    //사용자가 수행한 퍼센트
    let progress: Int
    
    //프로그레스바에 나타나는 색상
    let startColor: Color
    let endColor: Color

    //진행된 퍼센트 계산 함수
    private var ratio: CGFloat {
        guard goal > 0 else { return 0 }
        return min(CGFloat(progress) / CGFloat(goal), 1)
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .leading) {
                ZStack(alignment: .trailing){
                    Capsule()
                        .foregroundStyle(.fff)
                    Text("\(goal)%")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray888)
                        .padding(.trailing)
                }
                
                ZStack(alignment: .trailing){
                    Capsule()
                        .frame(width: max(geometry.size.width * ratio, 60))
                        .modifier(GradientModifier(startColor: startColor, endColor: endColor))
                    Text("\(progress)%")
                        .textStyle(.medium20)
                        .foregroundStyle(.fff50)
                        .padding(.trailing)
                }
            }
            .frame(height: 30)
        }
    }
}

#Preview {
    MainProgressView(
        goal: 60,
        progress: 40,
        startColor: .primary1,
        endColor: .primary2
    )
}
