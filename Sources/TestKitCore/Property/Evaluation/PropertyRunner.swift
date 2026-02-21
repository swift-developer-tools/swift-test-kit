//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog



/// Runs property-based tests.
internal struct PropertyRunner
{
    // MARK: - Run
    
    /// Runs a property check using the given ``Arbitrary`` type.
    /// - Parameters:
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        property    : (T) async throws -> Void,
        options     : TestOptions
    ) async -> PropertyCheckResult<T> where T : Arbitrary
    {
        return await run(
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
    @Reasync
    internal static func run<T>(
        using generator : Generator<T>,
        property        : (T) async throws -> Void,
        options         : TestOptions
    ) async -> PropertyCheckResult<T>
    {
        return await run(
            generate:       generator.generate,
            shrink:         generator.shrink,
            precondition:   nil,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check.
    /// - Parameters:
    ///   - precondition: The condition which generated values must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        where precondition  : @escaping (T) -> Bool,
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyCheckResult<T> where T : Arbitrary
    {
        return await run(
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
    ///   - precondition: The condition which generated values must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        using generator     : Generator<T>,
        where precondition  : @escaping (T) -> Bool,
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyCheckResult<T>
    {
        return await run(
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
    ///   - precondition: The condition which generated values must satisfy.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    private static func run<T>(
        generate            : (GenerationContext) -> T,
        shrink              : @escaping (T) -> [T],
        precondition        : ((T) -> Bool)?,
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyCheckResult<T>
    {
        let opts: PropertyOptions = options.propertyOptions
        
        let seed: UInt64 = opts.seed
            ?? .random(in: UInt64.min...UInt64.max)
        
        let interceptor     : PropertyInterceptor   = .init()
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
                        discarded:          discarded,
                        succeeded:          succeeded,
                        ratio:              maxDiscardRatio,
                        seed:               seed,
                        distribution:       interceptor.distribution,
                        tableDistribution:  interceptor.tableDistribution
                    )
                }
                
                continue
            }
            
            let result: IterationResult = await evaluateProperty(
                property,
                with:   value,
                using:  interceptor
            )
            
            switch result
            {
                case .passed:
                    
                    interceptor.finalizeIteration()
                    succeeded += 1
                    
                case .failed:
                    
                    let counterexample: Counterexample<T>
                        = await makeCounterexample(
                            value:          value,
                            shrink:         shrink,
                            precondition:   precondition,
                            seed:           seed,
                            iteration:      iteration,
                            property:       property,
                            options:        options
                        )
                    
                    return .failed(
                        counterexample:     counterexample,
                        distribution:       interceptor.distribution,
                        tableDistribution:  interceptor.tableDistribution
                    )
                    
                case .discarded:
                    
                    discarded += 1
                    
                    if discarded > maxDiscardRatio * iterations
                    {
                        return .exhausted(
                            discarded:          discarded,
                            succeeded:          succeeded,
                            ratio:              maxDiscardRatio,
                            seed:               seed,
                            distribution:       interceptor.distribution,
                            tableDistribution:  interceptor.tableDistribution
                        )
                    }
            }
        }
        
        
        
        if iterations == 0
        {
            logger.warning(
                "Test passed vacuously - PropertyOptions.iterations is zero"
            )
        }
        
        
        
        let unmet: [UnmetCoverage]
            = interceptor.checkCoverage(iterations: iterations)
        
        if !unmet.isEmpty
        {
            return .coverageNotMet(
                unmet:              unmet,
                iterations:         iterations,
                seed:               seed,
                distribution:       interceptor.distribution,
                tableDistribution:  interceptor.tableDistribution
            )
        }
        
        
        
        if
            !interceptor.distribution.isEmpty
            || !interceptor.tableDistribution.isEmpty
        {
            var flatLines: [String]
                = PropertyCheckResult<T>.formatDistribution(
                    interceptor.distribution,
                    iterations: iterations
                )
            
            let tableLines: [String]
                = PropertyCheckResult<T>.formatTableDistribution(
                    interceptor.tableDistribution,
                    iterations: iterations
                )
            
            if
                !flatLines.isEmpty,
                !tableLines.isEmpty
            {
                flatLines.append("")
            }
            
            flatLines.append(contentsOf: tableLines)
            
            let summary: String = flatLines.joined(separator: "\n")
            
            logger.info("Property passed \(iterations) iterations\n\(summary)")
        }
        
        
        
        return .passed(
            iterations:         iterations,
            seed:               seed,
            distribution:       interceptor.distribution,
            tableDistribution:  interceptor.tableDistribution
        )
    }
    
    
    
    // MARK: - Evaluate
    
    /// Evaluates the given property with the given value.
    /// - Parameters:
    ///   - property: The property to evaluate.
    ///   - value: The value with which to call the property.
    ///   - interceptor: The property interceptor to use, or `nil` to create
    ///   a new interceptor.
    /// - Returns: The iteration result.
    @Reasync
    private static func evaluateProperty<T>(
        _       property    : (T) async throws -> Void,
        with    value       : T,
        using   interceptor : PropertyInterceptor?      = nil
    ) async -> IterationResult
    {
        let interceptor: PropertyInterceptor = interceptor ?? .init()
        
        interceptor.reset()
        
        var threwError  : Bool  = false
        var discarded   : Bool  = false
        
        await PropertyInterceptor.$current.withValue(interceptor)
        {
            do
            {
                try await property(value)
            }
            catch is DiscardError
            {
                discarded = true
            }
            catch
            {
                threwError = true
            }
        }
        
        if discarded
        {
            return .discarded
        }
        else if
            interceptor.didFail
            || threwError
        {
            return .failed
        }
        
        return .passed
    }
    
    
    
    // MARK: - Counterexample
    
    /// Creates the minimal counterexample for the given value.
    /// - Parameters:
    ///   - value: The failing value.
    ///   - shrink: The function to shrink the given value.
    ///   - precondition: The condition which generated values must satisfy.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - iteration: The iteraton at which the failure occurred.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The minimal counterexample for the given value.
    @Reasync
    private static func makeCounterexample<T>(
        value           : T,
        shrink          : @escaping (T) -> [T],
        precondition    : ((T) -> Bool)?,
        seed            : UInt64,
        iteration       : Int,
        property        : (T) async throws -> Void,
        options         : TestOptions
    ) async -> Counterexample<T>
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
                
                let result: IterationResult = await evaluateProperty(
                    property,
                    with: candidate
                )
                
                if result == .failed
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
        
        await PropertyInterceptor.$current.withValue(interceptor)
        {
            do
            {
                try await property(current)
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
    
    
    
    // MARK: - Support
    
    private static let logger = Logger(
        subsystem:  "swift-test-kit",
        category:   "PropertyRunner"
    )
    
    
    
    /// The result of a single property iteration.
    private enum IterationResult: Equatable, Sendable
    {
        /// The property passed.
        case passed
        
        /// The property failed.
        case failed
        
        /// The iteration was discarded.
        case discarded
    }
}
