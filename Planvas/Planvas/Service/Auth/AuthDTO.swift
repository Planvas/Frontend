import Foundation

struct GoogleSignupResponse: Decodable {
    let resultType: String
    let error: ErrorResponse?
    let success: SignUpSuccess?
}

struct SignUpSuccess: Decodable {
    let message: String
    let token: String
    let expiresIn: Int
    let user: UserData?
}

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

struct ErrorResponse: Decodable {
    let errorCode: String
    let reason: String?
    let data: String?
}

struct UserData: Decodable {
    let userId: String
    let name: String
    let provider: String
}
