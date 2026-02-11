//
//  GoogleCalendarStatus.swift
//  Planvas
//
//  Created by 백지은 on 2/5/26.
//


//  도메인: 구글 캘린더 연동 상태 (Repository가 반환, ViewModel이 사용)


import Foundation

struct GoogleCalendarStatus {
    let connected: Bool
    let connectedAt: Date?
    let lastSyncedAt: Date?
}
