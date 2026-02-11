import Foundation
import Alamofire
import Moya

enum MyPageRouter {
    case getCurrentGoal
    case getUserInfo
}

extension MyPageRouter: APITargetType {
    var path: String {
        switch self {
        case .getCurrentGoal:
            return "/api/goals/current"
        case .getUserInfo:
            return "/api/users/me"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
}
