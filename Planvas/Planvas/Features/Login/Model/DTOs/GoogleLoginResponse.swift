import Foundation

struct GoogleLoginResponse: Decodable {
    let resultType: String
    let error: ErrorResponse?
    let success: LoginSuccess?
}

struct LoginSuccess: Decodable {
    let signupRequired: Bool
    let token: String?
    let expiresIn: Int?
    let user: UserData?
    // 회원가입이 필요할시
    let provider: String?
    let name: String?
}

