// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP
import XCTest
@testable import SkipSwiftUI

final class EnvironmentValueEqualityTests: XCTestCase {
    private final class Reference {}
    private final class Port: Equatable {
        static func == (lhs: Port, rhs: Port) -> Bool { lhs === rhs }
    }

    func testReboxedEqualValuesRetainNativeEquality() {
        XCTAssertEqual(Java_environmentEquality(for: ["one", "two"]), Java_environmentEquality(for: ["one", "two"]))
        XCTAssertNotEqual(Java_environmentEquality(for: ["one"]), Java_environmentEquality(for: ["two"]))
    }

    func testReferenceAndOptionalPortKeepTheirIdentity() {
        let reference = Reference()
        XCTAssertEqual(Java_environmentEquality(for: reference), Java_environmentEquality(for: reference))
        XCTAssertNotEqual(Java_environmentEquality(for: reference), Java_environmentEquality(for: Reference()))
        let port: Port? = Port()
        XCTAssertEqual(Java_environmentEquality(for: port), Java_environmentEquality(for: port))
        XCTAssertNotEqual(Java_environmentEquality(for: port), Java_environmentEquality(for: Optional(Port())))
    }

    func testNilAndWrappedValuesKeepTheirType() {
        let nilValue: Int? = nil
        XCTAssertEqual(Java_environmentEquality(for: nilValue), Java_environmentEquality(for: nilValue))
        XCTAssertNotEqual(Java_environmentEquality(for: nilValue), Java_environmentEquality(for: Optional(1)))
        let token = Java_environmentEquality(for: 7)!
        let wrapped = Java_environmentEquality(for: token)!
        XCTAssertTrue((wrapped.value as? AnyObject) === token)
    }

    func testClosuresRemainUncomparable() {
        XCTAssertNil(Java_environmentEquality(for: { () -> Void in }))
    }
}
#endif
