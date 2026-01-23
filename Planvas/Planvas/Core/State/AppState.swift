//
//  AppState.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
