//
//  MainActivityItem.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI

// MARK: - 인기 성장 활동 아이템
struct MainActivityItem: View {
    let item: ActivityItem
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(index)")
                .textStyle(.bold20)
                .foregroundStyle(.primary1)
                .padding(.bottom, 2)
            Text(item.title)
                .textStyle(.medium20)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 2)
            Text(item.subtitle)
                .textStyle(.medium14)
                .foregroundStyle(.primary1)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 5)
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 130, alignment: .top)
                .clipped()
                .padding(.bottom, 5)
            
            HStack{
                Spacer()
                Button(action:{}) {
                    Text("더 알아보기 >")
                        .textStyle(.medium14)
                        .foregroundStyle(.primary1)
                }
            }
        }
        .frame(width: 233, height: 284)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.subPurple)
        )
        .shadow(
            color: .black20,
            radius: 4,
            x: 0,
            y: 4
        )
    }
}
