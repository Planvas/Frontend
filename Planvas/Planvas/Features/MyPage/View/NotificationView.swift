//
//  NotificationView.swift
//  Planvas
//
//  Created by 정서영 on 2/1/26.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        HeaderGroup
    }
    
    private var HeaderGroup: some View {
        ZStack{
            HStack{
                Button(action:{print("뒤로가기")}){
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 11, height: 18)
                        .foregroundStyle(.black1)
                }
                Spacer()
            }
            Text("알림 및 리마인더")
                .textStyle(.bold20)
                .foregroundStyle(.black1)
        }
        .padding()
    }
}

#Preview {
    NotificationView()
}
