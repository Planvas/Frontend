import SwiftUI

// MARK: - 설명글 스타일링 함수
func styledSubDescription(_ text: String) -> AttributedString {
    var attributedString = AttributedString(text)
    
    let purpleHighLights = ["계획", "감에만 의존", "성장", "휴식", "균형", "일정에 딱맞는"]
    let grayHighLight:String = "학기, 방학, 시험 기간 등..."
    
    for word in purpleHighLights {
        if let range = attributedString.range(of: word) {
            attributedString[range].foregroundColor = .primary1
        }
    }
    
    if let range = attributedString.range(of: grayHighLight) {
        attributedString[range].foregroundColor = Color(.gray444)
    }
    
    return attributedString
}

// MARK: - 뷰 컴포넌트
struct SplashPageView : View {
    let description: String
    let highlight: String
    let imageName: String?
    
    var subDescription: String? = nil
    var isRollingPage: Bool = false
    
    // MARK: - 문자열 + 스타일 AttributedString 생성
    var attributedTitle: AttributedString {
        var attributedString = AttributedString(description)
        
        if let range = attributedString.range(of: highlight) {
            attributedString[range].foregroundColor = .primary1
        }
        
        return attributedString
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(attributedTitle)
                    .textStyle(.semibold30)
                    .padding(.horizontal, 24)
                Spacer()
            }
            .frame(height: 200)
            
            VStack {
                Spacer()
                if isRollingPage {
                    RollingIconView()
                }
                else if let name = imageName {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                        .padding(.horizontal, 40)
                }
                Spacer()
            }
            .frame(height: 250)
            
            VStack {
                if let subText = subDescription {
                    Text(styledSubDescription(subText))
                        .multilineTextAlignment(.center)
                        .textStyle(.medium18)
                }
            }
            .frame(height: 120)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 옆으로 흐르는 아이콘 뷰
struct RollingIconView: View {
    let icons = ["sun", "calendar", "alarm", "flight"]
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 40) {
                ForEach(0..<2) { _ in
                    HStack(spacing: 40) {
                        ForEach(icons, id: \.self) { name in
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 180)
                                .fixedSize()
                        }
                    }
                }
            }
            .offset(x: xOffset)
            .onAppear {
                withAnimation(
                    .linear(duration: 10)
                    .repeatForever(autoreverses: false)) {
                    xOffset = -(geo.size.width)
                }
            }
        }
        .frame(height: 200)
    }
}
