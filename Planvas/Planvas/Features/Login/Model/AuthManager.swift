//
//  AuthManager.swift
//  palnBas_mango
//
//  Created by 송민교 on 1/16/26.
//
import Foundation
import Alamofire
import Moya

final class AuthManager {
    static let shared = AuthManager()
    private let provider = MoyaProvider<AuthRouter>()
    
    private init() {}
    
    // 현재 로그인상태 확인
    var isLogIn: Bool {
        return TokenStore.shared.accessToken != nil
    }
    
    // 구글 로그인
    func login(idToken: String, completion: @escaping (LoginSuccess?, Bool) -> Void) { // (성공 데이터?, 회원가입 필요여부)
        // TODO: - MockData 삭제 후 실제 요청코드 사용
        let mockUser = UserData(userId: "123", name: "망고테스트", provider: "google")
        let mockData = LoginSuccess(signupRequired: false, token: "fake_token", expiresIn: 3600, user: mockUser, provider: "google", name: "망고테스트")
        completion(mockData, false)
        return
        
//        provider.request(.googleLogin(idToken: idToken)) { result in
//            switch result {
//            case .success(let response):
//                do {
//                    let decodedData = try JSONDecoder().decode(GoogleLoginResponse.self, from: response.data)
//                    let SuccessData = decodedData.success
//                    
//                    if SuccessData?.signupRequired == true {
//                        print("회원가입이 필요합니다.")
//                        completion(nil, true)
//                    } else if let data = SuccessData, let token = data.token {
//                        KeychainManager.shared.save(key: "accessToken", value: token)
//                        completion(data, false)
//                    } else {
//                        completion(nil, false) // 디코딩실패
//                    }
//                } catch {
//                    print("디코딩 에러 발생: \(error)")
//                    completion(nil, false)
//                }
//
//            case .failure:
//                print("로그인 실패")
//                completion(nil, false)
//            }
//        }
    }
    
    // 로그아웃
    func logout() {
        TokenStore.shared.clearSession()
    }
}
