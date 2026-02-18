//
//  MainView.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel = MainViewModel()
    @Environment(NavigationRouter<MainRoute>.self) var router
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        ScrollView {
            MainHeaderView(viewModel: viewModel)
            
            MainBodyView(viewModel: viewModel)
                .background(
                    RoundedTopRectangle(radius: 25)
                        .fill(Color.white)
                )
                .padding(.top, -220)
                .padding(.bottom, 75)
            
            DisableScrollBounce() 
        }
        .ignoresSafeArea()
        .task{viewModel.fetchMainData()}
        .overlay {
            if viewModel.showCompleteAlert,
               let alertVM = viewModel.completeAlertViewModel {
                
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { viewModel.showCompleteAlert = false }
                    
                    ActivityCompleteAlertView(
                        viewModel: alertVM,
                        onConfirm: {
                            viewModel.showCompleteAlert = false
                        },
                        onDismiss: {
                            viewModel.showCompleteAlert = false
                        }
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}  

#Preview {
    TabBar()
}
