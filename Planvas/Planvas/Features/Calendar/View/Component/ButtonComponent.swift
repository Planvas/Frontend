//
//  ButtonComponent.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .textStyle(.medium20)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 56)
            .background(.primary1)
            .cornerRadius(12)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .textStyle(.medium20)
                    .foregroundColor(.black1)
                Spacer()
            }
            .frame(height: 56)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "완료") {
            print("완료 버튼 클릭")
        }
        
        SecondaryButton(title: "일정 가져오기") {
            print("일정 가져오기 버튼 클릭")
        }
    }
    .padding()
}
