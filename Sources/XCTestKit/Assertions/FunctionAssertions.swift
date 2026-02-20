//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



// MARK: - Boolean

/// Asserts that the given expression is true.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
)
{
    TKAssert(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given expression is true.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
)
{
    TKAssertTrue(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given expression is false.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
)
{
    TKAssertFalse(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Nil and non-nil

/// Asserts that the given expression is `nil`.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
)
{
    TKAssertNil(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given expression is not `nil`.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
)
{
    TKAssertNotNil(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given expression is not `nil`, and returns the unwrapped
/// value.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``UnwrapError`` if the unwrapped value is `nil`, or an error
/// thrown by the given expression.
public func XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                  = nil
) throws -> T
{
    return try TKUnwrap(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Equality and inequality

/// Asserts that the given values are equal.
/// - Parameters:
///   - expected: The expected value.
///   - actual: The actual value.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil
) where T : Equatable
{
    TKAssertEqual(
        expected,
        actual,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given values are not equal.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Equatable
{
    TKAssertNotEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
)
{
    TKAssertIdentical(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
)
{
    TKAssertNotIdentical(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : FloatingPoint
{
    TKAssertEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given numeric values are equal within the given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Numeric
{
    TKAssertEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : FloatingPoint
{
    TKAssertNotEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Numeric
{
    TKAssertNotEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Comparable

/// Asserts that the value of the first expression is greater than the value
/// of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Comparable
{
    TKAssertGreaterThan(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the value of the first expression is greater than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Comparable
{
    TKAssertGreaterThanOrEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the value of the first expression is less than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Comparable
{
    TKAssertLessThanOrEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the value of the first expression is less than the value of
/// the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where T : Comparable
{
    TKAssertLessThan(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Error

/// Asserts that the given expression throws an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - errorHandler: An optional handler for errors thrown by `expression`.
public func XCTKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil,
    _ errorHandler  : (any Error) -> Void           = { _ in }
)
{
    TKAssertThrowsError(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        errorHandler,
        context:    failureContext
    )
}



/// Asserts that the given expression does not throw an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
)
{
    TKAssertNoThrow(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Fail

/// Immediately generates an unconditional failure.
/// - Parameters:
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
public func XCTKFail(
    _ message   : String        = "",
    fileID      : StaticString  = #fileID,
    file        : StaticString  = #filePath,
    line        : UInt          = #line,
    column      : UInt          = #column
)
{
    TKFail(
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        context:    failureContext
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
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertAllSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{
    TKAssertAllSatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that at least one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertAnySatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{
    TKAssertAnySatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that no elements of the given collection satisfy the given
/// predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertNoneSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{
    TKAssertNoneSatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that at least the specified number of elements of the given
/// collection satisfy the given predicate.
///
/// - Precondition: `atLeast` must be non-negative.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - atLeast: The minimum number of elements of the collection that must
///   satisfy the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{
    TKAssertSatisfy(
        collection,
        atLeast:    atLeast,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that up to the specified number of elements of the given collection
/// satisfy the given predicate.
///
/// - Precondition: `atMost` must be non-negative.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - atMost: The maximum number of elements of the collection that must
///   satisfy the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{    
    TKAssertSatisfy(
        collection,
        atMost:     atMost,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the number of elements of the given collection that satisfy
/// the given predicate is within the specified range.
///
/// - Precondition: `range.lowerBound` must be less than or equal to
/// `range.upperBound`, and non-negative.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - range: The range within which the number of matching elements must fall.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{    
    TKAssertSatisfy(
        collection,
        range:      range,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that exactly the specified number of elements of the given
/// collection satisfy the given predicate.
///
/// - Precondition: `count` must be non-negative.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - count: The exact number of elements of the collection that must satisfy
///   the predicate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertExactly<C>(
    _ collection    : @autoclosure () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{    
    TKAssertExactly(
        collection,
        count:      count,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that exactly one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertExactlyOne<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection
{
    TKAssertExactlyOne(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that the given collection is sorted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if its first argument should
///   be ordered before its second argument. Otherwise, it returns `false` or
///   throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertSorted<C>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
) where C : Collection
{
    TKAssertSorted(
        collection,
        by:         predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that each element of the given collection is unique.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertUnique<C>(
    _ collection    : @autoclosure () throws -> C,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection, C.Element : Hashable
{
    TKAssertUnique(
        collection,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



/// Asserts that each element of the given collection is unique, based on a
/// key extracted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that extracts a key from an element of the
///   collection. Elements are duplicates if they produce equal keys.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
public func XCTKAssertUnique<C, K>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element) throws -> K,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) where C : Collection, K : Hashable
{
    TKAssertUnique(
        collection,
        by:         predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}
