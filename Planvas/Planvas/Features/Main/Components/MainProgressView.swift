//
//  MainProgressView.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 메인에서 사용되는 프로그레스바 컴포넌트
struct MainProgressView: View {
    
    //프로그레스 타입
    let type: String

    //사용자가 설정한 목표 퍼센트
    let goal: Int
    
    //사용자가 수행한 퍼센트
    let progress: Int

    //진행된 퍼센트 계산 함수
    private var ratio: CGFloat {
        guard goal > 0 else { return 0 }
        return min(CGFloat(progress) / CGFloat(goal), 1)
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Image(type == "성장" ? .plant : .moon)
                HStack(spacing: 4) {
                    Text("\(progress)%")
                        .textStyle(.bold25)
                        .foregroundStyle(.black1)
                    Text("/ \(goal)%")
                        .textStyle(.medium18)
                        .foregroundStyle(.gray888)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.subPurple)
                        Capsule()
                            .fill(.gray444)
                            .frame(width: max(geometry.size.width * ratio, 5))
                    }
                }
                .frame(width: 123, height: 9)
                
                Text(type)
                    .textStyle(.bold20)
                    .padding(.top, 5)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 11)
                    .fill(.fff)
            )
        }
    }

#Preview {
    MainProgressView(
        type: "휴식",
        goal: 60,
        progress: 40
    )
}
