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
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    private let splashPages = [
        SplashData(
            description: "막연한 계획 때문에 불안하지 않나요?",
            highlight: "막연한 계획",
            imageName: nil,
            subDescription: "학기, 방학, 시험 기간 등... \n\n상황은 매번 바뀌는데 계획은\n늘 '열심히'라는 감에만 의존해왔다면",
            isRollingPage: true
        ),
        SplashData(
            description: "바라는 모습대로 기준점을 세우세요.",
            highlight: "바라는 모습",
            imageName: "page2",
            subDescription: "나의 목표를 성장과 휴식의 균형으로\n그려보는 것부터 시작하세요."
        ),
        SplashData(
            description: "똑똑하게 일상을 채우고 바라는 나에 가까워져요.",
            highlight: "똑똑하게",
            imageName: "page3",
            subDescription: "내 일정에 딱맞는 활동을 골라\n내가 정한 비율대로 일상을 채우기만 하면 돼요!"
        )
    ]
    
    var body: some View {
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
                    ForEach(0..<3) { index in
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

#Preview {
    SplashView()
}
