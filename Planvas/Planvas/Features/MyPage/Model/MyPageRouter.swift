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
    
    // TODO: - 추후 삭제
    var sampleData: Data {
        let json = """
            {
                "resultType":"SUCCESS",
                "error":null,
                "success":{
                    "goalId":12,
                    "title":"2026 새해 겨울 방학 갓생",
                    "startDate":"2025-12-22",
                    "endDate":"2026-02-28",
                    "growthRatio":70,
                    "restRatio":30
                }
            }
            """
        return  json.data(using: .utf8)!
    }
}
