import Foundation
import Alamofire
import Moya

final class AuthManager {
    static let shared = AuthManager()
    private let provider = APIManager.shared.createProvider(for: AuthRouter.self)
    
    private init() {}
    
    // 현재 로그인상태 확인
    var isLogIn: Bool {
        return TokenStore.shared.accessToken != nil
    }
    
    // 구글 로그인 및 필요시 자동 회원가입
    func login(idToken: String, completion: @escaping (LoginSuccess?, Bool) -> Void) { // (성공 데이터?, 회원가입 필요여부)
        provider.request(.googleLogin(idToken: idToken)) { result in
            switch result {
            case .success(let response):
                guard (200..<300).contains(response.statusCode) else {
                    print("로그인 요청 실패: 상태코드 \(response.statusCode)")
                    completion(nil, false)
                    return
                }
                do {
                    let decodedData = try JSONDecoder().decode(GoogleLoginResponse.self, from: response.data)
                    let successData = decodedData.success
                    
                    if successData?.signupRequired == true {
                        print("회원가입이 필요하여 자동 회원가입을 진행합니다.")
                        self.signUp(idToken: idToken) { signupData, error in
                            if let signupData = signupData {
                                let convertedData = LoginSuccess(
                                    signupRequired: false,
                                    token: signupData.token,
                                    expiresIn: signupData.expiresIn,
                                    user: signupData.user,
                                    provider: signupData.user?.provider,
                                    name: signupData.user?.name
                                )
                                completion(convertedData, false)
                            } else {
                                print("자동 회원가입 실패")
                                completion(nil, false)
                            }
                        }
                        
                    } else if let data = successData, let token = data.token {
                        let userInfo = UserInfo(
                            accessToken: token,
                            refreshToken: token
                        )
                        
                        let _ = KeychainManager.shared.saveSession(userInfo, for: "appNameUser")
                        
                        completion(data, false)
                        print("🔑 keychain accessToken:",
                              TokenStore.shared.accessToken ?? "nil")
                    } else {
                        completion(nil, false)
                    }
                } catch {
                    print("디코딩 에러 발생: \(error)")
                    completion(nil, false)
                }

            case .failure:
                print("로그인 실패")
                completion(nil, false)
            }
        }
    }
    
    // 구글 회원가입
    private func signUp(idToken: String, completion: @escaping (SignUpSuccess?, Error?) -> Void) {
        provider.request(.googleSignUp(idToken: idToken)) { result in
            switch result {
            case .success(let response):
                guard (200..<300).contains(response.statusCode) else {
                    print("회원가입 요청 실패: 상태코드 \(response.statusCode)")
                    completion(nil, nil)
                    return
                }
                do {
                    let decodedData = try JSONDecoder().decode(GoogleSignupResponse.self, from: response.data)
                    if let data = decodedData.success {
                        TokenStore.shared.accessToken = data.token
                        print("회원가입 및 로그인 성공")
                        completion(data, nil)
                    } else {
                        completion(nil, MoyaError.statusCode(response))
                    }
                } catch {
                    completion(nil, error)
                }
            case .failure(let error):
                print("회원가입 요청 실패")
                completion(nil, error)
            }
        }
    }
    
    // 로그아웃
    func logout() {
        TokenStore.shared.clearSession()
    }
}
