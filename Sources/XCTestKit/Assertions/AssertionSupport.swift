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
///   - expr: The expression to evaluate.
///   - assertion: The assertion kind.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing.
///   - errorHandler: An optional handler for errors thrown by `expr`.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
internal func evaluateExpr<T>(
    _ expr          : () throws -> T,
    assertion       : AssertionKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?,
    errorHandler    : (any Error) -> Void   = { _ in }
) -> Result<T, Error>
{
    do
    {
        return .success(try expr())
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
                line:       line,
                options:    options
            )
        }
        
        return .failure(error)
    }
}



// MARK: - Fail function assertions

@_documentation(visibility: internal)
/// Reports a function assertion failure.
///
/// - Note: This is public since it is used in boolean macro expansions.
///
/// - Parameters:
///   - kindName: The assertion kind name.
///   - reason: The optional failure reason.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
public func failAssertion(
    kindName    : String,
    reason      : String?,
    message     : String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kindName) failed"
    
    if let reason
    {
        text += ": \(reason)"
    }
    
    if
        let message,
        !message.isEmpty
    {
        text += " - \(message)"
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
///   - reason: The optional failure reason.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind    : AssertionKind,
    reason  : String?,
    message : () -> String?,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
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
///   - options: The options for testing.
internal func failAssertion(
    kind    : AssertionKind,
    diff    : DiffNode,
    message : () -> String?,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
)
{
    let diffOutput: String = Formatter.format(
        diff,
        options: options?.formatOptions
    )
    
    var fullOutput: String = "\(kind.name) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        fullOutput += " - \(msg)"
    }
    
    fullOutput += "\n\n\(diffOutput)"
    
    XCTKFail(
        fullOutput,
        file:   file,
        line:   line
    )
}



// MARK: - Fail macro assertions

/// Reports a macro assertion failure for boolean assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - exprText: The expression source text.
///   - evaluated: The evaluated boolean expressions.
///   - notEvaluated: The number of unevaluated boolean expressions.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind            : AssertionKind,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
)
{
    let output: String = Formatter.formatBooleanExpr(
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        expectedValue:  kind == .false ? false : true,
        options:        XCTKConfig.global.formatOptions
    )
    
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\n\(output)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for single-expression assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - exprText: The expression source text.
///   - actual: The string representation of the actual value, or `nil` to omit.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind        : AssertionKind,
    exprText    : String,
    actual      : String?,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpression: \(exprText)"
    
    if let actual
    {
        text += kind == .noThrow
            ? "\nThrew:      \(actual)"
            : "\nActual:     \(actual)"
    }
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for double-expression assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - expr1Text: The source text of the first expression.
///   - expr2Text: The source text of the second expression.
///   - reason: The failure reason describing the comparison result.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind        : AssertionKind,
    expr1Text   : String,
    expr2Text   : String,
    reason      : String,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kind.macroDisplayName) failed: \(reason)"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpression 1: \(expr1Text)"
    text += "\nExpression 2: \(expr2Text)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for double-expression equality assertions
/// with diff output.
/// - Parameters:
///   - kind: The assertion kind.
///   - expectedText: The source text of the expected expression.
///   - actualText: The source text of the actual expression.
///   - diff: The computed diff.
///   - options: The options for formatting diffs.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind            : AssertionKind,
    expectedText    : String,
    actualText      : String,
    diff            : DiffNode,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
)
{
    let diffOutput: String = Formatter.format(
        diff,
        options: options?.formatOptions
    )
    
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpected: \(expectedText)"
    text += "\nActual:   \(actualText)"
    text += "\n\n\(diffOutput)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



// MARK: - XCTKUnwrapError

/// The error thrown by ``XCTKUnwrap(_:_:file:line:options:)-func`` or
/// ``XCTKUnwrap(_:_:file:line:options:)-macro``when the unwrapped value
/// is `nil`.
public struct XCTKUnwrapError: Error, CustomStringConvertible
{
    /// The error description.
    public var description: String
    {
        return "XCTKUnwrap unwrapped a nil value"
    }
}



// MARK: - XCTKBooleanExpr

@_documentation(visibility: internal)
/// A boolean expression evaluated during macro expression decomposition.
public struct XCTKBooleanExpr: Equatable, Sendable
{
    /// The source text of the expression.
    public let text     : String
    
    /// The evaluated boolean value.
    public let value    : Bool
}



// MARK: - Numeric equality

internal func areEqual<T>(
    _ expr1     : T,
    _ expr2     : T,
    accuracy    : T
) -> Bool where T : Numeric
{
    if expr1 == expr2
    {
        return true
    }
    
    /// `NaN` values are handled implicitly, since the `<=` operator returns
    /// `false` when comparing any value to `NaN`.
    let difference: T = expr1.magnitude > expr2.magnitude
        ? expr1 - expr2
        : expr2 - expr1
    
    return difference.magnitude <= accuracy.magnitude
}
