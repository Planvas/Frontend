//
//  Bounce.swift
//  Planvas
//
//  Created by 정서영 on 2/18/26.
//

import SwiftUI

struct DisableScrollBounce: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        DispatchQueue.main.async {
            if let scrollView = view.enclosingScrollView() {
                scrollView.bounces = false
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

private extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        sequence(first: self.superview, next: { $0?.superview })
            .first { $0 is UIScrollView } as? UIScrollView
    }
}
