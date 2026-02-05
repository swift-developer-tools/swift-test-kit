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
    options         : TKOptions?                        = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertMacro"
)



/// Asserts that the given expression is true.
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
    options         : TKOptions?                        = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertTrueMacro"
)



/// Asserts that the given expression is false.
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
    options         : TKOptions?                        = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertFalseMacro"
)



// MARK: - Nil and non-nil

/// Asserts that the given expression is `nil`.
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
    options         : TKOptions?                        = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNilMacro"
)



/// Asserts that the given expression is not `nil`.
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
    options         : TKOptions?                        = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertNotNilMacro"
)



/// Asserts that the given expression is not `nil`, and returns the unwrapped
/// value.
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
    options         : TKOptions?                    = nil
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
    options     : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                            = nil
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
    options         : TKOptions?                            = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil
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
    options         : TKOptions?                    = nil,
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
    options         : TKOptions?                    = nil
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
@freestanding(expression)
public macro XCTKAssertAllSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyAllMacro"
)   where C : Collection



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
@freestanding(expression)
public macro XCTKAssertAnySatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyAnyMacro"
)   where C : Collection



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
@freestanding(expression)
public macro XCTKAssertNoneSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyNoneMacro"
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
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyAtLeastMacro"
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
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyAtMostMacro"
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
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSatisfyRangeMacro"
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
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertExactly<C>(
    _ collection    : @autoclosure () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertExactlyMacro"
)   where C : Collection



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
@freestanding(expression)
public macro XCTKAssertExactlyOne<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertExactlyOneMacro"
)   where C : Collection



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
@freestanding(expression)
public macro XCTKAssertSorted<C>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String             = "",
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    options         : TKOptions?                            = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertSortedMacro"
)   where C : Collection



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
@freestanding(expression)
public macro XCTKAssertUnique<C>(
    _ collection    : @autoclosure () throws -> C,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertUniqueMacro"
)   where C : Collection, C.Element : Hashable



/// Asserts that each element of the given collection is unique, based on a
/// key extracted by the given predicate.
/// - Parameters:
///   - collection: The collection to evaluate.
///   - predicate: A closure that extracts a key from an element of the
///   collection. Elements are duplicates if they produce equal keys.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
@freestanding(expression)
public macro XCTKAssertUnique<C, K>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element) throws -> K,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    options         : TKOptions?                    = nil
) = #externalMacro(
    module:     "XCTestKitMacros",
    type:       "AssertUniqueByKeyMacro"
)   where C : Collection, K : Hashable
