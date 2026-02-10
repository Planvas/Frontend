//
//  NotificationView.swift
//  Planvas
//
//  Created by 정서영 on 2/1/26.
//

// MARK: - 알림 세팅 페이지
import SwiftUI

struct NotificationView: View {
    @Environment(NavigationRouter<MyPageRoute>.self) var router
    @State private var viewModel = NotificationViewModel()
    
    var body: some View {
        VStack{
            HeaderGroup
            SettingGroup
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
    
    // 헤더
    private var HeaderGroup: some View {
        ZStack{
            HStack{
                Button(action:{
                    router.pop()
                }){
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
    
    // 알림 세팅 토글
    private var SettingGroup: some View {
        VStack(spacing: 10){
            reminderToggleRow(
                title: "D-day 및 리마인더 알림 받기",
                description: "종료일과 일주일 전에 \n리마인드 알림을 발송해요",
                isOn: $viewModel.reminder
            )
            reminderToggleRow(
                title: "활동 완료 알림 받기",
                description: "종료일과 종료일 이후에 알림을 발송하여\n활동 완료 등록을 도와드려요",
                isOn: $viewModel.complete
            )

        }
        .padding()
    }
}

// 알림 세팅 토글 아이템
@ViewBuilder
private func reminderToggleRow(
    title: String,
    description: String,
    isOn: Binding<Bool>
) -> some View {
    HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .textStyle(.semibold18)
                .foregroundStyle(.black1)

            Text(description)
                .textStyle(.medium14)
                .foregroundStyle(.gray888)
        }

        Spacer()

        Toggle("", isOn: isOn)
            .toggleStyle(SwitchToggleStyle(tint: .primary1))
            .frame(width: 52)
    }
    .padding(20)
    .padding(.trailing, 5)
    .background(
        RoundedRectangle(cornerRadius: 15)
            .stroke(.ccc, lineWidth: 1)
    )
}

#Preview {
    NotificationView()
        .environment(NavigationRouter<MyPageRoute>())
}
