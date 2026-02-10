//
//  CalendarSyncViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation
import Combine

@MainActor
class CalendarSyncViewModel: ObservableObject {
    let calendarTitleText = "캘린더 연동으로"
    let highlightedText = "캘린더 연동"

    @Published private(set) var isConnected = false
    @Published private(set) var isLoadingStatus = false
    @Published private(set) var isConnecting = false
    @Published var statusError: String?

    /// 이미 연동된 경우: 일정 선택 시트 노출 등
    var onConnectSuccess: (() -> Void)?
    /// 미연동 시: 로그인 필요 (Login 모듈에서 처리할 수 있도록 콜백)
    var onNeedGoogleLogin: (() -> Void)?

    private let repository: CalendarRepositoryProtocol

    init(repository: CalendarRepositoryProtocol? = nil) {
        self.repository = repository ?? CalendarAPIRepository()
    }

    /// 연동 상태 로드 (View onAppear 등에서 호출)
    func loadStatus() {
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

    /// "Google 캘린더 연동" 버튼 탭: 연동 여부만 확인. 이미 연동됐으면 시트 오픈, 아니면 로그인 필요 콜백 (GIDSignIn 호출 없음)
    func performGoogleCalendarConnect() {
        statusError = nil
        isConnecting = true
        Task {
            defer { isConnecting = false }
            do {
                let status = try await repository.getGoogleCalendarStatus()
                isConnected = status.connected
                if status.connected {
                    onConnectSuccess?()
                } else {
                    statusError = "Google 로그인이 필요합니다."
                    onNeedGoogleLogin?()
                }
            } catch {
                statusError = (error as? CalendarAPIError)?.reason ?? error.localizedDescription
            }
        }
    }

    /// 로그인 모듈 등에서 serverAuthCode 전달받았을 때 호출 (POST connect)
    func connectGoogleCalendar(code: String) async {
        do {
            try await repository.connectGoogleCalendar(code: code)
            let status = try await repository.getGoogleCalendarStatus()
            isConnected = status.connected
            statusError = nil
            if status.connected {
                onConnectSuccess?()
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
