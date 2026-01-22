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



// MARK: - AssertionKind

/// The kind of an assertion.
internal enum AssertionKind
{
    case assert
    case equal
    case equalWithAccuracy
    case identical
    case notIdentical
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case notEqual
    case notEqualWithAccuracy
    case `nil`
    case notNil
    case unwrap
    case `true`
    case `false`
    case fail
    case throwsError
    case noThrow
    
    
    
    /// The assertion name.
    var name: String
    {
        switch self
        {
            case .assert                : return "XCTKAssert"
            case .equal                 : return "XCTKAssertEqual"
            case .equalWithAccuracy     : return "XCTKAssertEqual"
            case .identical             : return "XCTKAssertIdentical"
            case .notIdentical          : return "XCTKAssertNotIdentical"
            case .greaterThan           : return "XCTKAssertGreaterThan"
            case .greaterThanOrEqual    : return "XCTKAssertGreaterThanOrEqual"
            case .lessThan              : return "XCTKAssertLessThan"
            case .lessThanOrEqual       : return "XCTKAssertLessThanOrEqual"
            case .notEqual              : return "XCTKAssertNotEqual"
            case .notEqualWithAccuracy  : return "XCTKAssertNotEqual"
            case .`nil`                 : return "XCTKAssertNil"
            case .notNil                : return "XCTKAssertNotNil"
            case .unwrap                : return "XCTKUnwrap"
            case .`true`                : return "XCTKAssertTrue"
            case .`false`               : return "XCTKAssertFalse"
            case .throwsError           : return "XCTKAssertThrowsError"
            case .noThrow               : return "XCTKAssertNoThrow"
            case .fail                  : return "XCTKAssertion"
        }
    }
}



// MARK: - Evaluate expressions

/// Evaluates the given expression.
///
/// - Important: This fails the assertion if the given expression throws an
/// error when called.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - assertion: The assertion kind.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
internal func evaluateExpression<T>(
    _ expression    : () throws -> T,
    assertion       : AssertionKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
) -> Result<T, Error>
{
    do
    {
        return .success(try expression())
    }
    catch
    {
        failAssertion(
            kind:       assertion,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return .failure(error)
    }
}



// MARK: - Fail assertions

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
    
    XCTFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports an assertion failure.
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
    
    XCTFail(
        fullOutput,
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
