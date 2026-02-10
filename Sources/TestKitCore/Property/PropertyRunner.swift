//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitBase



// MARK: - PropertyRunner

/// Runs property-based tests.
package struct PropertyRunner
{
    /// Runs a property check using the given ``Arbitrary`` type.
    /// - Parameters:
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    package static func run<T>(
        property    : (T) throws -> Void,
        options     : TKOptions
    ) -> PropertyCheckResult<T> where T : Arbitrary
    {
        return run(
            generate:       { context in T.arbitrary(using: context) },
            shrink:         { value in value.shrink() },
            precondition:   nil,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a property check using the given generator.
    /// - Parameters:
    ///   - generator: The generator.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    package static func run<T>(
        using generator : Generator<T>,
        property        : (T) throws -> Void,
        options         : TKOptions
    ) -> PropertyCheckResult<T>
    {
        return run(
            generate:       generator.generate,
            shrink:         generator.shrink,
            precondition:   nil,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check.
    /// - Parameters:
    ///   - precondition: The condition which generated inputs must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    package static func run<T>(
        where precondition  : @escaping (T) -> Bool,
        property            : (T) throws -> Void,
        options             : TKOptions
    ) -> PropertyCheckResult<T> where T : Arbitrary
    {
        return run(
            generate:       { context in T.arbitrary(using: context) },
            shrink:         { value in value.shrink() },
            precondition:   precondition,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check using the given generator.
    /// - Parameters:
    ///   - generator: The generator.
    ///   - precondition: The condition which generated inputs must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    package static func run<T>(
        using generator     : Generator<T>,
        where precondition  : @escaping (T) -> Bool,
        property            : (T) throws -> Void,
        options             : TKOptions
    ) -> PropertyCheckResult<T>
    {
        return run(
            generate:       generator.generate,
            shrink:         generator.shrink,
            precondition:   precondition,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check.
    /// - Parameters:
    ///   - generate: The function to generate a value from the given context.
    ///   - shrink: The function to shrink the given value.
    ///   - precondition: The condition which generated inputs must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    private static func run<T>(
        generate            : (GenerationContext) -> T,
        shrink              : @escaping (T) -> [T],
        precondition        : ((T) -> Bool)?,
        property            : (T) throws -> Void,
        options             : TKOptions
    ) -> PropertyCheckResult<T>
    {
        let opts: TKPropertyOptions = options.propertyOptions
        
        let seed: UInt64 = opts.seed
            ?? .random(in: UInt64.min...UInt64.max)
        
        let context         : GenerationContext     = .init(seed: seed)
        let maxSize         : Int                   = opts.maxSize
        let maxDiscardRatio : Int                   = opts.maxDiscardRatio
        let iterations      : Int                   = opts.iterations
        var iteration       : Int                   = 0
        var discarded       : Int                   = 0
        var succeeded       : Int                   = 0
        
        
        
        while succeeded < iterations
        {
            iteration       += 1
            context.size    = succeeded * maxSize / iterations
            
            let value: T = generate(context)
            
            if
                let precondition,
                !precondition(value)
            {
                discarded += 1
                
                if discarded > maxDiscardRatio * iterations
                {
                    return .exhausted(
                        discarded:  discarded,
                        succeeded:  succeeded,
                        ratio:      maxDiscardRatio,
                        seed:       seed
                    )
                }
                
                continue
            }
            
            if didPropertyFail(property, with: value)
            {
                let counterexample: Counterexample<T> = makeCounterexample(
                    value:          value,
                    shrink:         shrink,
                    precondition:   precondition,
                    seed:           seed,
                    iteration:      iteration,
                    property:       property,
                    options:        options
                )
                
                return .failed(counterexample: counterexample)
            }
            else
            {
                succeeded += 1
            }
        }
        
        
        
        return .passed(
            iterations:     iterations,
            seed:           seed
        )
    }
    
    
    
    /// Checks whether the given property fails when called with the
    /// given value.
    /// - Parameters:
    ///   - property: The property body.
    ///   - value: The value with which to call the property body.
    /// - Returns: Whether the given property fails when called with the
    /// given value.
    private static func didPropertyFail<T>(
        _       property    : (T) throws -> Void,
        with    value       : T
    ) -> Bool
    {
        let interceptor : PropertyInterceptor   = .init()
        var threwError  : Bool                  = false
        
        PropertyInterceptor.$current.withValue(interceptor)
        {
            do
            {
                try property(value)
            }
            catch
            {
                threwError = true
            }
        }
        
        return interceptor.didFail
            || threwError
    }
    
    
    
    /// Creates the minimal counterexample for the given value.
    /// - Parameters:
    ///   - value: The failing value.
    ///   - shrink: The function to shrink the given value.
    ///   - precondition: The condition which generated inputs must satisfy.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - iteration: The iteraton at which the failing value was found.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The minimal counterexample for the given value.
    private static func makeCounterexample<T>(
        value           : T,
        shrink          : @escaping (T) -> [T],
        precondition    : ((T) -> Bool)?,
        seed            : UInt64,
        iteration       : Int,
        property        : (T) throws -> Void,
        options         : TKOptions
    ) -> Counterexample<T>
    {
        var current : T     = value
        var steps   : Int   = 0
        
        while steps < options.propertyOptions.maxShrinkSteps
        {
            let candidates  : [T]   = shrink(current)
            var improved    : Bool  = false
            
            for candidate in candidates
            {
                if
                    let precondition,
                    !precondition(candidate)
                {
                    continue
                }
                
                if didPropertyFail(property, with: candidate)
                {
                    current     = candidate
                    improved    = true
                    steps       += 1
                    
                    /// Start again with a smaller value.
                    break
                }
            }
            
            if !improved
            {
                break
            }
        }
        
        
        
        /// Run one more time to capture the assertion output.
        let interceptor : PropertyInterceptor   = .init()
        var thrownError : Error?                = nil
        
        PropertyInterceptor.$current.withValue(interceptor)
        {
            do
            {
                try property(current)
            }
            catch
            {
                thrownError = error
            }
        }
        
        return Counterexample(
            value:          current,
            originalValue:  value,
            seed:           seed,
            iteration:      iteration,
            shrinkSteps:    steps,
            failures:       interceptor.failures,
            thrownError:    thrownError
        )
    }
}



// MARK: - PropertyCheckResult

/// The result of a property check.
package enum PropertyCheckResult<T>
{
    /// All iterations passed.
    /// - Parameters:
    ///   - iterations: The number of iterations.
    ///   - seed: The seed used to initialize the random number generator.
    case passed(
        iterations  : Int,
        seed        : UInt64
    )
    
    /// A counterexample was found.
    /// - Parameter counterexample: The found counterexample.
    case failed(
        counterexample: Counterexample<T>
    )
    
    /// Too many inputs did not meet the preconditions of conditional
    /// properties.
    /// - Parameters:
    ///   - discarded: The number of discarded inputs.
    ///   - succeeded: The number of successful inputs.
    ///   - ratio: The maximum ratio of discarded inputs to successful inputs.
    ///   - seed: The seed used to initialize the random number generator.
    case exhausted(
        discarded   : Int,
        succeeded   : Int,
        ratio       : Int,
        seed        : UInt64
    )
}



// MARK: - Counterexample

/// Information about a failing counterexample.
package struct Counterexample<T>
{
    /// The minimal counterexample (after shrinking).
    package let value           : T
    
    /// The original counterexample (before shrinking).
    package let originalValue   : T
    
    /// The seed used to initialize the random number generator.
    package let seed            : UInt64
    
    /// The 1-indexed iteration at which the original counterexample was found.
    package let iteration       : Int
    
    /// The number of shrink steps performed.
    package let shrinkSteps     : Int
    
    /// The assertion failures from the final run with the shrunken value.
    package let failures        : [InterceptedFailure]
    
    /// The error thrown by the property body, if any.
    package let thrownError     : Error?
}
