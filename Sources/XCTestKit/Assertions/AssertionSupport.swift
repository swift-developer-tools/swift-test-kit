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

import XCTestKitCore



// MARK: - Evaluate expressions

/// Evaluates the given expression.
///
/// - Important: This fails the assertion if the given expression throws an
/// error when called. This does not apply to ``AssertionKind/throwsErrow``.
/// In this single case, `.failure` indicates that the expresion threw an
/// error as expected, and the assertion passed. For all other cases,
/// `.failure`indicates that the expression unexpectedly threw an error, and
/// the assertion failed.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - assertion: The assertion kind.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - errorHandler: An optional handler for errors thrown by `expression`.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
internal func evaluateExpression<T>(
    _ expression    : () throws -> T,
    assertion       : AssertionKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    errorHandler    : (any Error) -> Void   = { _ in }
) -> Result<T, Error>
{
    do
    {
        return .success(try expression())
    }
    catch
    {
        if assertion == .throwsError
        {
            errorHandler(error)
        }
        else
        {
            failAssertion(
                kind:       assertion,
                reason:     "threw error \(quote(error))",
                message:    message,
                file:       file,
                line:       line
            )
        }
        
        return .failure(error)
    }
}



// MARK: - Fail assertions

/// Reports a function assertion failure.
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
    var text: String = "\(kind.name) failed"
    
    if let reason
    {
        text += ": \(reason)"
    }
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a function assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - diff: The computed diff.
///   - options: The options for formatting diffs.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
internal func failAssertion(
    kind    : AssertionKind,
    diff    : DiffNode,
    options : XCTKFormatOptions,
    message : () -> String?,
    file    : StaticString,
    line    : UInt
)
{
    let diffOutput: String = Formatter.format(
        diff,
        options: options
    )
    
    var fullOutput: String = "\(kind.name) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        fullOutput += " - \(msg)"
    }
    
    fullOutput += ":\n\n\(diffOutput)"
    
    XCTKFail(
        fullOutput,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - expressionText: The expression source text.
///   - actual: The string representation of the actual value, or `nil` to omit.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
internal func failAssertion(
    kind            : AssertionKind,
    expressionText  : String,
    actual          : String?,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt
)
{
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpression: \(expressionText)"
    
    if let actual
    {
        text += "\nActual:     \(actual)"
    }
    
    XCTKFail(
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



// MARK: - Numeric equality

internal func areEqual<T>(
    _ expression1   : T,
    _ expression2   : T,
    accuracy        : T
) -> Bool where T : Numeric
{
    if expression1 == expression2
    {
        return true
    }
    
    /// `NaN` values are handled implicitly, since the `<=` operator returns
    /// `false` when comparing any value to `NaN`.
    let difference: T = expression1.magnitude > expression2.magnitude
        ? expression1 - expression2
        : expression2 - expression1
    
    return difference.magnitude <= accuracy.magnitude
}
