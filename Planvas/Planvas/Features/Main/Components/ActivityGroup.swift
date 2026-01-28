//
//  ActivityGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 바디 / 활동 그룹
struct ActivityGroup: View {
    @State private var recommended: Bool = false
    @ObservedObject var viewModel: MainViewModel
    @State private var currentIndex: Int? = 0 
    
    var body: some View {
        VStack(alignment: .leading){
            Text("오늘의 인기 성장 활동")
                .textStyle(.semibold25)
                .foregroundStyle(.black1)
            
            HStack{
                Spacer()
                Toggle(isOn: $recommended) {
                    Text("나에게 맞는 추천만 보기")
                        .textStyle(.medium14)
                        .foregroundStyle(.primary1)
                }
                .toggleStyle(SwitchToggleStyle(tint: .primary1))
                .frame(width: 210)
                .padding(.trailing, 4)
            }
            
            // 스크롤 위치에 따른 페이지 계산
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.items.indices, id: \.self) { index in
                            MainActivityItem(
                                item: viewModel.items[index],
                                index: index + 1
                            )
                            .id(index)
                            .frame(height: 340)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 16)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $currentIndex)

                PageIndicatorView(
                    count: viewModel.items.count,
                    currentIndex: currentIndex ?? 0
                )
            }
        }
        .padding()
    }
}

// MARK: - 활동 아이템 페이지
struct PageIndicatorView: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? .gray888 : .gray88850)
                    .frame(
                        width: index == currentIndex ? 14 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
    }
}
