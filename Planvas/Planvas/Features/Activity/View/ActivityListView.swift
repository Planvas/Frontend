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
    
    @State private var showRecommendHeader = true
    @State private var lastDragTranslation: CGFloat = 0
    private let recommendHeaderHeight: CGFloat = 65

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
            await vm.onChangeTab(selectedActivityType, searchText: searchText)
        }
        .onChange(of: selectedActivityType) { _, newValue in
            withAnimation(.easeOut(duration: 0.18)) { showRecommendHeader = true }
            lastDragTranslation = 0
            Task { await vm.onChangeTab(newValue, searchText: searchText) }
        }

        .onChange(of: searchText) { _, newValue in
            withAnimation(.easeOut(duration: 0.18)) { showRecommendHeader = true }
            lastDragTranslation = 0
            Task {
                await vm.resetAndFetch(tab: selectedActivityType, searchText: newValue, onlyAvailable: onlyAvailable)
            }
        }

        .onChange(of: onlyAvailable) { _, newValue in
            withAnimation(.easeOut(duration: 0.18)) { showRecommendHeader = true }
            lastDragTranslation = 0
            Task {
                await vm.resetAndFetch(tab: selectedActivityType, searchText: searchText, onlyAvailable: newValue)
            }
        }
        .onChange(of: vm.isLoading) { _, loading in
            if loading {
                showRecommendHeader = true
                lastDragTranslation = 0
            }
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
                // 버튼 누르면 장바구니 화면으로 이동하도록 수정
                router.push(.activityCart)
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
        let isRestTab = (selectedActivityType == "휴식")
        
        return VStack(alignment: .leading, spacing: 0) {
            // 관심 분야 그냥 텍스트
            if !isRestTab {
                Text("관심 분야")
                    .textStyle(.semibold20)
                    .foregroundStyle(.gray444)
                    .padding(.bottom, 8)
            }
            
            HStack(spacing: 0) {
                // 대표 관심사 칩
                if !isRestTab {
                    Button {
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
                }
                
                // 카테고리 칩 스크롤
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.categories) { category in
                            Button {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    showRecommendHeader = true
                                }
                                lastDragTranslation = 0
                                
                                Task {
                                    await vm.selectCategory(category, tab: selectedActivityType, searchText: searchText)
                                }
                            } label: {
                                Text(category.name)
                                    .textStyle(.medium16)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        vm.selectedCategoryName == category.name
                                        ? .primary1
                                        : .fff
                                    )
                                    .foregroundStyle(
                                        vm.selectedCategoryName == category.name
                                        ? .fff
                                        : .gray44450
                                    )
                                    .overlay(
                                        Capsule().stroke(Color.ccc, lineWidth: 1)
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
        let filtered = vm.filteredActivities(
            searchText: searchText,
            onlyAvailable: onlyAvailable
        )

        return ZStack(alignment: .top) {
            ScrollView {
                Spacer().frame(height: recommendHeaderHeight)

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
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { item in
                            ActivityCardView(item: item)
                                .onAppear {
                                    Task {
                                        await vm.loadMoreIfNeeded(
                                            currentItem: item,
                                            tab: selectedActivityType,
                                            searchText: searchText
                                        )
                                    }
                                }
                        }

                        if vm.isFetchingMore {
                            ProgressView().padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 75)
                }
            }
            .scrollIndicators(.hidden)
            // 드래그 방향만으로 show/hide
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let dy = value.translation.height - lastDragTranslation
                        lastDragTranslation = value.translation.height

                        let threshold: CGFloat = 6

                        // 아래→위로 드래그
                        if dy < -threshold {
                            if showRecommendHeader {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    showRecommendHeader = false
                                }
                            }
                        }
                        // 위→아래로 드래그
                        else if dy > threshold {
                            if !showRecommendHeader {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    showRecommendHeader = true
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        lastDragTranslation = 0
                    }
            )

            // show 상태에 따라 숨김/등장
            recommendHeader
                .offset(y: showRecommendHeader ? 0 : -recommendHeaderHeight)
                .opacity(showRecommendHeader ? 1 : 0)
                .animation(.easeOut(duration: 0.18), value: showRecommendHeader)
        }
    }
    
    // MARK: - ~ 추천활동, 토글 부분
    private var recommendHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 0) {
                    Text(selectedActivityType)
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
        }
        .frame(maxWidth: .infinity)
        .background(.fff)
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
