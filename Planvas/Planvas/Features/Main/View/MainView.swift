//
//  MainView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        ScrollView {
            MainHeaderView(
                goalSetting: viewModel.goalSetting,
                stateTitle: viewModel.stateTitle
            )
            
            MainBodyView(viewModel: viewModel)
                .background(
                    RoundedTopRectangle(radius: 25)
                        .fill(Color.white)
                )
                .padding(.top, -220)
                .padding(.bottom, 75)
        }
        .ignoresSafeArea()
    }
}  

#Preview {
    TabBar()
}
