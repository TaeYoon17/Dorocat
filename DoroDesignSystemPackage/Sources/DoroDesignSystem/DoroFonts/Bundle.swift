//
//  File.swift
//  DoroDesignSystem
//
//  Created by Greem on 10/8/24.
//

import Foundation

public extension Bundle {
    // 현재 파일의 폴더 URL 정보를 번들로 불러오기 위해서 만든 임시 객체
    private class CurrentBundleFinder {}

    /// This is used to allow you to use resources from DesignSystem in other Swift Package previews.

    @MainActor static var designSystem: Bundle = {
        // The name of your local package bundle. This may change on every different version of Xcode.
        /// 로컬 패키지의 번들 이름은 Xcode 버전별로 다르다.
        /// iOS에서는 "LocalPackages_<ModuleName>"로 명명되어진다.
        /// 아래는 iOS 버전에서 표현되는 패키지 번들을 찾는 코드이다.
        /// Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent()
         
        let bundleNameIOS = "DoroDesignSystem_DoroDesignSystem"
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            /// 
            Bundle.main.resourceURL,
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: CurrentBundleFinder.self).resourceURL,
            // For command-line tools.
            Bundle.main.bundleURL,
            // Bundle should be present here when running previews from a different package
            // (this is the path to "…/Debug-iphonesimulator/").
            Bundle(for: CurrentBundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
            // iOS 앱에 대응하기 위함
            Bundle(for: CurrentBundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
        ]

        for candidate in candidates {
            let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")
            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
                print(bundle)
                return bundle
            }
        }
        fatalError("Can't find designSystem custom bundle. See Bundle+Extensions.swift")
    }()
}
