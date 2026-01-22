/// Info.plist에서 BASE_URL 값을 가져와서 사용
import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist 없음")
        }
        return dict
    }()
    
    static let baseURL: String = {
        guard let baseURL = Config.infoDictionary["BASE_URL"] as? String else {
            fatalError()
        }
        return baseURL
    }()
    
    static let ClientId: String = {
        guard let ClientId = Config.infoDictionary["CLIENT_ID"] as? String else {
            fatalError()
        }
        return ClientId
    }()
    
    static let ServerClientId: String = {
        guard let ServerClientId = Config.infoDictionary["SERVER_CLIENT_ID"] as? String else {
            fatalError()
        }
        return ServerClientId
    }()
}
