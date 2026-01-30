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

// MARK: - Boolean

/// Asserts that the given expression is true.
///
/// This generates a failure when `expression == false` and is equivalent to
/// ``XCTKAssertTrue(_:_:file:line:options:)-macro``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertMacro"
)



/// Asserts that the given expression is true.
///
/// This generates a failure when `expression == false` and is equivalent to
/// ``XCTKAssert(_:_:file:line:options:)-macro``.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertTrueMacro"
)



/// Asserts that the given expression is false.
///
/// This generates a failure when `expression == true`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertFalseMacro"
)



// MARK: - Nil and non-nil

/// Asserts that the given expression is `nil`.
///
/// This generates a failure when `expression != nil`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNilMacro"
)



/// Asserts that the given expression is not `nil`.
///
/// This generates a failure when `expression == nil`.
///
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    options         : XCTKOptions?                      = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotNilMacro"
)



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
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``XCTKUnwrapError`` if the unwrapped value is `nil`, or an
/// error thrown by the given expression.
@freestanding(expression)
public macro XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) -> T = #externalMacro(
            module:     "XCTestKitMacros",
            type:       "UnwrapMacro"
        )



// MARK: - Equality and inequality

/// Asserts that the given values are equal.
/// - Parameters:
///   - expected: The expected value.
///   - actual: The actual value.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    options     : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertEqualMacro"
)   where T : Equatable



/// Asserts that the given values are not equal.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotEqualMacro"
)   where T : Equatable



/// Asserts that the given values are identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : XCTKOptions?                          = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertIdenticalMacro"
)



/// Asserts that the given values are not identical.
///
/// The values are considered identical if they are the same instance.
///
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : XCTKOptions?                          = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotIdenticalMacro"
)



/// Asserts that the given floating-point values are equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertEqualWithAccuracyMacro"
)   where T : FloatingPoint



/// Asserts that the given numeric values are equal within the given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertEqualWithAccuracyMacro"
)   where T : Numeric



/// Asserts that the given floating-point values are not equal within the
/// given accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotEqualWithAccuracyMacro"
)   where T : FloatingPoint



/// Asserts that the given numeric values are not equal within the given
/// accuracy.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - accuracy: The maximum difference between the given expressions for
///   them to be considered not equal.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotEqualWithAccuracyMacro"
)   where T : Numeric



// MARK: - Comparable

/// Asserts that the value of the first expression is greater than the value
/// of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertGreaterThanMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is greater than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertGreaterThanOrEqualMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is less than or equal to
/// the value of the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:   "AssertLessThanOrEqualMacro"
)   where T : Comparable



/// Asserts that the value of the first expression is less than the value of
/// the second expression.
/// - Parameters:
///   - expression1: The first expression to evaluate.
///   - expression2: The second expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertLessThanMacro"
)   where T : Comparable



// MARK: - Error

/// Asserts that the given expression throws an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - errorHandler: An optional handler for errors thrown by `expression`.
@freestanding(expression)
public macro XCTKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil,
    _ errorHandler  : (any Error) -> Void           = { _ in }
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertThrowsErrorMacro"
)



/// Asserts that the given expression does not throw an error.
/// - Parameters:
///   - expression: The expression to evaluate.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : XCTKOptions?                  = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNoThrowMacro"
)



// MARK: - Fail

/// Immediately generates an unconditional failure.
/// - Parameters:
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this macro was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this macro was called.
@freestanding(expression)
public macro XCTKFail(
    _ message   : String        = "",
    file        : StaticString  = #filePath,
    line        : UInt          = #line
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "FailMacro"
)
