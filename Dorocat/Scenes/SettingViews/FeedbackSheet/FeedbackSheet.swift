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
    @Dependency(\.dismiss) var dismiss
    enum Action:Equatable{
        case delegate
        case close
    }
    var body: some ReducerOf<Self>{
        Reduce{ state, action in
            switch action{
            case .delegate: return .none
            case .close:
                return .run { send in
                    await dismiss()
                }
            }
        }
    }
}
struct FeedbackSheet: UIViewControllerRepresentable {
    @Bindable var store:StoreOf<FeedbackFeature>
    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composeVC = MFMailComposeViewController()
        composeVC.navigationBar.tintColor = .doroWhite
        composeVC.toolbar.tintColor = .doroWhite
        context.coordinator.vc = composeVC
        composeVC.mailComposeDelegate = context.coordinator
        return composeVC
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }
}
extension FeedbackSheet{
    final class Coordinator:NSObject,MFMailComposeViewControllerDelegate{
        let store:StoreOf<FeedbackFeature>
        weak var vc: MFMailComposeViewController!{
            didSet{
                guard let vc else {return}
                setContent()
            }
        }
        init(store:StoreOf<FeedbackFeature>){
            self.store = store
            super.init()
        }
        func setContent(){
            vc.setSubject("Feedback Dorocat")
            vc.setToRecipients(["dorocat.app@gmail.com"])
            vc.setMessageBody("Hello world", isHTML: false)
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
            // Check the result or perform other tasks.
            print(#function)
            // Dismiss the mail compose view controller.
            controller.dismiss(animated: true){[weak self] in
                print("완전한 종료...")
                self?.store.send(.close)
            }
        }
    }
}
