//
//  Font.swift
//  Planvas
//
//  Created by 정서영 on 1/15/26.
//

import SwiftUI

extension Font {
    enum Pretend {
        case extrabold
        case bold
        case semibold
        case medium
        case regular
        
        var value: String {
            switch self {
            case .extrabold:
                return "Pretendard-ExtraBold"
            case .bold:
                return "Pretendard-Bold"
            case .semibold:
                return "Pretendard-SemiBold"
            case .medium:
                return "Pretendard-Medium"
            case .regular:
                return "Pretendard-Regular"
            }
        }
    }
    
    static func pretend(type: Pretend, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
}

struct TextStyle: ViewModifier {
    let weight: Font.Pretend
    let size: CGFloat
    let letterSpacing: CGFloat?
    
    private var font: Font {
        .pretend(type: weight, size: size)
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .kerning(letterSpacing ?? size * 0.01)
            .lineSpacing(size * 0.1)
    }
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        modifier(style)
    }
}

extension TextStyle {
    // extrabold
    static let extrabold45 = TextStyle(
        weight: .extrabold,
        size: 45,
        letterSpacing: nil
    )
    
    // bold
    static let bold30 = TextStyle(
        weight: .bold,
        size: 30,
        letterSpacing: nil
    )
    
    static let bold25 = TextStyle(
        weight: .bold,
        size: 25,
        letterSpacing: nil
    )
    
    static let bold22 = TextStyle(
        weight: .bold,
        size: 22,
        letterSpacing: nil
    )
    
    static let bold20 = TextStyle(
        weight: .bold,
        size: 20,
        letterSpacing: nil
    )
    
    static let bold14 = TextStyle(
        weight: .bold,
        size: 14,
        letterSpacing: nil
    )
    
    static let bold12_5 = TextStyle(
        weight: .bold,
        size: 12.5,
        letterSpacing: nil
    )
    
    // semibold
    static let semibold30 = TextStyle(
        weight: .semibold,
        size: 30,
        letterSpacing: nil
    )
    
    static let semibold25 = TextStyle(
        weight: .semibold,
        size: 25,
        letterSpacing: nil
    )
    
    static let semibold20 = TextStyle(
        weight: .semibold,
        size: 20,
        letterSpacing: nil
    )
    
    static let semibold18 = TextStyle(
        weight: .semibold,
        size: 18,
        letterSpacing: 18 * (-0.02)
    )
    
    static let semibold16 = TextStyle(
        weight: .semibold,
        size: 16,
        letterSpacing: nil
    )
    
    static let semibold14 = TextStyle(
        weight: .semibold,
        size: 14,
        letterSpacing: nil
    )
    
    static let semibold14spacing = TextStyle(
        weight: .semibold,
        size: 14,
        letterSpacing: 14 * (-0.05)
    )
    
    static let semibold22 = TextStyle(
        weight: .semibold,
        size: 22,
        letterSpacing: nil
    )
    
    // medium
    static let medium58 = TextStyle(
        weight: .medium,
        size: 58,
        letterSpacing: nil
    )
    
    static let medium20 = TextStyle(
        weight: .medium,
        size: 20,
        letterSpacing: nil
    )
    
    static let medium18 = TextStyle(
        weight: .medium,
        size: 18,
        letterSpacing: nil
    )
    
    static let medium16 = TextStyle(
        weight: .medium,
        size: 16,
        letterSpacing: nil
    )
    
    static let medium15 = TextStyle(
        weight: .medium,
        size: 15,
        letterSpacing: 15 * (-0.05)
    )
    
    static let medium14 = TextStyle(
        weight: .medium,
        size: 14,
        letterSpacing: nil
    )
    
    static let medium10 = TextStyle(
        weight: .medium,
        size: 10,
        letterSpacing: 10 * (-0.02)
    )
    
    // regular
    static let regular18 = TextStyle(
        weight: .regular,
        size: 18,
        letterSpacing: 18 * (-0.02)
    )
    
    static let regular14 = TextStyle(
        weight: .regular,
        size: 14,
        letterSpacing: nil
    )
    
    static let regular14spacing = TextStyle(
        weight: .regular,
        size: 14,
        letterSpacing: 14 * (-0.02)
    )
}

//캘린더 연동 뷰에서 사용합니다!
extension TextStyle {
    var swiftUIFont: Font {
        .pretend(type: weight, size: size)
    }
}

