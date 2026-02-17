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
