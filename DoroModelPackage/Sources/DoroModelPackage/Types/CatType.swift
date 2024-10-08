// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public enum CatType:String,CaseIterable,Identifiable,Codable{
    public var id:String{self.rawValue}
    case doro,pomo,monet,muya
}
public extension CatType{
    enum LottieAssetType:String{
        case basic
        case sleeping
        case done = "done"
    }
    enum ImageType:String{
        case icon = "appIcon"
        case mainLogo
        case thumbnailLogo
        case settingInfoLogo
        case onboardingIcon
    }
}
