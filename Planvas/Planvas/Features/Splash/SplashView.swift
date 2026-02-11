import SwiftUI

// MARK: - Splash Data Model
struct SplashData: Identifiable {
    let id = UUID()
    let description: String
    let highlight: String
    let imageName: String?
    let subDescription: String?
    var isRollingPage: Bool = false
}

struct SplashView: View {
    @State private var currentPage = 0
    @AppStorage(OnboardingKeys.hasSeenOnboarding) var hasSeenOnboarding: Bool = false
    
    private let splashPages = [
        SplashData(
            description: "막연한 계획 때문에\n불안하지 않나요?",
            highlight: "막연한 계획",
            imageName: nil,
            subDescription: "학기, 방학, 시험 기간 등... \n\n상황은 매번 바뀌는데\n계획은 늘 '열심히' 라는 감에만\n의존해왔다면",
            isRollingPage: true
        ),
        SplashData(
            description: "나의 목표를 성장과 휴식의 비율로\n그려보는 것부터 시작하세요",
            highlight: "성장",
            imageName: "page2",
            subDescription: ""
        ),
        SplashData(
            description: "내 일정에 딱맞는 활동을 골라\n일상을 채우기만 하면 돼요!",
            highlight: "일정에 딱맞는",
            imageName: "page3",
            subDescription: ""
        )
    ]
    
    var body: some View {
        ZStack {
            Image("splashBackground")
                .ignoresSafeArea()
                .offset(y: -300)
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<splashPages.count, id: \.self) { index in
                        let page = splashPages[index]
                        SplashPageView(
                            description: page.description,
                            highlight: page.highlight,
                            imageName: page.imageName,
                            subDescription: page.subDescription,
                            isRollingPage: page.isRollingPage
                        )
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 40) {
                    HStack(spacing: 8) {
                        ForEach(0..<splashPages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.gray444 : Color.ccc)
                                .frame(width: currentPage == index ? 32 : 14, height: 8)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }){
                        Text("건너뛰기")
                            .textStyle(.bold20)
                            .foregroundStyle(Color.primary1)
                            .underline()
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}



#Preview {
    SplashView()
}
