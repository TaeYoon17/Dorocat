//
//  CatValue.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
enum CatType:String,CaseIterable,Identifiable,Codable{
    var id:String{self.rawValue}
    case doro,bbang,ace,greem
    func lottieAssetName(type:LottieAssetType)->String{
        let name = "\(self.rawValue)_\(type.rawValue)"
        return name
    }
    func imageAssetName(type: ImageType)->String{
        return "\(self.rawValue)_\(type.rawValue)"
    }
    var desc:String{
        switch self{
        case .bbang: "Bbang is a calm and curious cat\nwho loves to sleep often!"
        case .doro: "Doro is a calm and curious cat\nwho loves to sleep often!"
        case .ace: "Ace is a calm and curious cat\nwho loves to sleep often!"
        case .greem: "Greem is a calm and curious cat\nwho loves to sleep often!"
        }
    }
}
extension CatType{
    enum LottieAssetType:String{
        case basic
        case sleeping
        case done
        case great
    }
    enum ImageType:String{
        case mainLogo
        case thumbnailLogo
        case thumbnailInActiveLogo
        case settingInfoLogo
        case onboardingIcon
    }
    // MARK: -- 에셋이 존재하는지 나타내는 가장 중요한 값
    var isAssetExist:Bool{
        switch self{
        case .bbang,.ace,.greem: false
        default: true
        }
    }
}
