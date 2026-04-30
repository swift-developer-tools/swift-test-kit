//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

//  MARK: - RenderedValueKind

/// The kind of a rendered value.
package enum RenderedValueKind: Equatable, Sendable
{
    /// A string or character value.
    ///
    /// The formatter wraps the description of a string in double quotes.
    case string
    
    /// Any other value.
    ///
    /// The formatter renders the description as-is.
    case other
}



// MARK: - RenderedValue

/// A pre-rendered value.
package struct RenderedValue: Equatable, Sendable, CustomStringConvertible
{
    /// The string representation of the value.
    ///
    /// For strings, this is the string content with special characters
    /// escaped (`\n`, `\t`, `\r`, `\0`, `\\`), but without surrounding quotes.
    /// Quoting is handled by the formatter.
    package let description : String
    
    /// The name of the value's type.
    ///
    /// This uses the full generic signature (for example, `Array<String>`).
    package let typeName    : String
    
    /// The kind of value, used to determine the formatting behavior.
    package let kind        : RenderedValueKind
    
    
    
    /// Initializes a ``RenderedValue`` instance from the given value.
    /// - Parameter value: The value to use.
    package init(
        _ value: Any
    )
    {
        let unwrapped: Any = (value as? AnyHashable)?.base ?? value
        
        self.typeName = String(describing: type(of: unwrapped))
        
        if Self.isStringLike(unwrapped)
        {
            self.description    = String(describing: unwrapped).escaped
            self.kind           = .string
        }
        else if let convertible = unwrapped as? CustomDiffStringConvertible
        {
            self.description    = convertible.diffDescription.collapseLines()
            self.kind           = .other
        }
        else if
            let rawRepresentable = unwrapped as? any RawRepresentable,
            Comparator.isRawRepresentableLeaf(unwrapped)
        {
            let rawValue: Any = rawRepresentable.rawValue
            
            if Self.isStringLike(rawValue)
            {
                self.description    = String(describing: rawValue).escaped
                self.kind           = .string
            }
            else
            {
                self.description    = String(describing: rawValue).collapseLines()
                self.kind           = .other
            }
        }
        else
        {
            /// The string description of most Swift types is a single line,
            /// but a `CustomStringConvertible` type might include newlines
            /// that would break the line-based output of ``Formatter``.
            ///
            /// Replace newlines with a single space. Another approach is to
            /// replace all consecutive whitespace sequences with a single
            /// space, but that would affect spaces inside string property
            /// values, not just structural whitespace.
            self.description    = String(describing: unwrapped).collapseLines()
            self.kind           = .other
        }
    }
    
    
    
    /// Checks whether the given value is string-like.
    /// - Parameter value: The value to check.
    /// - Returns: Whether the given value is string-like.
    private static func isStringLike(
        _ value: Any
    ) -> Bool
    {
        /// `NSString` is bridged to `String`.
        return value is String
            || value is Substring
            || value is Character
            || value is Unicode.Scalar
    }
}



// MARK: - DiffValue

/// A value captured during diff computation.
///
/// This stores both the underlying value and its pre-rendered representation
/// in a diff node, allowing for a single rendering location. The comparator is
/// responsible for all value inspection and rendering, and the formatter works
/// with only pre-rendered data. The formatter can therefore focus only on
/// layout issues like indentation, alignment, and truncation.
///
/// Storing only the underlying value with lightweight metadata (type name,
/// kind, etc.) would split the rendering logic and require the formatter to
/// understand escaping rules, type introspection, and other concerns that
/// belong with the comparator. Notably, the comparator already has access to
/// the `Mirror` values, and can extract the necessary information at that time,
/// without requiring subsequent components to either re-`Mirror` the values or
/// use incomplete information (for example, using only string descriptions).
///
/// Storing only the rendered value would not allow for type-safe assertions
/// in tests, and would remove flexibility for potential future use cases that
/// need access to the underlying type.
///
/// The tradeoffs of this approach include increased memory usage, but this is
/// generally acceptable since diff trees are short-lived, and the string
/// overhead is relatively light compared to the overall test execution cost.
package struct DiffValue: Equatable
{
    /// The underlying value.
    package let value       : Any
    
    /// The pre-rendered value.
    package let rendered    : RenderedValue
    
    
    
    /// Initializes a ``DiffValue`` instance from the given values.
    package init(
        value       : Any,
        rendered    : RenderedValue
    )
    {
        self.value      = value
        self.rendered   = rendered
    }
    
    
    
    /// Initializes a ``DiffValue`` instance from the given value.
    package init(
        _ value: Any
    )
    {
        self.value      = value
        self.rendered   = RenderedValue(value)
    }
    
    
    
    /// Checks whether the given values are equal.
    ///
    /// - Note: Equality is based on only ``DiffValue/rendered``.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side value to compare.
    ///   - rhs: The right-hand side value to compare.
    /// - Returns: Whether the given values are equal.
    package static func == (
        lhs : DiffValue,
        rhs : DiffValue
    ) -> Bool
    {
        return lhs.rendered == rhs.rendered
    }
}
