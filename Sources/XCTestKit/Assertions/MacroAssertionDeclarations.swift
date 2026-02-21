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
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertMacro"
)



/// Asserts that the given expression is true.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertTrueMacro"
)



/// Asserts that the given expression is false.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertFalseMacro"
)



// MARK: - Nil and non-nil

/// Asserts that the given expression is `nil`.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNilMacro"
)



/// Asserts that the given expression is not `nil`.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNotNilMacro"
)



/// Asserts that the given expression is not `nil`, and returns the unwrapped
/// value.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``UnwrapError`` if the unwrapped value is `nil`, or an error
/// thrown by the given expression.
@freestanding(expression)
public macro XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) -> T = #externalMacro(
            module:     "TestKitMacros",
            type:       "XCTKUnwrapMacro"
        )



// MARK: - Equality and inequality

/// Asserts that the given values are equal.
/// - Parameters:
///   - expected: The expected value.
///   - actual: The actual value.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertEqualMacro"
)   where T : Equatable



/// Asserts that the given values are not equal.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNotEqualMacro"
)   where T : Equatable



/// Asserts that the given values are identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertIdenticalMacro"
)



/// Asserts that the given values are not identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNotIdenticalMacro"
)



/// Asserts that the given floating-point values are equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertEqualWithAccuracyMacro"
)   where T : FloatingPoint



/// Asserts that the given numeric values are equal within the given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertEqualWithAccuracyMacro"
)   where T : Numeric



/// Asserts that the given floating-point values are not equal within the
/// given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNotEqualWithAccuracyMacro"
)   where T : FloatingPoint



/// Asserts that the given numeric values are not equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNotEqualWithAccuracyMacro"
)   where T : Numeric



// MARK: - Comparable

/// Asserts that the value of the first expression is greater than the value
/// of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertGreaterThanMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is greater than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertGreaterThanOrEqualMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is less than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertLessThanOrEqualMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is less than the value of
/// the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertLessThanMacro"
)   where T : Comparable



// MARK: - Error

/// Asserts that the given expression throws an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - errorHandler: An optional handler for errors thrown by `expression`.
@freestanding(expression)
public macro XCTKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil,
    _ errorHandler  : (any Error) -> Void           = { _ in }
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertThrowsErrorMacro"
)



/// Asserts that the given expression does not throw an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertNoThrowMacro"
)



// MARK: - Fail

/// Immediately generates an unconditional failure.
/// - Parameters:
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
@freestanding(expression)
public macro XCTKFail(
    _ message   : String        = "",
    fileID      : StaticString  = #fileID,
    file        : StaticString  = #filePath,
    line        : UInt          = #line,
    column      : UInt          = #column
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKFailMacro"
)



// MARK: - Predicate

/// Asserts that all elements of the given collection satisfy the given
/// predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertAllSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyAllMacro"
)   where C : Collection



/// Asserts that at least one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertAnySatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyAnyMacro"
)   where C : Collection



/// Asserts that no elements of the given collection satisfy the given
/// predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNoneSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyNoneMacro"
)   where C : Collection



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
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyAtLeastMacro"
)   where C : Collection



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
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyAtMostMacro"
)   where C : Collection



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
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSatisfyRangeMacro"
)   where C : Collection



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
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertExactly<C>(
    _ collection    : @autoclosure () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertExactlyMacro"
)   where C : Collection



/// Asserts that exactly one element of the given collection satisfies the
/// given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if the element represents a
///   match. Otherwise, it returns `false` or throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertExactlyOne<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertExactlyOneMacro"
)   where C : Collection



/// Asserts that the given collection is sorted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that returns `true` if its first argument should
///   be ordered before its second argument. Otherwise, it returns `false` or
///   throws an error.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSorted<C>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions?                          = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertSortedMacro"
)   where C : Collection



/// Asserts that each element of the given collection is unique.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertUnique<C>(
    _ collection    : @autoclosure () throws -> C,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertUniqueMacro"
)   where C : Collection, C.Element : Hashable



/// Asserts that each element of the given collection is unique, based on a
/// key extracted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that extracts a key from an element of the
///   collection. Elements are duplicates if they produce equal keys.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this macro was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertUnique<C, K>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element) throws -> K,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions?                  = nil
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "XCTKAssertUniqueByKeyMacro"
)   where C : Collection, K : Hashable
