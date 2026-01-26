//
//  MainView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    // 헤더 그룹 높이
    @State private var headerHeight: CGFloat = 0
    
    var body: some View {
        ScrollView {
                MainHeaderView(
                    goalSetting: viewModel.goalSetting,
                    stateTitle: viewModel.StateTitle,
                    stateDescription: viewModel.StateDescription
                )
                //헤더 그룹 높이 측정
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: HeaderHeightKey.self, value: geo.size.height)
                    }
                )
            
                VStack {
                    Text("이번 주")
                    Rectangle()
                    Rectangle()
                }
                .padding(.top, 20)
                //헤더 그룹 높이에 따른 shape 높이 조정
                .background(
                    RoundedTopRectangle(radius: 25)
                        .fill(Color.white)
                )
                .offset(y: headerHeight - 35)

        }
        .ignoresSafeArea()
    }
}

// MARK: - 헤더 그룹 높이 전달
struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    MainView()
}
