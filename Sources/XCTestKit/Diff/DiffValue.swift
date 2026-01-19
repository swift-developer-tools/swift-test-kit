//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

//  MARK: - RenderedValueKind

/// The kind of a rendered value.
internal enum RenderedValueKind: Equatable, Sendable
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

/// Pre-rendered information about a value.
internal struct RenderedValue: Equatable, Sendable, CustomStringConvertible
{
    /// The string representation of the value.
    ///
    /// For strings, this is the string content with special characters
    /// escaped (`\n`, `\t`, `\r`, `\0`, `\\`), but without surrounding quotes.
    /// Quoting is handled by the formatter.
    let description : String
    
    /// The name of the value's type.
    ///
    /// This uses the full generic signature (for example, `Array<String>`).
    let typeName    : String
    
    /// The kind of value, used to determine the formatting behavior.
    let kind        : RenderedValueKind
    
    
    
    /// Initializes a ``RenderedValue`` instance from the given values.
    init(
        description : String,
        typeName    : String,
        kind        : RenderedValueKind
    )
    {
        self.description    = description
        self.typeName       = typeName
        self.kind           = kind
    }
    
    
    
    /// Initializes a ``RenderedValue`` instance from the given value.
    /// - Parameter value: The value to use.
    init(
        _ value: Any
    )
    {
        self.typeName = XCTestKit.typeName(of: value)
        
        if let string = value as? String
        {
            self.description    = string.escaped
            self.kind           = .string
        }
        else if let character = value as? Character
        {
            self.description    = String(character).escaped
            self.kind           = .string
        }
        else
        {
            self.description    = String(describing: value)
            self.kind           = .other
        }
    }
}



// MARK: - DiffValue

/// A value captured during diff computation.
///
/// This stores both the original value and its pre-rendered representation in
/// a diff node, allowing for a single rendering location. The comparator is
/// responsible for all value inspection and rendering, and the formatter works
/// with only pre-rendered data. The formatter can therefore focus only on
/// layout issues like indentation, alignment, and truncation.
///
/// Storing only the original value with lightweight metadata (type name, kind,
/// etc.) would split the rendering logic and require the formatter to
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
internal struct DiffValue
{
    /// The original value.
    let value       : Any
    
    /// The pre-rendered information about the value.
    let rendered    : RenderedValue
}
