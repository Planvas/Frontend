import Moya
import Alamofire
import Foundation

enum PastReportRouter {
    case getPastReport(year: Int?)
}

extension PastReportRouter: APITargetType {
    var path: String {
        return "api/reports/seasons"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getPastReport(let year):
            if let year = year {
                return .requestParameters(parameters: ["year": year], encoding: URLEncoding.queryString)
            }
            return .requestPlain
        }
    }
}
