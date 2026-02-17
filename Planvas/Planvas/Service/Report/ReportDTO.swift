import Foundation

struct ReportResponse: Decodable {
    let resultType: String
    let error: ReportErrorResponse?
    let success: ReportSuccessResponse?
}

// MARK: - Error Response
struct ReportErrorResponse: Decodable {
    let reason: String?
    let data: String?
}

// MARK: - Success Response
struct ReportSuccessResponse: Decodable {
    let goal: goalResponse
    let ratio: ratioResponse
    let summary: summaryResponse
    let cta: ctaResponse
}

struct goalResponse: Decodable {
    let goalId: Int
    let title: String
    let startDate: String
    let endDate: String
}

struct ratioResponse: Decodable {
    let target: RatioData
    let actual: RatioData
    
    struct RatioData: Decodable {
        let growthRatio: Int
        let restRatio: Int
    }
}

struct summaryResponse: Decodable {
    let type: String
    let title: String
    let subTitle: String
}

struct ctaResponse: Decodable {
    let primary: primaryDetail
    let secondary: SecondaryDetail
    
    struct primaryDetail: Decodable {
        let type: String
        let focus: String?
        let label: String
    }
    struct SecondaryDetail: Decodable {
        let type: String
        let label: String
    }
}
