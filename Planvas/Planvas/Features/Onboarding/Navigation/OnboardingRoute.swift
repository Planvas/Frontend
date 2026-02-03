//
//  OnboardingRoute.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import Foundation

enum OnboardingRoute {
    case onboardingSplash // 온보딩 스플래시 첫화면
    case onboardingSplashSuccess // 온보딩 스플래시 두번째 화면
    case info   // 목표 이름, 기간 설정
    case ratio  // 목표 비율 설정
    case recommendation    // 유형별 비율 추천 선택
    case interest   // 관심 분야 선택
    case mainPage    // 메인 페이지
}
