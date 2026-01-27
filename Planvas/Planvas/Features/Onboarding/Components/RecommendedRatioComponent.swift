//
//  RecommendedRatioComponent.swift
//  Planvas
//
//  Created by 황민지 on 1/27/26.
//

import SwiftUI

struct RecommendedRatioComponent: View {
    let title: String
    let ratioText: String
    let description: String
    let shortDesc: String
    let targetText: String
    
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // 유형 이름
                Text(title)
                    .textStyle(.semibold25)
                    .foregroundStyle(.fff)
                    .padding(.top, 25)
                    .padding(.bottom, 1)
                    .padding(.leading, 25)
                
                // 유형 비율
                Text(ratioText)
                    .textStyle(.medium16)
                    .foregroundStyle(.fff50)
                    .padding(.bottom, 22)
                    .padding(.leading, 25)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.fff)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // 유형 세부 설명
                        Text(description)
                            .textStyle(.medium14)
                            .foregroundStyle(.black1)
                            .lineLimit(6)
                            .padding(.top, 38)
                        
                        // 유형 간단 설명
                        Text(shortDesc)
                            .textStyle(.bold14)
                            .foregroundStyle(.primary1)
                        
                        Spacer()
                        
                        Text("추천 대상")
                            .textStyle(.semibold14)
                            .foregroundStyle(.black1)
                            .padding(.bottom, 2)
                        
                        // 추천 대상
                        Text(targetText)
                            .textStyle(.semibold14)
                            .foregroundStyle(.black1)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .frame(width: 241, alignment: .center)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(.ccc20)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(.black1, lineWidth: 1)
                            )
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            }
            .frame(width: 282, height: 342)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    // TODO: 변경 사항 어케 되는지 디자인 고쳐야 함
                    .fill(.primary1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(.ccc, lineWidth: 0.6)
            )
            .shadow(color: .black20, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedType: String?
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    RecommendedRatioComponent(
                        title: "파워 갓생러🔥",
                        ratioText: "성장 90% | 휴식 10%",
                        description: "잠은 죽어서 잔다!\n이번 시즌, 후회 없이 모든 걸 쏟아붓습니다\n\n지금 편안하게 쉬는 것보다,\n미래의 압도적인 성취를 위해",
                        shortDesc: "성장에 올인(All-in)하는 유형",
                        targetText: "학점 관리와 대외활동을 병행하는\n프로 N잡러",
                        onSelect: { print("선택: 파워 갓생러🔥 (step 9)") }
                    )
                    
                    RecommendedRatioComponent(
                        title: "갭이어 탐험가 ✈️",
                        ratioText: "성장 10% | 휴식 90%",
                        description: "이번 시즌의 목표는 경험!\n마음껏 놀고, 보고, 느끼는 게 나의 스펙\n\n단순한 휴식이 아니라\n여행이나 새로운 경험을 통한",
                        shortDesc: "'적극적인 휴식'으로 청춘을 즐기려는 유형",
                        targetText: "장배낭 여행, 워킹 홀리데이, 휴학 후\n자아를 찾는 여행자",
                        onSelect: { print("선택: 갭이어 탐험가 ✈️ (step 1)") }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        
        private func toggleSelection(_ title: String) {
            if selectedType == title {
                selectedType = nil
            } else {
                selectedType = title
            }
        }
    }
    
    return PreviewWrapper()
}
