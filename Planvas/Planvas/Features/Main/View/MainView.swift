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
            VStack {
                MainHeaderView(
                    goalSetting: viewModel.goalSetting,
                    stateTitle: viewModel.StateTitle,
                    stateDescription: viewModel.StateDescription
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainView()
}
