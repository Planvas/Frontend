//
//  ActivitySelectionView.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI

struct ActivitySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedType: String
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            Spacer().frame(height: 45)
            
            Button {
                selectedType = "성장"
                // 버튼 누르면 시트 닫히도록
                dismiss()
                
                print("성장 활동 클릭")
            } label: {
                HStack {
                    Text("성장 활동")
                        .textStyle(.semibold20)
                        .foregroundStyle(.black1)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
            
            // 구분선
            Rectangle()
                .fill(.line)
                .frame(height: 2)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            
            Button {
                selectedType = "휴식"
                // 버튼 누르면 시트 닫히도록
                dismiss()
                
                print("휴식 활동 클릭")
            } label: {
                HStack {
                    Text("휴식 활동")
                        .textStyle(.semibold20)
                        .foregroundStyle(.black1)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
            
        }
        .ignoresSafeArea()
        .padding(.horizontal, 20)
        .padding(.bottom, 75)
    }
}

#Preview {
    ActivitySelectionView(
        selectedType: .constant("성장 활동")
    )
}
