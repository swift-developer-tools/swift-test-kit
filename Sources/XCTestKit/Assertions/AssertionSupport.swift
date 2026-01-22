//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
// Parts of this file are adapted from the Swift.org open source project.
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors.
// Licensed under the Apache License, Version 2.0, with Runtime Library
// Exception.
//
// See https://swift.org/LICENSE.txt for license information.
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors.
//
//===----------------------------------------------------------------------===//

import XCTest



// MARK: - Evaluate

/// Evaluates the given expression.
/// - Parameters:
///   - kind: The assertion kind.
///   - expression: The expression to evaluate.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: The value returned by the given expression, or `nil` if the
/// expression throws an error.
internal func evaluateAssertion<T>(
    kind        : AssertionKind,
    expression  : () throws -> T,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
) -> T?
{
    do
    {
        return try expression()
    }
    catch
    {
        failAssertion(
            kind:       kind,
            reason:     "threw error \"\(error)\"",
            message:    message,
            file:       file,
            line:       line
        )
        
        return nil
    }
}



// MARK: - Fail

/// Reports an assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - reason: The optional failure reason.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
internal func failAssertion(
    kind    : AssertionKind,
    reason  : String?,
    message : () -> String?,
    file    : StaticString,
    line    : UInt
)
{
    var text: String = kind.name
    
    if let reason
    {
        text += " \(reason)"
    }
    else
    {
        text += " failed"
    }
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    XCTFail(
        text,
        file:   file,
        line:   line
    )
}



// MARK: - XCTKUnwrapError

/// The error thrown by ``XCTKUnwrap(_:_:file:line:)`` when the unwrapped
/// value is `nil`.
public struct XCTKUnwrapError: Error, CustomStringConvertible
{
    /// The error description.
    public var description: String
    {
        return "XCTKUnwrap unwrapped a nil value"
    }
}
