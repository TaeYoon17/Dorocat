//
//  CatValue.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
enum CatType:String,CaseIterable,Identifiable,Codable{
    var id:String{self.rawValue}
    case doro,pomo,monet,muya
    func lottieAssetName(type:LottieAssetType)->String{
        let name = "\(self.rawValue)_\(type.rawValue)"
        return name
    }
    func imageAssetName(type: ImageType)->String{
        return "\(self.rawValue)_\(type.rawValue)"
    }
    var desc:String{
        switch self{
        case .monet: "Monet is a shy but loving cat who takes time to\nwarm up but then becomes very loyal."
        case .doro: "Doro is a calm and curious cat\nwho loves to sleep often!"
        case .muya: "Muya is an adventurous and independent cat\nwho likes to explore new places."
        case .pomo: "Pomo is a playful and energetic cat\nwho enjoys chasing after toys and climbing."
        }
    }
}
extension CatType{
    enum LottieAssetType:String{
        case basic
        case sleeping
        case done = "done"
    }
    enum ImageType:String{
        case icon = "appIcon"
        case mainLogo
        case thumbnailLogo
//        case thumbnailInActiveLogo
        case settingInfoLogo
        case onboardingIcon
    }
    // MARK: -- 에셋이 존재하는지 나타내는 가장 중요한 값
    var isAssetExist:Bool{
        switch self{
//        case .pomo,.monet,.muya: false
        default: true
        }
    }
}
