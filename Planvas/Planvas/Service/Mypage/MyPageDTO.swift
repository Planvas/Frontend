import Foundation

// MARK: - 현재 목표 조회 DTO
struct GoalResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: GoalSuccessResponse?
}

struct GoalSuccessResponse: Decodable {
    let goalId: Int?
    let title: String?
    let startDate: String?
    let endDate: String?
    let growthRatio: Int?
    let restRatio: Int?
    let currentGrowthRatio: Int?
    let currentRestRatio: Int?
    let presetType: String?
    let presetId: Int?

    /// Preview/테스트용 (디코딩 실패 시 대체)
    init(
        goalId: Int? = nil,
        title: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        growthRatio: Int? = nil,
        restRatio: Int? = nil,
        currentGrowthRatio: Int? = nil,
        currentRestRatio: Int? = nil,
        presetType: String? = nil,
        presetId: Int? = nil
    ) {
        self.goalId = goalId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.growthRatio = growthRatio
        self.restRatio = restRatio
        self.currentGrowthRatio = currentGrowthRatio
        self.currentRestRatio = currentRestRatio
        self.presetType = presetType
        self.presetId = presetId
    }

    /// Decodable
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        goalId = try c.decodeIfPresent(Int.self, forKey: .goalId)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        startDate = try c.decodeIfPresent(String.self, forKey: .startDate)
        endDate = try c.decodeIfPresent(String.self, forKey: .endDate)
        growthRatio = try c.decodeIfPresent(Int.self, forKey: .growthRatio)
        restRatio = try c.decodeIfPresent(Int.self, forKey: .restRatio)
        currentGrowthRatio = try c.decodeIfPresent(Int.self, forKey: .currentGrowthRatio)
        currentRestRatio = try c.decodeIfPresent(Int.self, forKey: .currentRestRatio)
        presetType = try c.decodeIfPresent(String.self, forKey: .presetType)
        presetId = try c.decodeIfPresent(Int.self, forKey: .presetId)
    }

    private enum CodingKeys: String, CodingKey {
        case goalId, title, startDate, endDate, growthRatio, restRatio
        case currentGrowthRatio, currentRestRatio, presetType, presetId
    }
}

extension GoalSuccessResponse {
    /// Preview/테스트용 샘플 (활동 완료 모달 등)
    static var preview: GoalSuccessResponse {
        GoalSuccessResponse(
            growthRatio: 60,
            restRatio: 40,
            currentGrowthRatio: 35,
            currentRestRatio: 20
        )
    }
}

// MARK: - 내 정보 조회 DTO
struct UserResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: UserContainer?
}

struct UserContainer: Decodable {
    let user: UserSuccessResponse?
}

struct UserSuccessResponse: Decodable {
    let userId: Int
    let name: String
    let provider: String
    let createdAt: String
    let onboardingCompleted: Bool
}
