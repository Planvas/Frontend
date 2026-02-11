//
//  NotificationViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/10/26.
//

import Foundation
import Combine
import Moya

@Observable
class NotificationViewModel {
    var reminder: Bool = true
    var complete: Bool = true
    
    private let provider = APIManager.shared.createProvider(for: NotificationsAPI.self)
    
    // MARK: - 알림 설정 조회
    func fetchReminderState() {
        provider.request(.getNotification) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(NotificationResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if let success = decodedData.success {
                            self.reminder = success.dDayReminderEnabled
                            self.complete = success.activityCompleteReminderEnabled
                        }
                    }
                } catch {
                    print("GetNotifications 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("GetNotifications API 오류: \(error)")
            }
        }
    }
    
    // MARK: - 알림 설정 변경
    func fetchReminderSetting() {
        let dto = NotificationSettingRequestDTO(
            dDayReminderEnabled: reminder,
            activityCompleteReminderEnabled: complete
        )
        provider.request(.patchNotification(NotificationSettingRequestDTO: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(NotificationResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if let success = decodedData.success {
                            self.reminder = success.dDayReminderEnabled
                            self.complete = success.activityCompleteReminderEnabled
                        }
                    }
                } catch {
                    print("Notifications 세팅 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("Notifications 세팅 API 오류: \(error)")
            }
        }
    }
}
