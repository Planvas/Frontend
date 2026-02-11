import Foundation
import Combine
import Moya

final class DIContainer: ObservableObject {
    // MARK: - Global States
    let appState: AppState

    // MARK: - Router
    let rootRouter: RootRouter

    // MARK: - Network
    let apiManager: APIManager
    let calendarProvider: MoyaProvider<CalendarAPI>
    let onboardingProvider: MoyaProvider<OnboardingAPI>
    
    // MARK: - viewModel
    let loginVM: LoginViewModel
    let goalVM: GoalSetupViewModel
    let onboardingVM: OnboardingViewModel
    
    init() {
        self.appState = AppState()
        self.rootRouter = RootRouter(appState: appState)
        
        self.apiManager = APIManager.shared
        self.calendarProvider = apiManager.createProvider(for: CalendarAPI.self)
        self.onboardingProvider = apiManager.createProvider(for: OnboardingAPI.self)
        
        self.loginVM = LoginViewModel()
        self.loginVM.rootRouter = self.rootRouter
        self.goalVM = GoalSetupViewModel()
        self.onboardingVM = OnboardingViewModel(provider: onboardingProvider)
    }
}
