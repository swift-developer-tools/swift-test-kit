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
}
