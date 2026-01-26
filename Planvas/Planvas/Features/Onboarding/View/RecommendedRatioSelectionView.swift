//
//  RecommendedRatioSelectionView.swift
//  Planvas
//
//  Created by 황민지 on 1/27/26.
//

import SwiftUI

struct RecommendedRatioSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 현재 어떤 유형이 선택되었는지 저장 (없으면 nil)
    @State private var selectedType: String? = nil
    
    // 토글 로직: 이미 눌린 거면 해제(nil), 아니면 새로 선택
    private func toggleSelection(_ title: String) {
        if selectedType == title {
            selectedType = nil
        } else {
            selectedType = title
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("내가 바라는 모습대로")
                .textStyle(.medium20)
                .foregroundStyle(.black1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Text("유형별 추천 비율 ")
                    .foregroundStyle(.primary1)
                
                Text("선택하기")
                    .foregroundStyle(.black1)
            }
            .textStyle(.semibold30)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer().frame(height: 40)
            
            // 유형별 추천 컴포넌트 스크롤
            // TODO: API 연동
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    RecommendedRatioComponent(
                        title: "파워 갓생러🔥",
                        ratioText: "성장 90% | 휴식 10%",
                        description: "잠은 죽어서 잔다!\n이번 시즌, 후회 없이 모든 걸 쏟아붓습니다\n\n지금 편안하게 쉬는 것보다,\n미래의 압도적인 성취를 위해",
                        shortDesc: "성장에 올인(All-in)하는 유형",
                        targetText: "학점 관리와 대외활동을 병행하는\n프로 N잡러",
                        isSelected: selectedType == "파워 갓생러🔥",
                        action: {
                            toggleSelection("파워 갓생러🔥")
                        }
                    )
                    
                    RecommendedRatioComponent(
                        title: "갭이어 탐험가 ✈️",
                        ratioText: "성장 10% | 휴식 90%",
                        description: "이번 시즌의 목표는 경험!\n마음껏 놀고, 보고, 느끼는 게 나의 스펙\n\n단순한 휴식이 아니라\n여행이나 새로운 경험을 통한",
                        shortDesc: "'적극적인 휴식'으로 청춘을 즐기려는 유형",
                        targetText: "장배낭 여행, 워킹 홀리데이, 휴학 후\n자아를 찾는 여행자",
                        isSelected: selectedType == "갭이어 탐험가 ✈️",
                        action: {
                            toggleSelection("갭이어 탐험가 ✈️")
                        }
                    )
                    
                    Spacer().frame(width: 20)
                }
            }
            
            .scrollClipDisabled()
            
            Spacer()
            
            // 다음 버튼
            PrimaryButton(title: "이전으로") {
                print("이전으로 버튼 클릭")
                
                // TODO: 선택한 비율 저장 로직 구현
                
                // 이전으로 화면 이동 로직
                dismiss()
            }
            .padding(.bottom, 89)
            .zIndex(1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 134)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea()
    }
}

#Preview {
    RecommendedRatioSelectionView()
}
