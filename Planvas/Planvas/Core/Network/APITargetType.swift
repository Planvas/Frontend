import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("유효하지 않은 BASE_URL: \(Config.baseURL)")
        }
        return url
    }
    
    var headers: [String : String]? {
        var header = ["Content-Type": "application/json"]
        
        if let token = KeychainManager.shared.load(key: "accessToken") {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}

