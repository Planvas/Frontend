struct PastReportResponse: Decodable {
    let resultType: String
    let error: PastReportErrorResponse?
    let success: PastReportSuccessResponse?
}

struct PastReportSuccessResponse: Decodable {
    let seasons: [Seasons?]
    
    struct Seasons: Decodable {
        let goalId: Int
        let title: String
        let startDate: String
        let endDate: String
        let year: Int
    }
}

struct PastReportErrorResponse: Decodable {
    let reason: String
    let data: String?
}

// MARK: - 날짜를 튜플로 가공해서 제공하기
extension PastReportSuccessResponse.Seasons {
    var startDateTuple: (year: String, month: String, day: String)? {
        return startDate.toDateTuple()
    }
    var endDateTuple: (year: String, month: String, day: String)? {
        return endDate.toDateTuple()
    }
}
