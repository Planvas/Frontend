import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .textStyle(.medium14)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .multilineTextAlignment(.center)
            .background(Color.black.opacity(0.8))
            .cornerRadius(25)
            .shadow(radius: 10)
            .frame(maxWidth: 400)
    }
}
