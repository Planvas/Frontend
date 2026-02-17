//
//  MainActivityItem.swift
//  Planvas
//
//  Created by 정서영 on 1/28/26.
//

import SwiftUI
import Kingfisher

// MARK: - 인기 성장 활동 아이템
struct MainActivityItem: View {
    @Environment(NavigationRouter<MainRoute>.self) var router
    
    let item: ActivityItem
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading) {
                Text("\(index)")
                    .textStyle(.bold20)
                    .foregroundStyle(.primary1)
                    .padding(.bottom, 2)
                    .padding(.top, 15)


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

                if let url = URL(string: item.imageName) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                        }
                        .retry(maxCount: 2, interval: .seconds(2))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150, alignment: .top)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Color.gray
                }
            }
            .padding(20)
            
            Spacer()
        }
        .frame(width: 233, height: 284)
        .background(Color.subPurple)
        
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color.primary1)
                    .frame(height: 0.2)
                
                HStack {
                    Spacer()
                    Button {
                        router.push(.activityDetail(activityId: item.activityId))
                    } label: {
                        Text("더 알아보기 >")
                            .textStyle(.medium14)
                            .foregroundStyle(.primary1)
                    }
                }
                .padding(20)
                .frame(height: 39)
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary1, lineWidth: 0.2)
        )
        .shadow(color: .black20, radius: 6, x: 0, y: 4)
    }
}
