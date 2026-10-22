// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SkipBridge
import SkipUI

public protocol PreferenceKey {
    associatedtype Value

    static var defaultValue: Self.Value { get }

    static func reduce(value: inout Self.Value, nextValue: () -> Self.Value)
}

extension PreferenceKey where Self.Value : ExpressibleByNilLiteral {
    public static var defaultValue: Self.Value {
        return nil
    }
}

extension View {
    /* @inlinable */ nonisolated public func preference<K>(key: K.Type = K.self, value: K.Value) -> some View where K : PreferenceKey {
        return ModifierView(target: self) {
            let javaKey = String(describing: key)
            let ptr = SwiftObjectPointer.pointer(to: Box(value), retain: true)
            let javaValue = EnvironmentSupport(valueHolder: ptr)
            return $0.Java_viewOrEmpty.preference(key: javaKey, value: javaValue)
        }
    }

    /* @inlinable */ nonisolated public func onPreferenceChange<K>(_ key: K.Type = K.self, perform action: @escaping (K.Value) -> Void) -> some View where K : PreferenceKey, K.Value : Equatable {
        return ModifierView(target: self) {
            // Contributions retain opaque native holders. Reduced values use
            // the existing equatable bridge so Compose can manage both their
            // lifecycles and change observation before returning native values.
            let javaKey = String(describing: key)
            // Reduced values must retain their native equality at the
            // snapshotFlow/distinctUntilChanged boundary. Opaque environment
            // holders compare by identity and would notify again for equal values.
            let javaDefaultValue = SwiftEquatable(key.defaultValue)
            let javaReducer: (Any?, Any?) -> Any? = { value, nextValue in
                let reducedValue = value as! SwiftEquatable
                let envNextValue = nextValue as! EnvironmentSupport
                let boxNextValue: Box<K.Value> = envNextValue.valueHolder.pointee()!
                var swiftValue = reducedValue.value as! K.Value
                let swiftNextValue = boxNextValue.value
                key.reduce(value: &swiftValue, nextValue: { swiftNextValue })
                return SwiftEquatable(swiftValue)
            }
            let javaAction: (Any?) -> Void = { value in
                let reducedValue = value as! SwiftEquatable
                action(reducedValue.value as! K.Value)
            }
            return $0.Java_viewOrEmpty.onPreferenceChange(key: javaKey, defaultValue: javaDefaultValue, reducer: javaReducer, action: javaAction)
        }
    }
}
