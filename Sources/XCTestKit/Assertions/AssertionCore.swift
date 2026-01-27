//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The kind of captured assertion expression.
internal enum ExprCaptureKind: Equatable, Sendable
{
    /// A function assertion with no expression capture.
    case none
    
    /// A single-expression macro assertion.
    /// - Parameter text: The expression source text.
    case single(
        _ text: String
    )
    
    /// A double-expression macro assertion.
    /// - Parameters:
    ///   - text1: The source text of the first expression.
    ///   - text2: The source text of the second expression.
    case double(
        _ text1: String,
        _ text2: String
    )
}
