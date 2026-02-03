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
///   - assertionKind: The assertion kind.
///   - captureKind: The kind of captured assertion expression.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - errorHandler: An optional handler for errors thrown by `expr`.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
internal func evaluateExpr<T>(
    _ expr          : () throws -> T,
    assertionKind   : AssertionKind,
    captureKind     : ExprCaptureKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    errorHandler    : (any Error) -> Void   = { _ in }
) -> Result<T, Error>
{
    do
    {
        return .success(try expr())
    }
    catch
    {
        if assertionKind == .throwsError
        {
            errorHandler(error)
        }
        else
        {
            assertionKind.fail(
                captureKind:    captureKind,
                reason:         "threw error \(quote(error))",
                message:        message,
                file:           file,
                line:           line
            )
        }
        
        return .failure(error)
    }
}



// MARK: - Evaluate collections

/// Evaluates the given collection.
///
/// - Important: This fails the assertion if the given collection expression
/// throws an error when called.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - assertionKind: The assertion kind.
///   - captureKind: The kind of captured assertion expression.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given collection expression.
internal func evaluateCollection<C>(
    _ collection    : () throws -> C,
    assertionKind   : AssertionKind,
    captureKind     : ExprCaptureKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt
) -> Result<C, Error> where C : Collection
{
    do
    {
        return .success(try collection())
    }
    catch
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "threw error \(quote(error))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return .failure(error)
    }
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
        let name: String = AssertionKind.unwrap.name(for: .xctk)
        
        return "\(name) unwrapped a nil value"
    }
}
