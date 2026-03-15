// Copyright 2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation

#if !os(Android) && !ROBOLECTRIC
public typealias AndroidBundle = Foundation.Bundle

public struct AndroidStringInterpolation: StringInterpolationProtocol, Equatable, @unchecked Sendable {
    public var pattern = ""
    public var values: [Any] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
    }

    public mutating func appendLiteral(_ literal: String) {
        pattern += literal.replacingOccurrences(of: "%", with: "%%")
    }

    public mutating func appendInterpolation(_ string: String) {
        pattern += "%@"
        values.append(string)
    }

    public mutating func appendInterpolation(_ substring: Substring) {
        appendInterpolation(String(substring))
    }

    public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: AnyObject {
        if let formatter {
            appendInterpolation(formatter.string(for: subject) ?? "nil")
        } else {
            appendInterpolation(String(describing: subject))
        }
    }

    public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: NSObject {
        if let formatter {
            appendInterpolation(formatter.string(for: subject) ?? "nil")
        } else {
            appendInterpolation(subject.description)
        }
    }

    public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        appendInterpolation(format.format(input))
    }

    @available(*, unavailable)
    public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
        fatalError()
    }

    public mutating func appendInterpolation<T>(_ value: T) {
        if T.self == Double.self {
            appendInterpolation(value, specifier: "%lf")
        } else if T.self == Float.self {
            appendInterpolation(value, specifier: "%f")
        } else if T.self == Int.self {
            appendInterpolation(value, specifier: "%lld")
        } else if T.self == Int8.self {
            appendInterpolation(value, specifier: "%d")
        } else if T.self == Int16.self {
            appendInterpolation(value, specifier: "%d")
        } else if T.self == Int32.self {
            appendInterpolation(value, specifier: "%d")
        } else if T.self == Int64.self {
            appendInterpolation(value, specifier: "%lld")
        } else if T.self == UInt.self {
            appendInterpolation(value, specifier: "%llu")
        } else if T.self == UInt8.self {
            appendInterpolation(value, specifier: "%u")
        } else if T.self == UInt16.self {
            appendInterpolation(value, specifier: "%u")
        } else if T.self == UInt32.self {
            appendInterpolation(value, specifier: "%u")
        } else if T.self == UInt64.self {
            appendInterpolation(value, specifier: "%llu")
        } else {
            appendInterpolation(String(describing: value))
        }
    }

    public mutating func appendInterpolation<T>(_ value: T, specifier: String) {
        pattern += specifier
        values.append(value)
    }

    @available(*, unavailable)
    public mutating func appendInterpolation(_ attributedString: AttributedString) {
        fatalError()
    }

    public typealias StringLiteralType = String

    public static func == (lhs: AndroidStringInterpolation, rhs: AndroidStringInterpolation) -> Bool {
        guard lhs.pattern == rhs.pattern, lhs.values.count == rhs.values.count else {
            return false
        }
        for pair in zip(lhs.values, rhs.values) {
            guard String(describing: pair.0) == String(describing: pair.1) else {
                return false
            }
        }
        return true
    }
}

public struct AndroidLocalizedStringResource: ExpressibleByStringInterpolation, Equatable, Sendable {
    public enum BundleDescription: Equatable, Codable, Sendable {
        case main
        case atURL(URL)

        static func from(bundle: Bundle) -> BundleDescription {
            if bundle.bundleURL == Bundle.main.bundleURL {
                return .main
            } else {
                return .atURL(bundle.bundleURL)
            }
        }
    }

    public init(_ key: StaticString, defaultValue: AndroidStringInterpolation? = nil, table: String? = nil, locale: Locale? = nil, bundle: BundleDescription? = nil, comment: StaticString? = nil) {
        self._key = key.description
        if let defaultValue {
            self.defaultValue = defaultValue
        } else {
            var defaultValue = AndroidStringInterpolation(literalCapacity: 0, interpolationCount: 0)
            defaultValue.appendLiteral(key.description)
            self.defaultValue = defaultValue
        }
        self.table = table
        self._locale = locale
        self._bundle = bundle
    }

    public init(_ key: StaticString, defaultValue: AndroidStringInterpolation, table: String? = nil, locale: Locale? = nil, bundle: AndroidBundle, comment: StaticString? = nil) {
        self.init(key, defaultValue: defaultValue, table: table, locale: locale, bundle: BundleDescription.from(bundle: bundle), comment: comment)
    }

    public init(_ keyAndValue: AndroidStringInterpolation, table: String? = nil, locale: Locale? = nil, bundle: BundleDescription? = nil, comment: StaticString? = nil) {
        self._key = nil
        self.defaultValue = keyAndValue
        self.table = table
        self._locale = locale
        self._bundle = bundle
    }

    public init(_ keyAndValue: AndroidStringInterpolation, table: String? = nil, locale: Locale? = nil, bundle: AndroidBundle, comment: StaticString? = nil) {
        self.init(keyAndValue, table: table, locale: locale, bundle: BundleDescription.from(bundle: bundle), comment: comment)
    }

    public init(stringLiteral: String) {
        self._key = nil
        var defaultValue = AndroidStringInterpolation(literalCapacity: 0, interpolationCount: 0)
        defaultValue.appendLiteral(stringLiteral)
        self.defaultValue = defaultValue
        self.table = nil
        self._bundle = nil
    }

    public typealias StringInterpolation = AndroidStringInterpolation

    public init(stringInterpolation: StringInterpolation) {
        self._key = nil
        self.defaultValue = stringInterpolation
        self.table = nil
        self._bundle = nil
    }

    public var key: String {
        _key ?? defaultValue.pattern
    }
    private let _key: String?

    public private(set) var defaultValue: AndroidStringInterpolation

    public let table: String?

    public var bundle: BundleDescription {
        _bundle ?? .main
    }
    private let _bundle: BundleDescription?

    public var locale: Locale {
        get { _locale ?? .current }
        set { _locale = newValue }
    }
    private var _locale: Locale?

    public var isDefaultBundle: Bool {
        _bundle == nil
    }

    public var isDefaultLocale: Bool {
        _locale == nil
    }

    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
}
#endif
