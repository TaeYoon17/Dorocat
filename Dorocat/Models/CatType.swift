//
//  CatValue.swift
//  Dorocat
//
//  Created by Developer on 5/31/24.
//

import Foundation
enum CatType:String,CaseIterable,Identifiable{
    var id:String{self.rawValue}
    case doro,bbang,gilah,greem
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
        case .gilah: "Gilah is a calm and curious cat\nwho loves to sleep often!"
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
}
