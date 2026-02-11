import SwiftUI

// MARK: - 설명글 스타일링 함수
func styledSubDescription(_ text: String) -> AttributedString {
    var attributedString = AttributedString(text)
    
    let purpleHighLights = ["계획", "늘", "'열심히'", "라는", "감에만", "의존"]
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
            Spacer()
            VStack(alignment: .center) {
                Text(attributedTitle)
                    .textStyle(.semibold25)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                Spacer()
            }
            .frame(height: 200)
            
            VStack {
                if isRollingPage {
                    RollingIconView()
                    Spacer()
                }
                else if let name = imageName {
                    Spacer()
                    Image(name)
                        .resizable()
                        .frame(width: 180, height: 400)
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                }
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
            let singleSetWidth: CGFloat = CGFloat(icons.count) * 130 + CGFloat(icons.count - 1) * 40
            HStack(spacing: 40) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 40) {
                        ForEach(icons, id: \.self) { name in
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 240)
                        }
                    }
                }
            }
            .offset(x: xOffset)
            .onAppear {
                withAnimation(
                    .linear(duration: 10)
                    .repeatForever(autoreverses: false)) {
                    xOffset = -(singleSetWidth + 40) // 한세트폭 + 세트 간 spacing
                }
            }
        }
        .frame(height: 200)
    }
}
