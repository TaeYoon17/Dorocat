//
//  FeedbackRepository.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation

final class FeedbackRepository: FeedbackProtocol {
    let feedbackService = FeedbackService()
    var isMailFeedbackAvailable: Bool { feedbackService.isMailFeedbackAvailable }
}
