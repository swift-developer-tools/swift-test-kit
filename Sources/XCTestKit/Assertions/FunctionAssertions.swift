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



// MARK: - Boolean

/// Asserts that the given expression is true.
///
/// This generates a failure when `expression == false` and is equivalent to
/// ``XCTKAssertTrue(_:_:file:line:)``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line
)
{
    evaluateXCTKAssert(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given expression is true.
///
/// This generates a failure when `expression == false` and is equivalent to
/// ``XCTKAssert(_:_:file:line:)``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line
)
{
    evaluateXCTKAssertTrue(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given expression is false.
///
/// This generates a failure when `expression == true`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line
)
{
    evaluateXCTKAssertFalse(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Nil and non-nil

/// Asserts that the given expression is `nil`.
///
/// This generates a failure when `expression != nil`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line
)
{
    evaluateXCTKAssertNil(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given expression is not `nil`.
///
/// This generates a failure when `expression == nil`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line
)
{
    evaluateXCTKAssertNotNil(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given expression is not `nil`, and returns the unwrapped
/// value.
///
/// This generates a failure when `expression == nil`. Otherwise, it returns
/// the unwrapped value of `expression`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``XCTKUnwrapError`` if the unwrapped value is `nil`, or an
/// error thrown by the given expression.
public func XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) throws -> T
{
    return try evaluateXCTKUnwrap(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Equality and inequality

/// Asserts that the given values are equal.
/// - Parameters:
///   - expected: The expected value.
///   - actual: The actual value.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    options     : XCTKOptions?                  = nil
) where T : Equatable
{
    evaluateXCTKAssertEqual(
        captureKind:    .none,
        expected:       expected,
        actual:         actual,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that the given values are not equal.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Equatable
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given values are identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line
)
{
    evaluateXCTKAssertIdentical(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given values are not identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line
)
{
    evaluateXCTKAssertNotIdentical(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given floating-point values are equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : FloatingPoint
{
    evaluateXCTKAssertEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given numeric values are equal within the given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Numeric
{
    evaluateXCTKAssertEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given floating-point values are not equal within the
/// given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : FloatingPoint
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the given numeric values are not equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Numeric
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Comparable

/// Asserts that the value of the first expression is greater than the value
/// of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Comparable
{
    evaluateXCTKAssertGreaterThan(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the value of the first expression is greater than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Comparable
{
    evaluateXCTKAssertGreaterThanOrEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the value of the first expression is less than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Comparable
{
    evaluateXCTKAssertLessThanOrEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



/// Asserts that the value of the first expression is less than the value of
/// the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) where T : Comparable
{
    evaluateXCTKAssertLessThan(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Error

/// Asserts that the given expression throws an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - errorHandler: An optional handler for errors thrown by `expression`.
public func XCTKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    _ errorHandler  : (any Error) -> Void           = { _ in }
)
{
    evaluateXCTKAssertThrowsError(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        errorHandler:   errorHandler
    )
}



/// Asserts that the given expression does not throw an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
)
{
    evaluateXCTKAssertNoThrow(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Fail

/// Immediately generates an unconditional failure.
/// - Parameters:
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
public func XCTKFail(
    _ message   : String        = "",
    file        : StaticString  = #filePath,
    line        : UInt          = #line
)
{
    XCTFail(
        message,
        file:   file,
        line:   line
    )
}
