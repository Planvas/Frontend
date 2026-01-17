import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        return URL(string: "https://~~.com")!
    }
    
    var headers: [String : String]? {
        var header = ["Content-Type": "application/json"]
        
        if let token = KeychainManager.shared.load(key: "accessToken") {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}

