//
//  FeedbackService.swift
//  Dorocat
//
//  Created by Greem on 5/5/25.
//

import Foundation
import MessageUI

struct FeedbackService {
    var isMailFeedbackAvailable: Bool { MFMailComposeViewController.canSendMail() }
}
