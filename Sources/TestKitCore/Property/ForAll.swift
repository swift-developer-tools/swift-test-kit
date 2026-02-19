//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Asserts that the given property holds for all generated inputs.
@Reasync
package func TKForAll<each T>(
    _ message   : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    _ property  : (repeat each T) async throws -> Void,
    context     : FailureContext
) async where repeat each T : Arbitrary
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat Generator<each T>.arbitrary())
    
    let wrappedProperty: ((repeat each T)) async throws -> Void =
    {
        tuple in
        
        try await property(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)>
        = await PropertyRunner.run(
            using:      generator,
            property:   wrappedProperty,
            options:    options
        )
    
    result.emit(
        context:    context,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all inputs produced by the
/// given generators.
@Reasync
package func TKForAll<each T>(
    using generators    : repeat Generator<each T>,
    message             : () -> String,
    file                : StaticString,
    line                : UInt,
    options             : TestOptions,
    _ property          : (repeat each T) async throws -> Void,
    context             : FailureContext
) async
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat each generators)
    
    let wrappedProperty: ((repeat each T)) async throws -> Void =
    {
        tuple in
        
        try await property(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)>
        = await PropertyRunner.run(
            using:      generator,
            property:   wrappedProperty,
            options:    options
        )
    
    result.emit(
        context:    context,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all generated inputs that satisfy
/// the given precondition.
@Reasync
package func TKForAll<each T>(
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : () -> String,
    file                : StaticString,
    line                : UInt,
    options             : TestOptions,
    _ property          : (repeat each T) async throws -> Void,
    context             : FailureContext
) async where repeat each T : Arbitrary
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat Generator<each T>.arbitrary())
    
    let wrappedProperty: ((repeat each T)) async throws -> Void =
    {
        tuple in
        
        try await property(repeat each tuple)
    }
    
    let wrappedPrecondition: ((repeat each T)) -> Bool =
    {
        tuple in
        
        return precondition(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)>
        = await PropertyRunner.run(
            using:      generator,
            where:      wrappedPrecondition,
            property:   wrappedProperty,
            options:    options
        )
    
    result.emit(
        context:    context,
        message:    message,
        file:       file,
        line:       line
    )
}



/// Asserts that the given property holds for all inputs produced by the given
/// generators that satisfy the given precondition.
@Reasync
package func TKForAll<each T>(
    using generators    : repeat Generator<each T>,
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : () -> String,
    file                : StaticString,
    line                : UInt,
    options             : TestOptions,
    _ property          : (repeat each T) async throws -> Void,
    context             : FailureContext
) async
{
    let generator: Generator<(repeat each T)>
        = .zip(repeat each generators)
    
    let wrappedProperty: ((repeat each T)) async throws -> Void =
    {
        tuple in
        
        try await property(repeat each tuple)
    }
    
    let wrappedPrecondition: ((repeat each T)) -> Bool =
    {
        tuple in
        
        return precondition(repeat each tuple)
    }
    
    let result: PropertyCheckResult<(repeat each T)>
        = await PropertyRunner.run(
            using:      generator,
            where:      wrappedPrecondition,
            property:   wrappedProperty,
            options:    options
        )
    
    result.emit(
        context:    context,
        message:    message,
        file:       file,
        line:       line
    )
}
