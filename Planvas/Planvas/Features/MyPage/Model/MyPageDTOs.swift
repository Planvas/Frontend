import Foundation

struct GoalResponse: Decodable {
    let resultType: String
    let error: GoalErrorResponse?
    let success: GoalSuccessResponse?
}

struct GoalErrorResponse: Decodable {
    let reason: String
    let data: String?
}

struct GoalSuccessResponse: Decodable {
    let goalId: Int?
    let title: String?
    let startDate: String?
    let endDate: String?
    let growthRatio: Int?
    let restRatio: Int?
}
