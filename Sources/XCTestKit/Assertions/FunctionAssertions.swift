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
/// ``XCTKAssertTrue(_:_:file:line:options:)-func``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
)
{
    evaluateXCTKAssert(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



/// Asserts that the given expression is true.
///
/// This generates a failure when `expression == false` and is equivalent to
/// ``XCTKAssert(_:_:file:line:options:)-func``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
)
{
    evaluateXCTKAssertTrue(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
)
{
    evaluateXCTKAssertFalse(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
)
{
    evaluateXCTKAssertNil(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
)
{
    evaluateXCTKAssertNotNil(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``XCTKUnwrapError`` if the unwrapped value is `nil`, or an
/// error thrown by the given expression.
public func XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) throws -> T
{
    return try evaluateXCTKUnwrap(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Equatable
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : XCTKOptions?                          = nil
)
{
    evaluateXCTKAssertIdentical(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : XCTKOptions?                          = nil
)
{
    evaluateXCTKAssertNotIdentical(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : FloatingPoint
{
    evaluateXCTKAssertEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Numeric
{
    evaluateXCTKAssertEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : FloatingPoint
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Numeric
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Comparable
{
    evaluateXCTKAssertGreaterThan(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Comparable
{
    evaluateXCTKAssertGreaterThanOrEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Comparable
{
    evaluateXCTKAssertLessThanOrEqual(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where T : Comparable
{
    evaluateXCTKAssertLessThan(
        captureKind:    .none,
        expr1:          expression1,
        expr2:          expression2,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - errorHandler: An optional handler for errors thrown by `expression`.
public func XCTKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil,
    _ errorHandler  : (any Error) -> Void           = { _ in }
)
{
    evaluateXCTKAssertThrowsError(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
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
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
)
{
    evaluateXCTKAssertNoThrow(
        captureKind:    .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options
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



// MARK: - Predicate

/// Asserts that all elements of the given collection satisfy the given
/// predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertAllSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{
    evaluateXCTKAssertAllSatisfy(
        captureKind:    .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that at least one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertAnySatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{
    evaluateXCTKAssertAnySatisfy(
        captureKind:    .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that no elements of the given collection satisfy the given
/// predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNoneSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{
    evaluateXCTKAssertNoneSatisfy(
        captureKind:    .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that at least the specified number of elements of the given
/// collection satisfy the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - atLeast: The minimum number of elements of the collection that must
///   satisfy the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        captureKind:    .none,
        collection:     collection,
        atLeast:        atLeast,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that up to the specified number of elements of the given collection
/// satisfy the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - atMost: The maximum number of elements of the collection that must
///   satisfy the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{    
    evaluateXCTKAssertSatisfy(
        captureKind:    .none,
        collection:     collection,
        atMost:         atMost,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that the number of elements of the given collection that satisfy
/// the given predicate is within the specified range.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - range: The range within which the number of matching elements must fall.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{    
    evaluateXCTKAssertSatisfy(
        captureKind:    .none,
        collection:     collection,
        range:          range,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that exactly the specified number of elements of the given
/// collection satisfy the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - count: The exact number of elements of the collection that must satisfy
///   the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertExactly<C>(
    _ collection    : @autoclosure () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{    
    evaluateXCTKAssertExactly(
        captureKind:    .none,
        collection:     collection,
        count:          count,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that exactly one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertExactlyOne<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection
{
    evaluateXCTKAssertExactlyOne(
        captureKind:    .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that the given collection is sorted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if its first argument should
///   be ordered before its second argument. Otherwise, it returns `false` or
///   throws an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSorted<C>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : XCTKOptions?                          = nil
) where C : Collection
{
    evaluateXCTKAssertSorted(
        captureKind:    .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that each element of the given collection is unique.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertUnique<C>(
    _ collection    : @autoclosure () throws -> C,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection, C.Element : Hashable
{
    evaluateXCTKAssertUnique(
        captureKind:    .none,
        collection:     collection,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



/// Asserts that each element of the given collection is unique, based on a
/// key extracted by the given closure.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - key: A closure that extracts a key from an element of the collection.
///   Two elements are considered duplicates if they produce equal keys.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertUnique<C, K>(
    _ collection    : @autoclosure () throws -> C,
    by key          : (C.Element) throws -> K,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) where C : Collection, K : Hashable
{
    evaluateXCTKAssertUnique(
        captureKind:    .none,
        collection:     collection,
        key:            key,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}
