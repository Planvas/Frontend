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
                        } else {
                            self.errorMessage = decoded.error?.reason ?? "목표 생성 실패"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "응답 파싱 오류"
                    }
                }

            case .failure(let error):
                let statusCode = error.response?.statusCode

                if statusCode == 409 {
                    DispatchQueue.main.async {
                        self.errorMessage = "이미 진행 중인 목표가 있어요."
                    }
                    self.fetchCurrentGoal(fallbackToCalendar: true)
                    return
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "서버 오류가 발생했어요. 캘린더로 이동할게요."
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

                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "현재 목표 응답 파싱 오류"
                    }
                }

            case .failure:
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "현재 목표 조회 실패(서버 오류)"
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
    
    func checkHasCurrentGoal(completion: @escaping (Bool) -> Void) {
        provider.request(.getCurrentGoal) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 404 {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(GoalDetailResponse.self, from: response.data)
                    DispatchQueue.main.async { completion(decoded.success?.goalId != nil) }
                } catch {
                    DispatchQueue.main.async { completion(false) }
                }

            case .failure(let error):
                if error.response?.statusCode == 404 {
                    DispatchQueue.main.async { completion(false) }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            }
        }
    }
    
    // MARK: - 온보딩 저장
    func saveOnboarding(
        goalSetupVM: GoalSetupViewModel,
        selectedPresetId: Int?,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        let interestIds = goalSetupVM.interestActivityTypes.enumerated().compactMap { index, item in
            goalSetupVM.selectedInterestIds.contains(item.id) ? (index + 1) : nil
        }

        let body = SaveOnboardingRequestDTO(
            goalPeriod: GoalPeriodDTO(
                title: goalSetupVM.goalName,
                dateRange: DateRangeDTO(
                    startDate: goalSetupVM.formatAPIDate(goalSetupVM.startDate),
                    endDate: goalSetupVM.formatAPIDate(goalSetupVM.endDate)
                ),
                ratio: RatioDTO(
                    growth: goalSetupVM.growthPercent,
                    rest: goalSetupVM.restPercent,
                    presetType: selectedPresetId == nil ? .custom : .preset
                )
            ),
            profile: OnboardingProfileDTO(interests: interestIds),
            calendar: OnboardingCalendarDTO(
                connect: goalSetupVM.isCalendarConnected,
                provider: goalSetupVM.isCalendarConnected ? .google : nil
            )
        )

        provider.request(.postOnboarding(body: body)) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    // 디버깅 로그: status code / raw body 확인
                    print("온보딩 저장 statusCode:", response.statusCode)
                    if let raw = String(data: response.data, encoding: .utf8) {
                        print("온보딩 저장 raw:", raw)
                    }

                    do {
                        let decoded = try JSONDecoder().decode(SaveOnboardingResponseDTO.self, from: response.data)

                        // 성공 판정: statusCode + resultType
                        let ok = (200..<300).contains(response.statusCode) && decoded.resultType == "SUCCESS"

                        if ok {
                            completion(true)
                        } else {
                            self.errorMessage = decoded.error?.reason ?? "온보딩 저장에 실패했습니다."
                            completion(false)
                        }
                    } catch {
                        self.errorMessage = "온보딩 저장 응답 파싱 실패"
                        completion(false)
                    }

                case .failure(let error):
                    let statusCode = error.response?.statusCode
                    print("온보딩 저장 실패 statusCode:", statusCode ?? -1)
                    self.errorMessage = "네트워크 오류가 발생했습니다."
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - 목표 기간/이름 수정 (PATCH /api/goals/{goalId})
    func editGoal(
        goalId: Int,
        title: String?,
        startDate: String?,
        endDate: String?,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        let body = EditGoalRequestDTO(
            title: title,
            startDate: startDate,
            endDate: endDate,
            targetGrowthRatio: nil,
            targetRestRatio: nil
        )

        provider.request(.patchGoalBase(goalId: goalId, EditGoalRequestDTO: body)) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    print("editGoal statusCode:", response.statusCode)
                    print("editGoal raw:", String(data: response.data, encoding: .utf8) ?? "nil")

                    let ok = (200..<300).contains(response.statusCode)
                    if ok {
                        completion(true)
                    } else {
                        self.errorMessage = "목표 수정 실패"
                        completion(false)
                    }

                case .failure(let error):
                    let code = error.response?.statusCode ?? -1
                    print("editGoal failure statusCode:", code)
                    print("editGoal failure:", error.localizedDescription)
                    if let data = error.response?.data {
                        print("editGoal failure raw:", String(data: data, encoding: .utf8) ?? "nil")
                    }
                    self.errorMessage = "네트워크 오류(목표 수정)"
                    completion(false)
                }
            }
        }
    }

    // MARK: - 목표 비율 수정 (PATCH /api/goals/{goalId}/ratio)
    func editGoalRatio(
        goalId: Int,
        growth: Int,
        rest: Int,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        let body = EditRatioRequestDTO(growthRatio: growth, restRatio: rest)

        provider.request(.patchGoalRatio(goalId: goalId, EditRatioRequestDTO: body)) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let response):
                    print("editGoalRatio statusCode:", response.statusCode)
                    print("editGoalRatio raw:", String(data: response.data, encoding: .utf8) ?? "nil")

                    let ok = (200..<300).contains(response.statusCode)
                    completion(ok)

                case .failure(let error):
                    let code = error.response?.statusCode ?? -1
                    print("editGoalRatio failure statusCode:", code)
                    print("editGoalRatio failure:", error.localizedDescription)
                    if let data = error.response?.data {
                        print("editGoalRatio failure raw:", String(data: data, encoding: .utf8) ?? "nil")
                    }
                    self.errorMessage = "네트워크 오류(비율 수정)"
                    completion(false)
                }
            }
        }
    }
}
