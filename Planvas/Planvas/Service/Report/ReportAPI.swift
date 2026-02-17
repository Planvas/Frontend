import Foundation
import Alamofire
import Moya

enum ReportRouter {
    case getReport(goalId: Int)
}

extension ReportRouter: APITargetType {
    var path: String {
        switch self {
        case .getReport(let goalId):
            return "/api/reports/seasons/\(goalId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getReport:
            return .get
        }
    }
    
    var task: Task {
        return .requestPlain
    }
}

