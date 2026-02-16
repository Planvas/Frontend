//
//  ActivityListView.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI

struct ActivityListView: View {
    @Environment(NavigationRouter<ActivityRoute>.self) var router
    @EnvironmentObject var container: DIContainer
    
    @Environment(GoalSetupViewModel.self) private var goalVM
    @State private var vm = ActivityListViewModel()

    @State private var showActivitySheet: Bool = false
    @State private var selectedActivityType: String = "성장"
    @State private var searchText: String = ""
    
    @State private var onlyAvailable: Bool = false
    @State private var showInterestEditSheet = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 성장/휴식 활동 선택, 장바구니
            HeaderGroup
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top, 68)
            
            // 검색창
            SearchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 31)
            
            // 관심 분야
            InterestSection
                .padding(.horizontal, 20)
                .padding(.bottom, 17)
            
            // 구분선
            Rectangle()
                .fill(.line)
                .frame(height: 10)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            
            // 활동 리스트
            if vm.isLoading {
                ProgressView().padding(.top, 50)
                Spacer()
            } else {
                activityList
            }
                
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await vm.fetchActivities(tab: selectedActivityType)
        }
        .onChange(of: selectedActivityType) { _, newValue in
            Task { await vm.fetchActivities(tab: newValue, searchText: searchText) }
        }
        .onChange(of: searchText) { _, newValue in
            Task { await vm.fetchActivities(tab: selectedActivityType, searchText: newValue) }
        }
        .sheet(isPresented: $showActivitySheet) {
            ActivitySelectionView(
                selectedType: $selectedActivityType
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.fff)
        }
        .sheet(isPresented: $showInterestEditSheet) {
            InterestEditSheetView()
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.fff)
        }
    }
    
    // MARK: - 헤더 (성장/휴식 활동 선택, 장바구니)
    private var HeaderGroup: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Button {
                // 버튼 누르면 성장으로 할지 휴식으로 할지 팝업 뜨도록
                 showActivitySheet = true
                
                print("성장/휴식 활동 선택 버튼 클릭")
                
            } label: {
                HStack(spacing: 10) {
                    Text(selectedActivityType + " 활동")
                        .textStyle(.bold20)
                        .foregroundStyle(.black1)
                    
                    Image(systemName: "chevron.down")
                        .textStyle(.bold20)
                        .foregroundStyle(.black1)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                // TODO: 버튼 누르면 장바구니 화면으로 이동하도록 수정
                
                print("장바구니 버튼 클릭")
                
            } label: {
                Image("shopping-cart")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 검색창
    private var SearchBar: some View {
        HStack(spacing: 0) {
            // 검색 아이콘
            ZStack {
                Circle()
                    .fill(.gray444)
                    .frame(width: 42, height: 42)

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.fff)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            // 텍스트 필드
            TextField("원하는 활동을 검색하세요", text: $searchText)
                .textStyle(.medium18)
                .foregroundStyle(.black1)
                .padding(.leading, 15)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .background(.fff)
        .overlay(
            Capsule()
                .stroke(.gray444, lineWidth: 1.5)
        )
    }
    
    // MARK: - 관심 분야 선택
    private var InterestSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 관심 분야 그냥 텍스트
            Text("관심 분야")
                .textStyle(.semibold20)
                .foregroundStyle(.gray444)
                .padding(.bottom, 8)
            
            HStack(spacing: 0) {
                // 대표 관심사 칩
                Button {
                    // 버튼 누르면 관심 분야 재설정하는 시트 뜨도록
                    showInterestEditSheet = true
                    
                    print("관심 분야 재설정 버튼 클릭")
                    
                } label: {
                    HStack(spacing: 6) {
                        Text(mainInterest)
                            .textStyle(.medium16)
                            .foregroundStyle(.white)

                        if extraCount > 0 {
                            Text("+\(extraCount)")
                                .textStyle(.medium14)
                                .foregroundStyle(.primary1)
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 0.5)
                                .background(.subPurple)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal, 17)
                    .padding(.vertical, 8)
                    .background(.primary1)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // 구분선
                Rectangle()
                    .fill(.ccc)
                    .frame(height: 28)
                    .frame(width: 2)
                    .padding(.horizontal, 7)
                
                // 카테고리 칩 스크롤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.categoryChips, id: \.self) { category in
                            Button {
                                Task {
                                    await vm.selectCategory(category, tab: selectedActivityType, searchText: searchText)
                                }
                            } label: {
                                Text(category)
                                    .textStyle(.medium16)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        vm.selectedCategory == category
                                        ? .primary1
                                        : .fff
                                    )
                                    .foregroundStyle(
                                        vm.selectedCategory == category
                                        ? .fff
                                        : .gray44450
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.ccc, lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 활동 리스트
    private var activityList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 추천 활동 그냥 텍스트
            HStack {
                HStack(spacing: 0) {
                    Text(selectedActivityType )
                        .textStyle(.bold25)
                        .foregroundStyle(.primary1)
                    
                    Text(" 추천활동")
                        .textStyle(.semibold25)
                        .foregroundStyle(.black1)
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 20)
            
            // 가능한 일정만 보기
            HStack(spacing: 8) {
                Spacer()
                
                Text("가능한 일정만 보기")
                    .textStyle(.medium16)
                    .foregroundStyle(.primary1)
                
                Toggle("", isOn: $onlyAvailable)
                    .labelsHidden()
                    .tint(.primary1)
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 20)
            
            // 리스트 컴포넌트들 스크롤
            let filtered = vm.filteredActivities(
                searchText: searchText,
                onlyAvailable: onlyAvailable
            )

            if filtered.isEmpty {

                VStack(spacing: 8) {
                    Spacer().frame(height: 63)

                    Text("검색 결과 없음")
                        .textStyle(.semibold20)
                        .foregroundStyle(.gray444)

                    Text("검색어가 맞는지 다시 한 번 확인해주세요 ")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray444)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 75)

            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { item in
                            ActivityCardView(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 75)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private var selectedInterestTitles: [String] {
        goalVM.interestActivityTypes
            .filter { goalVM.selectedInterestIds.contains($0.id) }
            .map { $0.title }
    }

    private var mainInterest: String {
        selectedInterestTitles.first ?? "관심 분야 선택"
    }

    private var extraCount: Int {
        max(selectedInterestTitles.count - 1, 0)
    }
}

// MARK: - 프리뷰
#Preview {
    let goalVM = GoalSetupViewModel()
    let container = DIContainer()
    let router = NavigationRouter<ActivityRoute>()
    
    // 프리뷰용 더미 선택
    goalVM.selectedInterestIds = [
        goalVM.interestActivityTypes[0].id,
        goalVM.interestActivityTypes[1].id
    ]

    return ActivityListView()
        .environment(goalVM)
        .environmentObject(container)
        .environment(router)
}
