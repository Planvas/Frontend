//
//  MyPageFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct MyPageFlowView: View {
    @State private var router = NavigationRouter<MyPageRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            MyPageView()
                .navigationDestination(for: MyPageRoute.self) { route in
                    switch route {
                    case .mypage:
                        MyPageView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    MyPageFlowView()
}
