// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SkipBridge

/// Preserve value equality or reference identity without reading object fields.
/// Functions and other uncomparable values deliberately receive no token.
func Java_environmentEquality<Value>(for value: Value) -> SwiftEquatable? {
    if let equatable = value as? any Equatable {
        return SwiftEquatable(equatable)
    }
    if Value.self is AnyObject.Type {
        return SwiftEquatable(ObjectIdentifier(value as AnyObject))
    }
    return nil
}
