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
///   - expression: A Boolean expression.
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
    let value: Bool? = evaluateAssertion(
        kind:           .assert,
        expression:     expression,
        message:        message,
        file:           file,
        line:           line
    )
    
    if value == false
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
///   - expression: A Boolean expression.
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
    let value: Bool? = evaluateAssertion(
        kind:           .`true`,
        expression:     expression,
        message:        message,
        file:           file,
        line:           line
    )
    
    if value == false
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
///   - expression: A Boolean expression.
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
    let value: Bool? = evaluateAssertion(
        kind:           .`false`,
        expression:     expression,
        message:        message,
        file:           file,
        line:           line
    )
    
    if value == true
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
///   - expression: An expression of type `Any?` to compare against `nil`.
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
    let value: Any?
    
    do
    {
        value = try expression()
    }
    catch
    {
        failAssertion(
            kind:       .`nil`,
            reason:     "threw error \"\(error)\"",
            message:    message,
            file:       file,
            line:       line
        )
        
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
///   - expression: An expression of type `Any?` to compare against `nil`.
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
    let value: Any?
    
    do
    {
        value = try expression()
    }
    catch
    {
        failAssertion(
            kind:       .notNil,
            reason:     "threw error \"\(error)\"",
            message:    message,
            file:       file,
            line:       line
        )
        
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
/// the unwarpped value of `expression`.
///
/// - Parameters:
///   - expression: An expression of type `T?`.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: The result of evaluating and unwrapped the given expression.
/// This only returns a value if the unwrapped value is not `nil`.
/// - Throws: An ``XCTKUnwrapError`` if the unwrapped value is `nil`.
public func XCTKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line
) throws -> T
{
    let value: T?
    
    do
    {
        value = try expression()
    }
    catch
    {
        failAssertion(
            kind:       .unwrap,
            reason:     "threw error \"\(error)\"",
            message:    message,
            file:       file,
            line:       line
        )
        
        throw error
    }
    
    if let unwrapped: T = value
    {
        return unwrapped
    }
    
    failAssertion(
        kind:       .unwrap,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
    
    throw XCTKUnwrapError()
}
