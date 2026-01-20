//
//  LoginViewModel.swift
//  Planvas
//
//  Created by 송민교 on 1/20/26.
//
import Foundation
import GoogleSignIn
import Combine
import UIKit

class LoginViewModel: ObservableObject {
    @Published var isLoginSuccess = false
    @Published var isSignupRequired = false
    @Published var userName: String = ""
    @Published var errorMessage: String? = nil
    
    @MainActor
    func GoogleLogin() {
        // SwiftUI에서는 현재 뷰의 UIViewController를 찾아와야 구글 로그인창이 뜸
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] GIDSignInResult, error in
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
            
            print("idToken:\(idToken)")
            
            Task {
                await self?.requestServerAuth(idToken: idToken)
            }
        }
    }
    
    private func requestServerAuth(idToken: String) {
        AuthManager.shared.login(idToken: idToken, completion: { [weak self] loginData, signupRequired in
            DispatchQueue.main.async {
                if signupRequired {
                    self?.isSignupRequired = true
                } else if let data = loginData {
                    self?.userName = data.user?.name ?? "사용자"
                    self?.isLoginSuccess = true
                } else {
                    self?.errorMessage = "로그인 실패"
                }
            }
        })
    }
}
