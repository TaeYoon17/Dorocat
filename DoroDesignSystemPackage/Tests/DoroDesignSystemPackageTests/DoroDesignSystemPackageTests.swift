import Testing
@testable import DoroDesignSystem
import SwiftUI

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    await CustomFonts.registerCustomFonts()
}

