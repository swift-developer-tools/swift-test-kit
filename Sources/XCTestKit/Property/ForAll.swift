//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Asserts that the given property holds for all generated inputs.
///
/// XCTestKit assertions used inside a property body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a property body, it bypasses
/// shrinking and produces an immediate test failure. Use only XCTestKit
/// assertions inside property bodies.
///
/// - Parameters:
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
public func XCTKForAll<each T>(
    _ message   : @autoclosure () -> String         = "",
    file        : StaticString                      = #filePath,
    line        : UInt                              = #line,
    options     : TestOptions?                      = nil,
    _ property  : (repeat each T) throws -> Void
) where repeat each T : Arbitrary
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat Generator<each T>.arbitrary())
    
    let wrappedProperty: ((repeat each T)) throws -> Void =
    {
        tuple in
        
        try property(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)> = PropertyRunner.run(
        using:      generator,
        property:   wrappedProperty,
        options:    options ?? XCTKConfig.global
    )
    
    result.emit(
        context:    failureContext,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all inputs produced by the
/// given generators.
///
/// Use a generator when ``Arbitrary`` conformance of a specific type does
/// not produce the necessary distribution of values. For example, a
/// generator may be used to test only positive integers, or only non-empty
/// arrays.
///
/// XCTestKit assertions used inside a property body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a property body, it bypasses
/// shrinking and produces an immediate test failure. Use only XCTestKit
/// assertions inside property bodies.
///
/// - Parameters:
///   - generators: The generators to use to produce values.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
public func XCTKForAll<each T>(
    using generators    : repeat Generator<each T>,
    message             : @autoclosure () -> String         = "",
    file                : StaticString                      = #filePath,
    line                : UInt                              = #line,
    options             : TestOptions?                      = nil,
    _ property          : (repeat each T) throws -> Void
)
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat each generators)
    
    let wrappedProperty: ((repeat each T)) throws -> Void =
    {
        tuple in
        
        try property(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)> = PropertyRunner.run(
        using:      generator,
        property:   wrappedProperty,
        options:    options ?? XCTKConfig.global
    )
    
    result.emit(
        context:    failureContext,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all generated inputs that satisfy
/// the given precondition.
///
/// Inputs that do not satisfy the precondition are discarded. If too many
/// inputs are discarded relative to the max discard ratio, the test fails
/// with an exhaustion error.
///
/// - Important: Preconditions that reject most inputs waste iterations and
/// can lead to exhaustion. Prefer constructing valid inputs using a custom
/// ``Generator`` rather than discarding invalid inputs with a precondition.
///
/// XCTestKit assertions used inside a property body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a property body, it bypasses
/// shrinking and produces an immediate test failure. Use only XCTestKit
/// assertions inside property bodies.
///
/// - Parameters:
///   - precondition: The condition which generated inputs must satisfy.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
public func XCTKForAll<each T>(
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : @autoclosure () -> String         = "",
    file                : StaticString                      = #filePath,
    line                : UInt                              = #line,
    options             : TestOptions?                      = nil,
    _ property          : (repeat each T) throws -> Void
) where repeat each T : Arbitrary
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat Generator<each T>.arbitrary())
    
    let wrappedProperty: ((repeat each T)) throws -> Void =
    {
        tuple in
        
        try property(repeat each tuple)
    }
    
    let wrappedPrecondition: ((repeat each T)) -> Bool =
    {
        tuple in
        
        return precondition(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)> = PropertyRunner.run(
        using:      generator,
        where:      wrappedPrecondition,
        property:   wrappedProperty,
        options:    options ?? XCTKConfig.global
    )
    
    result.emit(
        context:    failureContext,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all inputs produced by the given
/// generators that satisfy the given precondition.
///
/// Inputs that do not satisfy the precondition are discarded. If too many
/// inputs are discarded relative to the max discard ratio, the test fails
/// with an exhaustion error.
///
/// - Important: Preconditions that reject most inputs waste iterations and
/// can lead to exhaustion. Prefer constructing valid inputs using
/// generator-level filtering rather than discarding invalid inputs with a
/// precondition.
///
/// XCTestKit assertions used inside a property body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a property body, it bypasses
/// shrinking and produces an immediate test failure. Use only XCTestKit
/// assertions inside property bodies.
///
/// - Parameters:
///   - generators: The generators to use to produce values.
///   - precondition: The condition which generated inputs must satisfy.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
public func XCTKForAll<each T>(
    using generators    : repeat Generator<each T>,
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : @autoclosure () -> String         = "",
    file                : StaticString                      = #filePath,
    line                : UInt                              = #line,
    options             : TestOptions?                      = nil,
    _ property          : (repeat each T) throws -> Void
)
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat each generators)
    
    let wrappedProperty: ((repeat each T)) throws -> Void =
    {
        tuple in
        
        try property(repeat each tuple)
    }
    
    let wrappedPrecondition: ((repeat each T)) -> Bool =
    {
        tuple in
        
        return precondition(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)> = PropertyRunner.run(
        using:      generator,
        where:      wrappedPrecondition,
        property:   wrappedProperty,
        options:    options ?? XCTKConfig.global
    )
    
    result.emit(
        context:    failureContext,
        message:    message,
        file:       file,
        line:       line
    )
}
