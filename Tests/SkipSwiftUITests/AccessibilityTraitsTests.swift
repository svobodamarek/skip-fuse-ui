// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP
import XCTest
@testable import SkipSwiftUI

final class AccessibilityTraitsTests: XCTestCase {
    func testDefaultInitializerReturnsEmptyTraits() {
        XCTAssertEqual(AccessibilityTraits().rawValue, 0)
    }

    func testEmptyLiteralAndUnselectedControlReturnEmptyTraits() {
        let literal: AccessibilityTraits = []
        let selected = false
        let control: AccessibilityTraits = selected ? .isSelected : []
        XCTAssertEqual(literal.rawValue, 0)
        XCTAssertEqual(control.rawValue, 0)
    }

    func testTraitSetAlgebraPreservesExistingBits() {
        var traits: AccessibilityTraits = [.isButton, .isSelected]
        XCTAssertEqual(traits.rawValue, (1 << 0) | (1 << 2))
        traits.remove(.isSelected)
        XCTAssertEqual(traits, .isButton)
        XCTAssertEqual(traits.union(.isHeader).intersection(.isHeader), .isHeader)
        XCTAssertTrue(traits.intersection(.isSelected).isEmpty)
    }
}
#endif
