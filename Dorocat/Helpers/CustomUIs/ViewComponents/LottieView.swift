//
//  LottieView.swift
//  Dorocat
//
//  Created by Developer on 4/15/24.
//

import SwiftUI

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable{
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    let fileName: String
    var loopMode: LottieLoopMode = .playOnce
    init(fileName: String, loopMode: LottieLoopMode) {
        self.fileName = fileName
        self.loopMode = loopMode
    }
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(fileName)
        animationView.loopMode = loopMode
        animationView.play()
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view
    }
}
