import Foundation
struct PastReportResponse: Decodable {
    let resultType: String
    let error: PastReportErrorResponse?
    let success: [PastReportSuccessResponse?]
}

struct PastReportSuccessResponse: Decodable, Identifiable {
    let id: Int
    let title: String
    let startDate: String
    let endDate: String
    let year: Int
}

struct PastReportErrorResponse: Decodable {
    let reason: String
    let data: String?
}

// MARK: - 서버 날짜를 Date()로 변환
extension PastReportSuccessResponse {
    var startDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: startDate)
    }
    var endDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: endDate)
    }
}
