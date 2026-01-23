import SwiftUI

struct InitOnboardingPageView : View {
    let description: String
    let highlight: String
    let imageName: String
    
    // MARK: - 문자열 + 스타일 AttributedString 생성
    var attributedTitle: AttributedString {
        var attributedString = AttributedString(description)
        
        if let range = attributedString.range(of: highlight) {
            attributedString[range].foregroundColor = .primary1
        }
        
        return attributedString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(attributedTitle)
                .textStyle(.semibold30)
                .padding(.top, 80)
                .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 120)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
