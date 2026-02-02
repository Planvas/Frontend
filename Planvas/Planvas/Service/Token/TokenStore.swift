//
//  TokenProvider.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation
import Moya

class TokenStore: TokenProviding {
    static let shared = TokenStore()
    private let userSession = "appNameUser"
    private let keyChain = KeychainManager.shared
    private let provider = MoyaProvider<AuthRouter>()
    
    var accessToken: String? {
        get {
            guard let userInfo = keyChain.loadSession(for: userSession) else { return nil }
            return userInfo.accessToken
        }
        set {
            guard var userInfo = keyChain.loadSession(for: userSession) else { return }
            userInfo.accessToken = newValue
            if keyChain.saveSession(userInfo, for: userSession) {
                print("유저 액세스 토큰 갱신됨: \(String(describing: newValue))")
            }
        }
    }
    
    var refreshToken: String? {
        get {
            guard let userInfo = keyChain.loadSession(for: userSession) else { return nil }
            return userInfo.refreshToken
        }
        
        set {
            guard var userInfo = keyChain.loadSession(for: userSession) else { return }
            userInfo.refreshToken = newValue
            if keyChain.saveSession(userInfo, for: userSession) {
                print("유저 리프레시 갱신됨")
            }
        }
    }
    func refreshToken(completion: @escaping (String?, (any Error)?) -> Void) {
        guard let userInfo = keyChain.loadSession(for: userSession), let refreshToken = userInfo.refreshToken else {
            let error = NSError(domain: "example.com", code: -2, userInfo: [NSLocalizedDescriptionKey: "UserSession or refreshToken not found"])
            completion(nil, error)
            return
        }
        
        // TODO: - 토큰 재발급
//        provider.request(.sendRefreshToken(refreshToken: refreshToken)) { result in
//            switch result {
//            case .success(let response):
//                if let jsonString = String(data: response.data, encoding: .utf8) {
//                    print("응답 JSON: \(jsonString)")
//                } else {
//                    print("JSON 데이터를 문자열로 변환할 수 없습니다.")
//                }
//                
//                do {
//                    let tokenData = try JSONDecoder().decode(TokenResponse.self, from: response.data)
//                    if tokenData.isSuccess {
//                        self.accessToken = tokenData.result.accessToken
//                        self.refreshToken = tokenData.result.refreshToken
//                        completion(self.accessToken, nil)
//                    } else {
//                        let error = NSError(domain: "example.com", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token Refresh failed: isSuccess false"])
//                        
//                        completion(nil, error)
//                    }
//                } catch {
//                    print("디코딩 에러: \(error)")
//                    completion(nil, error)
//                }
//                
//            case .failure(let error):
//                print("네트워크 에러 : \(error)")
//                completion(nil, error)
//            }
//        }
    }
    
    func clearSession() {
        keyChain.deleteSession(for: userSession)
        print("유저 세션 삭제됨")
    }
}
