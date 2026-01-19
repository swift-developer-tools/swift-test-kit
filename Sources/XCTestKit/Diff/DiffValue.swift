//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
