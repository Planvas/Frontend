//
//  CalendarSyncViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation
import GoogleSignIn
import UIKit
import Observation

@Observable
@MainActor
final class CalendarSyncViewModel {
    let calendarTitleText = "캘린더 연동으로"
    let highlightedText = "캘린더 연동"

    private(set) var isConnected = false
    private(set) var isLoadingStatus = false
    private(set) var isConnecting = false
    var statusError: String?

    /// 연동 성공 시 일정 선택 시트 노출 여부 (View는 이 값만 구독해 시트 표시)
    var shouldOpenScheduleSelection = false
    /// 토큰 없을 때 로그인 시트만 띄우기 위해 Flow에서 설정
    var onNeedLogin: (() -> Void)?

    func dismissScheduleSelection() {
        shouldOpenScheduleSelection = false
    }

    private let repository: CalendarRepositoryProtocol
    private static let calendarScope = "https://www.googleapis.com/auth/calendar.readonly"

    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarAPIRepository()
    }

    /// 연동 상태 로드 (View onAppear 등에서 호출). 로그인되지 않았으면 API 호출 없이 미연동으로 처리.
    func loadStatus() {
        guard TokenStore.shared.accessToken != nil else {
            isConnected = false
            statusError = nil
            return
        }
        isLoadingStatus = true
        statusError = nil
        Task {
            do {
                let status = try await repository.getGoogleCalendarStatus()
                isConnected = status.connected
            } catch {
                statusError = (error as? CalendarAPIError)?.reason ?? error.localizedDescription
            }
            isLoadingStatus = false
        }
    }

    /// "Google 캘린더 연동" 버튼 탭. 연동됐으면 일정 시트만 오픈. 연동 안 된 상태면 SDK로 auth code 받아 POST /api/integrations/google-calendar/connect 로 새로 연동.
    func performGoogleCalendarConnect() {
        statusError = nil
        guard TokenStore.shared.accessToken != nil else {
            statusError = "로그인이 필요합니다."
            onNeedLogin?()
            return
        }
        isConnecting = true
        Task {
            do {
                let status = try await repository.getGoogleCalendarStatus()
                isConnected = status.connected
                if status.connected {
                    isConnecting = false
                    shouldOpenScheduleSelection = true
                    return
                }
                // 연동 안 된 상태: SDK로 serverAuthCode 발급 → POST /api/integrations/google-calendar/connect { "code": "..." } 로 새 연동
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else {
                    isConnecting = false
                    statusError = "화면을 불러올 수 없습니다."
                    return
                }
                let config = GIDConfiguration(clientID: Config.ClientId, serverClientID: Config.ServerClientId)
                GIDSignIn.sharedInstance.configuration = config
                GIDSignIn.sharedInstance.signIn(withPresenting: rootVC, hint: nil, additionalScopes: [Self.calendarScope]) { [weak self] result, error in
                    Task { @MainActor in
                        guard let self else { return }
                        self.isConnecting = false
                        if let error = error {
                            self.statusError = error.localizedDescription
                            return
                        }
                        guard let code = result?.serverAuthCode, !code.isEmpty else {
                            self.statusError = "Google 인증 코드를 받지 못했습니다."
                            return
                        }
                        print("[CalendarSync] auth code 수신: \(code)")
                        await self.connectGoogleCalendar(code: code)
                    }
                }
                return
            } catch {
                isConnecting = false
                statusError = (error as? CalendarAPIError)?.reason ?? error.localizedDescription
            }
        }
    }

    /// serverAuthCode로 연동 (버튼 탭 시 내부에서 호출, 또는 외부에서 code 전달 시)
    func connectGoogleCalendar(code: String) async {
        do {
            try await repository.connectGoogleCalendar(code: code)
            let status = try await repository.getGoogleCalendarStatus()
            isConnected = status.connected
            statusError = nil
            if status.connected {
                shouldOpenScheduleSelection = true
            }
        } catch {
            statusError = (error as? CalendarAPIError)?.reason ?? error.localizedDescription
        }
    }
}

extension CalendarAPIError {
    var reason: String? {
        if case .serverFail(let reason) = self { return reason }
        return nil
    }
}
