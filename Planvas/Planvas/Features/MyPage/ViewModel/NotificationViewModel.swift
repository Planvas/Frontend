//
//  NotificationViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/10/26.
//

import Foundation
import Combine
import Moya

class NotificationViewModel {
    @Published var reminder: Bool = false
    @Published var complete: Bool = true
    
    private let provider = APIManager.shared.createProvider(for: NotificationsAPI.self)
    
    // MARK: - 알림 설정 조회
    func fetchReminderState() {
        provider.request(.getNotification) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(NotificationResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        self.reminder = decodedData.success!.dDayReminderEnabled
                        self.complete = decodedData.success!.activityCompleteReminderEnabled
                    }
                } catch {
                    print("GetNotifications 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("GetNotifications API 오류: \(error)")
            }
        }
    }
}
