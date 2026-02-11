import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var headers: [String: String]? {
        switch task {
        case .requestJSONEncodable, .requestParameters, .requestPlain:
            return ["Content-Type": "application/json"]
        case .uploadMultipart:
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }
    
    var validationType: ValidationType { .successCodes }
}
