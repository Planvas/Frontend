//
//  ActivityFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI
import Moya

struct ActivityFlowView: View {
    @State private var router = NavigationRouter<ActivityRoute>()
    @State private var goalVM = GoalSetupViewModel()
    
    @State private var didFetchInterests = false
    @State private var isFetchingInterests = false
    private let provider = APIManager.shared.createProvider(for: OnboardingAPI.self)
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ActivityListView()
                .navigationDestination(for: ActivityRoute.self) { route in
                    switch route {
                    case .activityList:
                        ActivityListView()
                    case .activityDetail(let activityId):
                        ActivityDetailView(activityId: activityId)
                    case .activityCart:
                        CartView()
                    }
                }
        }
        .environment(router)
        .environment(goalVM)
        .onAppear {
            fetchMyInterestsIfNeeded()
        }
    }
    
    // MARK: - 활동 목록 페이지 들어갔을 때 선택해뒀던 관심 분야 바로 나오도록
    private func fetchMyInterestsIfNeeded() {
        if didFetchInterests { return }
        if isFetchingInterests { return }
        if !goalVM.selectedInterestIds.isEmpty {
            didFetchInterests = true
            return
        }

        isFetchingInterests = true

        provider.request(.getMyInterests) { result in
            DispatchQueue.main.async {
                defer { self.isFetchingInterests = false }

                switch result {
                case .success(let response):
                    guard (200..<300).contains(response.statusCode) else {
                        print("관심사 조회 실패 status: \(response.statusCode)")
                        return
                    }

                    do {
                        let decoded = try JSONDecoder().decode(MyInterestsResponseDTO.self, from: response.data)
                        let interests = decoded.success?.interests ?? []

                        let mappedUUIDs = Set(
                            interests.compactMap { serverItem in
                                goalVM.interestActivityTypes.first(where: { $0.title == serverItem.name })?.id
                            }
                        )

                        goalVM.selectedInterestIds = mappedUUIDs
                        self.didFetchInterests = true

                    } catch {
                        print("관심사 디코딩 오류: \(error)")
                    }

                case .failure(let error):
                    print("관심사 네트워크 오류: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ActivityFlowView()
}
