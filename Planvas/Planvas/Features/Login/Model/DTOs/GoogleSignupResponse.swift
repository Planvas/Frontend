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
