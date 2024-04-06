//
//  NumberPickerView.swift
//  Dorocat
//
//  Created by Developer on 3/16/24.
//

import SwiftUI
import UIKit

struct NumberPickerView: UIViewRepresentable{
    typealias UIViewType = UIPickerView
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    func makeUIView(context: Context) -> UIPickerView {
        let view = UIPickerView()
        return view
    }
    func updateUIView(_ uiView: UIPickerView, context: Context) { }
}
extension NumberPickerView{
    final class Coodrinator: NSObject{
        override init() {
            super.init()
        }
    }
}
