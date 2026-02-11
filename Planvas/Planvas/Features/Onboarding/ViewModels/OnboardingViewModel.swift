//
//  OnboardingViewModel.swift
//  Planvas
//
//  Created by 황민지 on 2/11/26.
//

import Foundation
import Observation
import Moya

@Observable
@MainActor
final class OnboardingViewModel {
    private let provider: MoyaProvider<OnboardingAPI>
    
    init(provider: MoyaProvider<OnboardingAPI>) {
        self.provider = provider
    }

    var createdGoalId: Int? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // 유형별 비율 추천 목록 상태 추가
    var ratioPresets: [RatioPreset] = []
    
    // 사용자가 선택한 프리셋 기억
    var selectedPresetId: Int? = nil
    var selectedPresetStep: Int? = nil
    
    // MARK: - 목표 기간/이름 생성
    func createGoal(
        title: String,
        startDate: String,
        endDate: String,
        targetGrowthRatio: Int,
        targetRestRatio: Int
    ) {
        isLoading = true

        let request = CreateGoalRequestDTO(
            presetId: selectedPresetId, // 자동으로 nil / 선택한 프리셋 id (선택한 프리셋에서 커스텀하면 nil이 됨)
            title: title,
            startDate: startDate,
            endDate: endDate,
            targetGrowthRatio: targetGrowthRatio,
            targetRestRatio: targetRestRatio
        )

        provider.request(.postGoalBase(CreateGoalRequestDTO: request)) { [weak self] result in
            guard let self else { return }

            self.isLoading = false

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(CreateGoalResponse.self, from: response.data)

                    if let success = decoded.success {
                        DispatchQueue.main.async {
                            self.createdGoalId = success.goalId
                            print("목표 생성 성공, goalId:", success.goalId)
                        }
                    } else {
                        self.errorMessage = decoded.error?.reason ?? "목표 생성 실패"
                        print("목표 생성 실패:", self.errorMessage ?? "")
                    }
                } catch {
                    print("CreateGoal 디코딩 오류:", error)
                }

            case .failure(let error):
                print("CreateGoal API 오류:", error)
            }
        }
    }
    
    // 서버 전송용 날짜 포맷: "yyyy-MM-dd"
    func formatDateForAPI(_ date: Date?) -> String {
        guard let date else { return "" }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }
    
    
    // MARK: - 유형별 비율 추천 목록 조회
    
    // 프리셋 선택
    func selectPreset(_ preset: RatioPreset) {
        selectedPresetId = preset.presetId
        selectedPresetStep = preset.growthRatio / 10
    }
    
    // 프리셋 선택했던 거 리셋
    func clearSelectedPreset() {
        selectedPresetId = nil
        selectedPresetStep = nil
    }
    
    func fetchRatioPresets() {
        isLoading = true
        errorMessage = nil

        provider.request(.getRatioList) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
            }

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(RatioListResponse.self, from: response.data)

                    if let success = decoded.success {
                        DispatchQueue.main.async {
                            self.ratioPresets = success.presets
                        }
                        print("비율 추천 목록 조회 성공:", success.presets.count)
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = decoded.error?.reason ?? "비율 추천 목록 조회 실패"
                        }
                        print("비율 추천 목록 조회 실패:", self.errorMessage ?? "")
                    }
                } catch {
                    print("RatioList 디코딩 오류:", error)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "네트워크 오류가 발생했어요."
                }
                print("RatioList API 오류:", error)
            }
        }
    }
}
