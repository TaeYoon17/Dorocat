//
//  FeedbackDependency.swift
//  Dorocat
//
//  Created by Developer on 6/3/24.
//

import Foundation
import ComposableArchitecture
import MessageUI

protocol FeedbackProtocol{
    var isMailFeedbackAvailable:Bool{ get }
}
final class FeedbackClient:FeedbackProtocol {
    static let shared = FeedbackClient()
    var isMailFeedbackAvailable: Bool{ MFMailComposeViewController.canSendMail() }
    private init(){}
}
fileprivate enum FeedbackClientKey: DependencyKey {
    static let liveValue: FeedbackProtocol = FeedbackClient.shared
}
extension DependencyValues{
    var feedback: FeedbackProtocol{
        get{self[FeedbackClientKey.self]}
        set{self[FeedbackClientKey.self] = newValue}
    }
}
