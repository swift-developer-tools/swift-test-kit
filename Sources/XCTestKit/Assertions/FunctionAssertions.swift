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
    let result: Result<Bool, Error> = evaluateExpression(
        expression,
        assertion:  .assert,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if !value
    {
        failAssertion(
            kind:       .assert,
            reason:     nil,
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<Bool, Error> = evaluateExpression(
        expression,
        assertion:  .`true`,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if !value
    {
        failAssertion(
            kind:       .`true`,
            reason:     nil,
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<Bool, Error> = evaluateExpression(
        expression,
        assertion:  .`false`,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value
    {
        failAssertion(
            kind:       .`false`,
            reason:     nil,
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<Any?, Error> = evaluateExpression(
        expression,
        assertion:  .`nil`,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value != nil
    {
        failAssertion(
            kind:       .`nil`,
            reason:     nil,
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<Any?, Error> = evaluateExpression(
        expression,
        assertion:  .notNil,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value == nil
    {
        failAssertion(
            kind:       .notNil,
            reason:     nil,
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<T?, Error> = evaluateExpression(
        expression,
        assertion:  .unwrap,
        message:    message,
        file:       file,
        line:       line
    )
    
    switch result
    {
        case let .success(value):
            
            guard let value
            else
            {
                failAssertion(
                    kind:       .unwrap,
                    reason:     nil,
                    message:    message,
                    file:       file,
                    line:       line
                )
                
                throw XCTKUnwrapError()
            }
            
            return value
            
        case let .failure(error):
            
            throw error
    }
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
///   - options: The options for testing. The default value is a
///   default-initialized ``XCTKOptions`` instance.
public func XCTKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    options     : XCTKOptions                   = .init()
) where T : Equatable
{
    let expResult: Result<T, Error> = evaluateExpression(
        expected,
        assertion:  .equal,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(exp) = expResult
    else
    {
        return
    }
    
    
    
    let actResult: Result<T, Error> = evaluateExpression(
        actual,
        assertion:  .equal,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(act) = actResult
    else
    {
        return
    }
    
    
    
    if exp == act
    {
        return
    }
    
    guard options.diffEnabled
    else
    {
        failAssertion(
            kind:       .equal,
            reason:     "(\(quote(exp))) is not equal to (\(quote(act)))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    let diff: DiffNode = Comparator.computeDiff(
        expected:   exp,
        actual:     act,
        options:    options.diffOptions
    )
    
    failAssertion(
        kind:       .equal,
        diff:       diff,
        options:    options.formatOptions,
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .notEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .notEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 != value2
    {
        return
    }
    
    failAssertion(
        kind:       .notEqual,
        reason:     "both values equal (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
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
    let value1: AnyObject?
    
    do
    {
        value1 = try expression1()
    }
    catch
    {
        failAssertion(
            kind:       .identical,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    let value2: AnyObject?
    
    do
    {
        value2 = try expression2()
    }
    catch
    {
        failAssertion(
            kind:       .identical,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    if value1 === value2
    {
        return
    }
    
    failAssertion(
        kind:       .identical,
        reason:     "(\(quote(value1))) is not identical to (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
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
    let value1: AnyObject?
    
    do
    {
        value1 = try expression1()
    }
    catch
    {
        failAssertion(
            kind:       .notIdentical,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    let value2: AnyObject?
    
    do
    {
        value2 = try expression2()
    }
    catch
    {
        failAssertion(
            kind:       .notIdentical,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    if value1 !== value2
    {
        return
    }
    
    failAssertion(
        kind:       .notIdentical,
        reason:     "both values are identical (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .equalWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .equalWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    failAssertion(
        kind:       .equalWithAccuracy,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .equalWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .equalWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    failAssertion(
        kind:       .equalWithAccuracy,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .notEqualWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .notEqualWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    failAssertion(
        kind:       .notEqualWithAccuracy,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .notEqualWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .notEqualWithAccuracy,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    failAssertion(
        kind:       .notEqualWithAccuracy,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .greaterThan,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .greaterThan,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 <= value2
    {
        failAssertion(
            kind:       .greaterThan,
            reason:     "(\(quote(value1))) is not greater than"
                        + " (\(quote(value2)))",
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .greaterThanOrEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .greaterThanOrEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 < value2
    {
        failAssertion(
            kind:       .greaterThanOrEqual,
            reason:     "(\(quote(value1))) is not greater than or equal to"
                        + " (\(quote(value2)))",
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .lessThanOrEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .lessThanOrEqual,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 > value2
    {
        failAssertion(
            kind:       .lessThanOrEqual,
            reason:     "(\(quote(value1))) is not less than or equal to"
                        + " (\(quote(value2)))",
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result1: Result<T, Error> = evaluateExpression(
        expression1,
        assertion:  .lessThan,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpression(
        expression2,
        assertion:  .lessThan,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 >= value2
    {
        failAssertion(
            kind:       .lessThan,
            reason:     "(\(quote(value1))) is not less than"
                        + " (\(quote(value2)))",
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    let result: Result<T, Error> = evaluateExpression(
        expression,
        assertion:      .throwsError,
        message:        message,
        file:           file,
        line:           line,
        errorHandler:   errorHandler
    )
    
    if case .success = result
    {
        failAssertion(
            kind:       .throwsError,
            reason:     "did not throw an error",
            message:    message,
            file:       file,
            line:       line
        )
    }
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
    _ = evaluateExpression(
        expression,
        assertion:  .noThrow,
        message:    message,
        file:       file,
        line:       line
    )
}
