import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        guard let url = URL(string:)
    }
    
    var headers: [String : String]? {
        var header = ["Content-Type": "application/json"]
        
        if let token = KeychainManager.shared.load(key: "accessToken") {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}

