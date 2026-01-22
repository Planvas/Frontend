import Foundation
import Moya
import Alamofire

enum AuthRouter {
    case googleSignUp(idToken: String)
    case googleLogin(idToken: String)
}

extension AuthRouter: APITargetType {
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
    
    var path: String {
        switch self {
        case .googleSignUp:
            return "api/users"
        case .googleLogin:
            return "api/users/oauth2/google"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .googleSignUp(let idToken), .googleLogin(let idToken):
            return .requestParameters(parameters: ["authorizationCode": idToken], encoding: JSONEncoding.default)
        }
    }
}
