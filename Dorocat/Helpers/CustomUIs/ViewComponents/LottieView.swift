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
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.fileName = fileName
    }
    var fileName: String
    var loopMode: LottieLoopMode = .playOnce
    init(fileName: String, loopMode: LottieLoopMode) {
        self.fileName = fileName
        self.loopMode = loopMode
    }
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        context.coordinator.animationView = animationView
        context.coordinator.fileName = fileName
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
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
extension LottieView{
    final class Coordinator:NSObject{
        weak var animationView: LottieAnimationView!
        var fileName:String = ""{
            didSet{
                guard oldValue != fileName else {return}
                animationView.animation = LottieAnimation.named(fileName)
            }
        }
    }
}
