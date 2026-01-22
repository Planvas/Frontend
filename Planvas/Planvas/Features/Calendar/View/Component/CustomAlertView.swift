//
//  CustomAlertView.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String?
    let messageColor: Color
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryButtonAction: () -> Void
    let secondaryButtonAction: (() -> Void)?
    
    init(
        title: String,
        message: String? = nil,
        messageColor: Color = .gray44450,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        primaryButtonAction: @escaping () -> Void,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.messageColor = messageColor
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
    }
    
    var body: some View {
        ZStack {
            // 배경 블러
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    secondaryButtonAction?()
                }
            
            // 팝업
            VStack(spacing: 10) {
                // 제목
                Text(title)
                    .textStyle(.bold25)
                    .foregroundColor(.black1)
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                
                // 안내 메시지
                if let message = message {
                    Text(message)
                        .textStyle(.semibold16)
                        .foregroundColor(messageColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }
                
                // 버튼들
                HStack(spacing: 12) {
                    // 주 버튼 (왼쪽)
                    Button {
                        primaryButtonAction()
                    } label: {
                        Text(primaryButtonTitle)
                            .textStyle(.medium14)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.primary1)
                            .cornerRadius(100)
                    }
                    
                    // 보조 버튼 (오른쪽, 옵션)
                    if let secondaryButtonTitle = secondaryButtonTitle {
                        Button {
                            secondaryButtonAction?()
                        } label: {
                            Text(secondaryButtonTitle)
                                .textStyle(.medium14)
                                .foregroundColor(.black1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.primary20)
                                .cornerRadius(100)
                        }
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(width: 353, height: 323)
            .background(.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
    }
}

#Preview {
    CustomAlertView(
        title: "캘린더를 연동할까요?",
        message: "현재 캘린더가 연동되어 있지 않아요",
        messageColor: .primary1,
        primaryButtonTitle: "Google 캘린더 연동",
        secondaryButtonTitle: "취소",
        primaryButtonAction: {
            print("Google 캘린더 연동")
        },
        secondaryButtonAction: {
            print("취소")
        }
    )
    
    CustomAlertView(
        title: "캘린더를 동기화하고\n새 일정을 불러올까요?",
        message: "현재 캘린더가 연동되어 있어요",
        messageColor: .gray44450,
        primaryButtonTitle: "Google 캘린더 동기화",
        secondaryButtonTitle: "취소",
        primaryButtonAction: {
            print("Google 캘린더 동기화")
        },
        secondaryButtonAction: {
            print("취소")
        }
    )
}
