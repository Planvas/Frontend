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

    // 에러 나도 캘린더로 이동
    var shouldNavigateToCalendar: Bool = false

    // ratio presets
    var ratioPresets: [RatioPreset] = []

    // 선택 프리셋
    var selectedPresetId: Int? = nil
    var selectedPresetStep: Int? = nil

    // MARK: - 목표 생성 (POST)
    func createGoal(
        title: String,
        startDate: String,
        endDate: String,
        targetGrowthRatio: Int,
        targetRestRatio: Int
    ) {
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
                            self.shouldNavigateToCalendar = true
                        } else {
                            self.errorMessage = decoded.error?.reason ?? "목표 생성 실패"
                            self.shouldNavigateToCalendar = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "응답 파싱 오류"
                        self.shouldNavigateToCalendar = true
                    }
                }

            case .failure(let error):
                let statusCode = error.response?.statusCode

                if statusCode == 409 {
                    DispatchQueue.main.async {
                        self.errorMessage = "이미 진행 중인 목표가 있어요. 캘린더로 이동할게요."
                    }
                    self.fetchCurrentGoal(fallbackToCalendar: true)
                    return
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "서버 오류가 발생했어요. 캘린더로 이동할게요."
                    self.shouldNavigateToCalendar = true
                }
            }
        }
    }

    // MARK: - 현재 목표 조회 (GET /goals/current)
    func fetchCurrentGoal(fallbackToCalendar: Bool = false) {
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

                        if let success = decoded.success, let goalId = success.goalId {
                            self.currentGoalId = goalId
                        } else {
                            self.errorMessage = decoded.error?.reason ?? "현재 목표 조회 실패"
                        }

                        if fallbackToCalendar {
                            self.shouldNavigateToCalendar = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "현재 목표 응답 파싱 오류"
                        if fallbackToCalendar {
                            self.shouldNavigateToCalendar = true
                        }
                    }
                }

            case .failure:
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "현재 목표 조회 실패(서버 오류)"
                    if fallbackToCalendar {
                        self.shouldNavigateToCalendar = true
                    }
                }
            }
        }
    }

    // MARK: - 서버 전송용 날짜 포맷 (yyyy-MM-dd)
    func formatDateForAPI(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - 프리셋 목록 조회 (GET /goals/ratio-presets)
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
                        } else {
                            self.errorMessage = decoded.error?.reason ?? "비율 추천 목록 조회 실패"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "RatioList 디코딩 오류"
                    }
                }

            case .failure:
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
}
