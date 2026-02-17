//
//  Untitled.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import SwiftUI
import Moya

struct GoalInfoSetupView: View {
    @Environment(GoalSetupViewModel.self) private var viewModel
    @Environment(LoginViewModel.self) private var loginVM
    
    // 마이페이지 흐름인지 온보딩 흐름인지 알기 위해 두 라우터 모두 선언 (옵셔널)
    @Environment(NavigationRouter<MyPageRoute>.self) private var myPageRouter: NavigationRouter<MyPageRoute>?
    @Environment(NavigationRouter<OnboardingRoute>.self) private var onboardingRouter: NavigationRouter<OnboardingRoute>?
    
    @State private var fetchedUserName: String = ""
    @State private var didFetchName = false

    private let provider = APIManager.shared.createProvider(for: MainAPI.self)

    private var displayName: String {
        // loginVM (로그인 직후엔 여기 있을 수 있음)
        if !loginVM.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return loginVM.userName
        }
        // 온보딩에서 fetch한 이름
        if !fetchedUserName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fetchedUserName
        }
        // fallback
        return "사용자"
    }
    
    // 버튼 활성화 조건: 이름이 있고 + 시작일이 있고 + 종료일이 있을 때
    private var isSetupCompleted: Bool {
        let isNameValid = !viewModel.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return isNameValid && viewModel.startDate != nil && viewModel.endDate != nil
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                
                InfoGroup
                
                Spacer().frame(height: 13)
                
                GoalNameCard()
                
                Spacer().frame(height: 10)
                
                GoalPeriodCard()
                
                Spacer()
                
                if isSetupCompleted && viewModel.expandedSection == nil {
                    PrimaryButton(title: "설정하기") {
                        print("설정 완료: \(viewModel.goalName), \(viewModel.formatDate(viewModel.startDate)) ~ \(viewModel.formatDate(viewModel.endDate))")
                        
                        // 목표 비율 설정 화면 이동
                        if let myPageRouter = myPageRouter {
                            myPageRouter.push(.goalRatioInfo)
                        } else if let onboardingRouter = onboardingRouter {
                            onboardingRouter.push(.ratio)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 89)
                }
            }
            .padding(.top, 125)
        }
        .task {
            // 중복 호출 방지
            guard !didFetchName else { return }
            didFetchName = true

            // loginVM이 비었을 때만 서버에서 이름 fetch
            guard loginVM.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

            provider.request(.getMainData) { result in
                switch result {
                case .success(let response):
                    if let decoded = try? JSONDecoder().decode(MainDataResponse.self, from: response.data),
                       let name = decoded.success?.userName {
                        DispatchQueue.main.async {
                            self.fetchedUserName = name
                        }
                    }
                case .failure:
                    break
                }
            }
        }

        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - 멘트 그룹
    private var InfoGroup: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // 이름이 유효한지 확인 (공백 제외)
            let isNameValid = !viewModel.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            // 이름 카드가 열려있거나, 이름이 아직 없을 때 (이름 설정히더록)
            if viewModel.expandedSection == .name || !isNameValid {
                // 사용자 이름 적용
                Text("\(displayName)님의")
                    .textStyle(.semibold30)
                    .foregroundStyle(.black1)

                HStack(spacing: 0) {
                    Text("목표 이름")
                        .textStyle(.semibold30)
                        .foregroundStyle(.primary1)

                    Text("을 설정해주세요")
                        .textStyle(.semibold30)
                        .foregroundStyle(.black1)
                }
            }
            
            // 이름 입력이 완료되었고, 기간 카드가 열려있거나 이름 카드가 닫혔을 때 (기간 설정하도록)
            else {
                HStack(spacing: 0) {
                    Text(viewModel.goalName)
                        .textStyle(.semibold30)
                        .foregroundStyle(.primary1)

                    Text("의")
                        .textStyle(.semibold30)
                        .foregroundStyle(.black1)
                }
                
                Text("목표 기간을 설정해주세요")
                    .textStyle(.semibold30)
                    .foregroundStyle(.black1)
            }
        }
        .padding(.leading, 20)
    }
    
}

#Preview {
    let router = NavigationRouter<OnboardingRoute>()
    let goalVM = GoalSetupViewModel()
    let loginVM = LoginViewModel()
    let myPageRouter = NavigationRouter<MyPageRoute>()

    NavigationStack(path: .constant(router.path)) {
        GoalInfoSetupView()
            .environment(goalVM)
            .environment(loginVM)
            .environment(router)
            .environment(myPageRouter)
    }
    .environment(router)
}
