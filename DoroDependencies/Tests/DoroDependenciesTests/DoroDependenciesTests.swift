import XCTest
@testable import NotificationDependency
final class DoroDependenciesTests: XCTestCase {
//    @Dependency(\.pomoNotification) var pomoNoti
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
        let testBundle = Bundle(for: type(of: self))
        print(testBundle)
        let notiCenter = UNUserNotificationCenter.current()
        Task{@MainActor in
            var client = PomoNotificationClient()
//            client.isEnable = true
            await client.setEnable(true)
        }
        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}
