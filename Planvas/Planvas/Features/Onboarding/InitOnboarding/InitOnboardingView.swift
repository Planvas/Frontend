import SwiftUI

struct InitOnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                InitOnboardingPageView(
                    description: "막연한 계획 때문에 불안하지 않나요?",
                    highlight: "막연한 계획",
                    imageName: "page1")
                    .tag(0)
                InitOnboardingPageView(
                    description: "나만의 비율로 똑똑하게 채워가세요",
                    highlight: "나만의 비율",
                    imageName: "page2")
                    .tag(1)
            }
            .tabViewStyle(.page)
            
            VStack(spacing: 40) {
                HStack(spacing: 8) {
                    ForEach(0..<2) { index in
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
    InitOnboardingView()
}
