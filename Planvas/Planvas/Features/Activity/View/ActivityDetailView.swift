//
//  ActivityDetailView.swift
//  Planvas
//
//  Created by 정서영 on 2/12/26.
//

import SwiftUI

struct ActivityDetailView: View {
    @State private var viewModel: ActivityDetailViewModel
    @Environment(NavigationRouter<ActivityRoute>.self) var router
    
    let activityId: Int
    
    init(activityId: Int) {
        self.activityId = activityId
        let mockData = ActivityDetail(
            title: "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집",
            dDay: 16,
            date: "11/15 ~ 12/3",
            category: .growth,
            point: 30,
            description: "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집합니다.",
            thumbnailUrl: ""
        )

        _viewModel = State(
            initialValue: ActivityDetailViewModel(activity: mockData)
        )
    }
    
    var body: some View {
        ScrollView{
            VStack{
                HeaderGroup
                Spacer()
                BodyGroup
                BottomGroup
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .task{viewModel.fetchActivityDetail(activityId: activityId)}
    }
    
    private var HeaderGroup: some View {
        ZStack{
            HStack{
                Button(action:{
                    router.pop()
                }, label:{
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black1)
                        .frame(width: 11, height: 18)
                })
                Spacer()
            }
            HStack{
                Text("성장 활동")
                    .foregroundStyle(.black1)
                    .textStyle(.bold20)
            }
        }
        .padding(.vertical)
        .padding(.bottom, 20)
    }
    
    private var BodyGroup: some View {
        VStack(alignment: .leading, spacing: 9){
            Text(viewModel.title)
                .textStyle(.semibold22)
                .foregroundStyle(.black1)
            
            HStack(spacing: 9){
                Text(viewModel.dDayText)
                    .textStyle(.medium14)
                    .foregroundStyle(.fff)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.primary1)
                    )
                
                Text(viewModel.date)
                    .textStyle(.semibold18)
                    .foregroundStyle(.primary1)
            }
            
            ZStack{
                RoundedRectangle(cornerRadius: 15)
                    .aspectRatio(contentMode: .fit)
                
                Image(.banner1)
                    .resizable()
                    .scaledToFit()
            }
            .overlay(alignment: .topTrailing) {
                Text(viewModel.categoryText)
                    .textStyle(.semibold16)
                    .foregroundStyle(.fff)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundStyle(.primary1)
                    )
                    .padding(17)
            }
        }
    }
    
    private var BottomGroup: some View {
        VStack(alignment: .leading){
            Text(viewModel.title)
                .textStyle(.semibold18)
                .foregroundStyle(.black1)
                .padding(.top, 26)
            
            Text(viewModel.description)
                .textStyle(.medium14)
                .foregroundStyle(.black1)
                .padding(.bottom, 26)
            
            HStack(spacing: 5){
                Button(action: {}, label: {
                    Text("장바구니")
                        .textStyle(.semibold18)
                        .foregroundStyle(.fff)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.primary1)
                        )
                })
                
                Button(action: {}, label: {
                    Text("일정 추가")
                        .textStyle(.semibold18)
                        .foregroundStyle(.black1)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.subPurple)
                        )
                })
            }
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    let router = NavigationRouter<ActivityRoute>()
    
    ActivityDetailView(activityId: 1)
        .environment(router)
}
