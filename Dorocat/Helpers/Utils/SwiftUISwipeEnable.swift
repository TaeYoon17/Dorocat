//
//  SwiftUISwipeEnable.swift
//  Dorocat
//
//  Created by Greem on 4/21/25.
//

import UIKit
import SwiftUI

/// NavigationHidden 처리에도 스와이프가 가능하게 해준다.
extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
