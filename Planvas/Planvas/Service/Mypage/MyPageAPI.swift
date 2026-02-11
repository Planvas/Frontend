import Foundation
import Alamofire
import Moya

enum MyPageRouter {
    case getCurrentGoal
}

extension MyPageRouter: APITargetType {
    var path: String {
        return "api/goals/current"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
}
