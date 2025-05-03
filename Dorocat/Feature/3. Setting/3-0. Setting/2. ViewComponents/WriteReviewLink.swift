//
//  WriteReviewLink.swift
//  Dorocat
//
//  Created by Developer on 6/18/24.
//


import SwiftUI
import DoroDesignSystem

extension SettingViewComponents{
    struct WriteReviewLink: View {
        @Environment(\.openURL) private var openURL
        let title:String
        var description: String? = nil
        var body: some View {
            Button(action: requestReviewManually) {
                HStack(content: {
                    VStack {
                        Text(title).font(.paragraph02()).foregroundStyle(Color.doroWhite).fontCoordinator()
                        if let description{
                            Text(description)
                                .font(.paragraph04)
                                .foregroundStyle(Color.grey02)
                                .fontCoordinator().fontCoordinator()
                        }
                    }
                    Spacer()
                    Image(.disclosure).resizable().frame(width: 12,height: 12)
                        .padding(.trailing,21)
                })
                .frame(height: 68)
                .padding(.leading,23)
                .background(Color.grey03)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        
        /// - Tag: ManualReviewRequest
        private func requestReviewManually() {
            // Replace the placeholder value below with the App Store ID for your app.
            // You can find the App Store ID in your app's product URL.
            let url = "https://apps.apple.com/app/id6480333786?action=write-review"
            
            guard let writeReviewURL = URL(string: url) else {
                fatalError("Expected a valid URL")
            }
            
            openURL(writeReviewURL)
        }
    }
}
