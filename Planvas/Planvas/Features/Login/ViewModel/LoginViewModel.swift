import Foundation
import GoogleSignIn
import Combine
import UIKit

class LoginViewModel: ObservableObject {
    @Published var isLoginSuccess = false
    @Published var isSignupRequired = false
    @Published var userName: String = ""
    @Published var errorMessage: String? = nil
    
    var rootRouter: RootRouter?
    
    @MainActor
    func GoogleLogin() {
        // SwiftUI에서는 현재 뷰의 UIViewController를 찾아와야 구글 로그인창이 뜸
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        // MARK: - 캘린더 연동
        let calendarScope = "https://www.googleapis.com/auth/calendar.readonly"
        
        /// 로그인 설정
        let config = GIDConfiguration(clientID: Config.ClientId, serverClientID: Config.ServerClientId)
        GIDSignIn.sharedInstance.configuration = config
        
        // MARK: - 로그인 요청
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC, hint: nil, additionalScopes: [calendarScope]) { [weak self] GIDSignInResult, error in
            print("1. 구글 SDK 응답 도착")
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("구글 로그인 에러발생: \(error.localizedDescription)")
                return
            }
            
            guard let idToken = GIDSignInResult?.user.idToken?.tokenString else {
                self?.errorMessage = "구글 로그인 실패: idToken 없음"
                return
            }
            
            Task {
                await self?.requestServerAuth(idToken: idToken)
            }
        }
    }
    
    // 서버로 idToken 전송
    private func requestServerAuth(idToken: String) {
        AuthManager.shared.login(idToken: idToken, completion: { [weak self] loginData, signupRequired in
            DispatchQueue.main.async {
                if signupRequired {
                    self?.isSignupRequired = true
                } else if let data = loginData {
                    self?.userName = data.user?.name ?? "사용자"
                    self?.isLoginSuccess = true
                    
                    // 로그인 성공 후 목표 설정 온보딩 화면으로 이동하는 경우도 있어 일단 주석처리해두었습니다
//                    if let router = self?.rootRouter {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                            router.root = .main
//                            self?.objectWillChange.send()
//                        }
//                    }
                } else {
                    self?.errorMessage = "로그인 실패"
                }
                
                
            }
        })
    }
}
