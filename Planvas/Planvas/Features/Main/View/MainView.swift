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
                stateTitle: viewModel.StateTitle
            )
            
            MainBodyView(viewModel: viewModel)
                .background(
                    RoundedTopRectangle(radius: 25)
                        .fill(Color.white)
                )
                .offset(y: -220)
        }
        .ignoresSafeArea()
    }
}  

#Preview {
    MainView()
}
