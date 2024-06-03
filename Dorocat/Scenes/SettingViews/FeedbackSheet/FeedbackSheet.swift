//
//  FeedbackSheet.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import SwiftUI
import MessageUI
import ComposableArchitecture
@Reducer
struct FeedbackFeature{
    @ObservableState struct State: Equatable{}
    enum Action:Equatable{
        case delegate
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            }
        }
    }
}
struct FeedbackSheet: UIViewControllerRepresentable {
    let store:StoreOf<FeedbackFeature>
    func makeCoordinator() -> Coordinator {
        
    }
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composeVC = MFMailComposeViewController()
        composeVC.navigationBar.tintColor = .doroWhite
        composeVC.toolbar.tintColor = .doroWhite
        return composeVC
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }
}
