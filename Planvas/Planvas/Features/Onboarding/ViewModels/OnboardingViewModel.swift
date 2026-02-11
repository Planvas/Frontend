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

    // MARK: - State
    var currentGoalId: Int? = nil
    var createdGoalId: Int? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // 유형별 비율 추천 목록
    var ratioPresets: [RatioPreset] = []

    // 사용자가 선택한 프리셋 기억
    var selectedPresetId: Int? = nil
    var selectedPresetStep: Int? = nil

    // MARK: - 목표 기간/이름 생성 (POST)
    func createGoal(
        title: String,
        startDate: String,
        endDate: String,
        targetGrowthRatio: Int,
        targetRestRatio: Int
    ) {
        // 입력값 최소 검증
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "목표 이름이 비어있어요."
            return
        }
        guard !startDate.isEmpty, !endDate.isEmpty else {
            errorMessage = "목표 기간이 비어있어요."
            return
        }

        isLoading = true
        errorMessage = nil
        createdGoalId = nil
        currentGoalId = nil

        let request = CreateGoalRequestDTO(
            presetId: selectedPresetId,
            title: title,
            startDate: startDate,
            endDate: endDate,
            targetGrowthRatio: targetGrowthRatio,
            targetRestRatio: targetRestRatio
        )

        provider.request(.postGoalBase(CreateGoalRequestDTO: request)) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(CreateGoalResponse.self, from: response.data)

                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let success = decoded.success {
                            self.createdGoalId = success.goalId
                            print("목표 생성 성공, goalId:", success.goalId)
                            return
                        }

                        let reason = decoded.error?.reason ?? "목표 생성 실패"
                        self.errorMessage = reason
                        print("목표 생성 실패:", reason)

                        // 서버가 200으로 FAIL 바디를 내려주는 경우 대비
                        if reason.contains("이미 진행 중인 목표") {
                            self.fetchCurrentGoal()
                        }
                    }
                } catch {
                    print("CreateGoal 디코딩 오류:", error)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "CreateGoal 디코딩 오류"
                    }
                }

            case .failure(let error):
                // 상태 변경은 메인으로
                DispatchQueue.main.async {
                    self.isLoading = false
                }

                // 409면 현재 목표 조회로 유도
                if self.isHTTP409(error) {
                    DispatchQueue.main.async {
                        self.errorMessage = "이미 진행 중인 목표가 있어요. 기존 목표를 불러올게요."
                    }
                    self.fetchCurrentGoal()
                    return
                }

                print("CreateGoal API 오류:", error)
                DispatchQueue.main.async {
                    self.errorMessage = "네트워크 오류가 발생했어요."
                }
            }
        }
    }

    // MARK: - 현재 목표 조회 (GET /goals/current)
    func fetchCurrentGoal() {
        isLoading = true
        errorMessage = nil
        currentGoalId = nil

        provider.request(.getCurrentGoal) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(GoalDetailResponse.self, from: response.data)

                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let goalId = decoded.success?.goalId {
                            self.currentGoalId = goalId
                            print("현재 목표 조회 성공, goalId:", goalId)
                        } else {
                            let reason = decoded.error?.reason ?? "현재 목표 조회 실패"
                            self.errorMessage = reason
                            print("현재 목표 조회 실패:", reason)
                        }
                    }
                } catch {
                    print("GoalDetail 디코딩 오류:", error)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "현재 목표 디코딩 오류"
                    }
                }

            case .failure(let error):
                print("getCurrentGoal API 오류:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "현재 목표 조회 네트워크 오류"
                }
            }
        }
    }

    // MARK: - 서버 전송용 날짜 포맷: "yyyy-MM-dd"
    func formatDateForAPI(_ date: Date?) -> String {
        guard let date else { return "" }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }

    // MARK: - 유형별 비율 추천 목록 조회 (GET /goals/ratio-presets)
    func fetchRatioPresets() {
        isLoading = true
        errorMessage = nil

        provider.request(.getRatioList) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    let decoded = try JSONDecoder().decode(RatioListResponse.self, from: response.data)

                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let success = decoded.success {
                            self.ratioPresets = success.presets
                            print("비율 추천 목록 조회 성공:", success.presets.count)
                        } else {
                            let reason = decoded.error?.reason ?? "비율 추천 목록 조회 실패"
                            self.errorMessage = reason
                            print("비율 추천 목록 조회 실패:", reason)
                        }
                    }
                } catch {
                    print("RatioList 디코딩 오류:", error)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "RatioList 디코딩 오류"
                    }
                }

            case .failure(let error):
                print("RatioList API 오류:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "네트워크 오류가 발생했어요."
                }
            }
        }
    }

    // MARK: - 프리셋 선택
    func selectPreset(_ preset: RatioPreset) {
        selectedPresetId = preset.presetId
        selectedPresetStep = preset.growthRatio / 10
    }

    func clearSelectedPreset() {
        selectedPresetId = nil
        selectedPresetStep = nil
    }

    // MARK: - Helpers
    private func isHTTP409(_ error: MoyaError) -> Bool {
        // 1) response가 있으면 여기로 가장 깔끔하게 체크 가능
        if let response = error.response, response.statusCode == 409 {
            return true
        }

        // 2) underlying에 response가 같이 붙는 케이스
        if case let .underlying(_, response) = error, response?.statusCode == 409 {
            return true
        }

        return false
    }
}
