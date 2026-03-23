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
    ///   - examples: The examples to test first.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        examples    : [T]                       = [],
        property    : (T) async throws -> Void,
        options     : TestOptions
    ) async -> PropertyResult<T> where T : Arbitrary
    {
        return await run(
            generate:       { context in T.arbitrary(using: context) },
            shrink:         { value in value.shrink() },
            mutate:         { value, context in value.mutate(using: context) },
            precondition:   nil,
            examples:       examples,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a property check using the given generator.
    /// - Parameters:
    ///   - generator: The generator.
    ///   - examples: The examples to test first.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        using generator : Generator<T>,
        examples        : [T]                       = [],
        property        : (T) async throws -> Void,
        options         : TestOptions
    ) async -> PropertyResult<T>
    {
        return await run(
            generate:       generator.generate,
            shrink:         generator.shrink,
            mutate:         generator.mutate,
            precondition:   nil,
            examples:       examples,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check.
    /// - Parameters:
    ///   - precondition: The condition which generated values must satisfy.
    ///   - examples: The examples to test first.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        where precondition  : @escaping (T) -> Bool,
        examples            : [T]                       = [],
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyResult<T> where T : Arbitrary
    {
        return await run(
            generate:       { context in T.arbitrary(using: context) },
            shrink:         { value in value.shrink() },
            mutate:         { value, context in value.mutate(using: context) },
            precondition:   precondition,
            examples:       examples,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check using the given generator.
    /// - Parameters:
    ///   - generator: The generator.
    ///   - precondition: The condition which generated values must satisfy.
    ///   - examples: The examples to test first.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    internal static func run<T>(
        using generator     : Generator<T>,
        where precondition  : @escaping (T) -> Bool,
        examples            : [T]                       = [],
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyResult<T>
    {
        return await run(
            generate:       generator.generate,
            shrink:         generator.shrink,
            mutate:         generator.mutate,
            precondition:   precondition,
            examples:       examples,
            property:       property,
            options:        options
        )
    }
    
    
    
    /// Runs a conditional property check.
    /// - Parameters:
    ///   - generate: The function to generate a value from the given context.
    ///   - shrink: The function to shrink the given value.
    ///   - mutate: The function to mutate the given value.
    ///   - precondition: The condition which generated values must satisfy.
    ///   - examples: The examples to test first.
    ///   - property: The property body.
    ///   - options: The options for testing.
    /// - Returns: The result of the property check.
    @Reasync
    private static func run<T>(
        generate            : (GenerationContext) -> T,
        shrink              : @escaping (T) -> [T],
        mutate              : (T, GenerationContext) -> T,
        precondition        : ((T) -> Bool)?,
        examples            : [T],
        property            : (T) async throws -> Void,
        options             : TestOptions
    ) async -> PropertyResult<T>
    {
        let opts            : PropertyOptions       = options.propertyOptions
        let seed            : UInt64                = opts.resolvedSeed
        let interceptor     : PropertyInterceptor   = .init()
        let context         : GenerationContext     = .init(seed: seed)
        let maxSize         : Int                   = opts.maxSize
        let maxDiscardRatio : Int                   = opts.maxDiscardRatio
        var iterations      : Int                   = opts.iterations
        var iteration       : Int                   = 0
        var discarded       : Int                   = 0
        var succeeded       : Int                   = 0
        var targetedMode    : Bool                  = false
        
        var targetPool = TargetPool<T>(capacity: opts.poolSize)
        
        let deadline: ContinuousClock.Instant?
            = opts.timeout.map { ContinuousClock.now.advanced(by: $0) }
        
        let trace       : Bool  = opts.diagnostics.contains(.trace)
        let slowness    : Bool  = opts.diagnostics.contains(.slowness)
        
        var iterationDurations: [(iteration: Int, duration: Duration)] = []
        
        
        
        let exampleResult: PropertyResult<T>? = await evaluateExamples(
            examples,
            with:   property,
            using:  interceptor,
            seed:   seed
        )
        
        if let exampleResult
        {
            return exampleResult
        }
        
        
        
        while succeeded < iterations
        {
            if
                let deadline,
                ContinuousClock.now >= deadline
            {
                let ratio: String = "\(succeeded) of \(iterations) iterations"
                
                logger.warning("Property-based test timed out after \(ratio)")
                break
            }
            
            iteration       += 1
            context.size    = succeeded * maxSize / iterations
            
            let iterationStart: ContinuousClock.Instant? = slowness
                ? .now
                : nil
            
            let value       : T
            let isMutated   : Bool
            
            if
                targetedMode,
                context.random(in: 0.0..<1.0) >= opts.explorationRatio,
                !targetPool.isEmpty
            {
                let base: T = targetPool.select(using: context)
                
                value       = mutate(base, context)
                isMutated   = true
            }
            else
            {
                value       = generate(context)
                isMutated   = false
            }
            
            
            
            if trace
            {
                let message: String
                    = "[\(iteration)/\(iterations)]"
                    + " generation size = \(context.size),"
                    + " \(isMutated ? "mutated" : "generated"):"
                    + " \(String(describing: value))"
                
                logger.info("\(message)")
            }
            
            
            
            if
                let precondition,
                !precondition(value)
            {
                discarded += 1
                
                if trace
                {
                    let message: String
                        = "[\(iteration)/\(iterations)] discarded:"
                        + " \(String(describing: value))"
                    
                    logger.info("\(message)")
                }
                
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
            
            let evaluationResult: EvaluationResult = await evaluateProperty(
                property,
                with:   value,
                using:  interceptor
            )
            
            switch evaluationResult
            {
                case .passed:
                    
                    if let iterationStart
                    {
                        iterationDurations.append(
                            (iteration, iterationStart.elapsed)
                        )
                    }
                    
                    if let target: Double = interceptor.target
                    {
                        if !targetedMode
                        {
                            targetedMode = true
                            
                            if trace
                            {
                                logger.info("Entering targeted mode")
                            }
                        }
                        
                        targetPool.insert(
                            value:      value,
                            target:     target
                        )
                    }
                    
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
                            options:        options,
                            deadline:       deadline
                        )
                    
                    return .failed(
                        counterexample:     counterexample,
                        distribution:       interceptor.distribution,
                        tableDistribution:  interceptor.tableDistribution
                    )
                    
                case .discarded:
                    
                    discarded += 1
                    
                    if trace
                    {
                        let message: String
                            = "[\(iteration)/\(iterations)] discarded (assume):"
                            + " \(String(describing: value))"
                        
                        logger.info("\(message)")
                    }
                    
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
        
        
        
        /// If the test timed out, `succeeded` is less than `iterations`.
        /// Otherwise, the two values are the same. Adjust `iterations` so if
        /// the test timed out, subsequent logic reflects the actual number
        /// of completed iterations.
        iterations = succeeded
        
        reportSlowIterations(
            iterationDurations,
            totalIterations: iterations
        )
        
        
        
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
                = PropertyResult<T>.formatDistribution(
                    interceptor.distribution,
                    iterations: iterations
                )
            
            let tableLines: [String]
                = PropertyResult<T>.formatTableDistribution(
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
    
    /// Evaluates the given pinned examples with the using the property body
    /// and interceptor.
    /// - Parameters:
    ///   - examples: The pinned examples to test.
    ///   - property: The property body.
    ///   - interceptor: The interceptor.
    ///   - seed: The seed used to initialize the random number generator.
    /// - Returns: The result of the property check, if an example failed.
    /// Otherwise, `nil` if all examples passed or were discarded.
    @Reasync
    private static func evaluateExamples<T>(
        _       examples    : [T],
        with    property    : (T) async throws -> Void,
        using   interceptor : PropertyInterceptor,
        seed                : UInt64
    ) async -> PropertyResult<T>?
    {
        for example in examples
        {
            let evaluationResult: EvaluationResult = await evaluateProperty(
                property,
                with:   example,
                using:  interceptor
            )
            
            switch evaluationResult
            {
                case
                    .passed,
                    .discarded:
                    
                    /// Pinned examples do not seed the target pool on success,
                    /// since they are fixed values, not mutation candidates.
                    ///
                    /// Pinned examples cannot be discarded by the precondition,
                    /// but the property body can throw a ``DiscardError``
                    /// from a failed assumption. Still finalize the iteration
                    /// in this case so it counts toward the distribution.
                    
                    interceptor.finalizeIteration()
                    
                case .failed:
                    
                    /// Run one more time to capture the assertion output.
                    let finalInterceptor    : PropertyInterceptor   = .init()
                    var thrownError         : Error?                = nil
                    
                    await FailureInterceptor.$current
                        .withValue(finalInterceptor)
                    {
                        do
                        {
                            try await property(example)
                        }
                        catch
                        {
                            thrownError = error
                        }
                    }
                    
                    let counterexample = Counterexample(
                        value:          example,
                        originalValue:  example,
                        seed:           seed,
                        iteration:      0,
                        shrinkSteps:    0,
                        failures:       finalInterceptor.failures,
                        failingStep:    nil,
                        error:          thrownError
                    )
                    
                    return .failed(
                        counterexample:     counterexample,
                        distribution:       interceptor.distribution,
                        tableDistribution:  interceptor.tableDistribution
                    )
            }
        }
        
        return nil
    }
    
    
    
    /// Evaluates the given property with the given value.
    /// - Parameters:
    ///   - property: The property to evaluate.
    ///   - value: The value with which to call the property.
    ///   - interceptor: The property interceptor to use, or `nil` to create
    ///   a new interceptor.
    /// - Returns: The evaluation result.
    @Reasync
    private static func evaluateProperty<T>(
        _       property    : (T) async throws -> Void,
        with    value       : T,
        using   interceptor : PropertyInterceptor?      = nil
    ) async -> EvaluationResult
    {
        let interceptor: PropertyInterceptor = interceptor ?? .init()
        
        interceptor.reset()
        
        var threwError  : Bool  = false
        var discarded   : Bool  = false
        
        await FailureInterceptor.$current.withValue(interceptor)
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
    ///   - deadline: The timeout deadline.
    /// - Returns: The minimal counterexample for the given value.
    @Reasync
    private static func makeCounterexample<T>(
        value           : T,
        shrink          : @escaping (T) -> [T],
        precondition    : ((T) -> Bool)?,
        seed            : UInt64,
        iteration       : Int,
        property        : (T) async throws -> Void,
        options         : TestOptions,
        deadline        : ContinuousClock.Instant?
    ) async -> Counterexample<T>
    {
        var current             : T     = value
        var steps               : Int   = 0
        var candidatesEvaluated : Int   = 0
        var candidatesFiltered  : Int   = 0
        var candidatesPassed    : Int   = 0
        
        let trace: Bool = options.propertyOptions.diagnostics.contains(.trace)
        
        while steps < options.propertyOptions.maxShrinkSteps
        {
            if
                let deadline,
                ContinuousClock.now >= deadline
            {
                break
            }
            
            let candidates  : [T]   = shrink(current)
            var improved    : Bool  = false
            
            candidateLoop: for candidate in candidates
            {
                if
                    let precondition,
                    !precondition(candidate)
                {
                    candidatesFiltered += 1
                    continue candidateLoop
                }
                
                let evaluationResult: EvaluationResult
                    = await evaluateProperty(
                        property,
                        with: candidate
                    )
                
                candidatesEvaluated += 1
                
                switch evaluationResult
                {
                    case .failed:
                        
                        improved    = true
                        current     = candidate
                        steps       += 1
                        
                        if trace
                        {
                            let message: String
                                = "Shrink step \(steps):"
                                + " \(String(describing: candidate))"
                            
                            logger.info("\(message)")
                        }
                        
                        /// Start again with a smaller value.
                        break candidateLoop
                        
                    case
                        .passed,
                        .discarded:
                        
                        candidatesPassed += 1
                }
            }
            
            if !improved
            {
                if
                    trace,
                    steps > 0
                {
                    logger.info("Shrinking complete at step \(steps)")
                }
                
                break
            }
        }
        
        
        
        if options.propertyOptions.diagnostics.contains(.shrinking)
        {
            reportShrinkEffectiveness(
                steps:              steps,
                evaluated:          candidatesEvaluated,
                filtered:           candidatesFiltered,
                passed:             candidatesPassed,
                hasPrecondition:    precondition != nil
            )
        }
        
        
        
        /// Run one more time to capture the assertion output.
        let interceptor : PropertyInterceptor   = .init()
        var thrownError : Error?                = nil
        
        await FailureInterceptor.$current.withValue(interceptor)
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
            failingStep:    nil,
            error:          thrownError
        )
    }
    
    
    
    // MARK: - Support
    
    private static let logger = Logger(
        subsystem:  "swift-test-kit",
        category:   "PropertyRunner"
    )
    
    
    
    /// The result of evaluating a property.
    private enum EvaluationResult: Equatable, Sendable
    {
        /// The property passed.
        case passed
        
        /// The property failed.
        case failed
        
        /// The iteration was discarded.
        case discarded
    }
    
    
    
    /// Reports slow iterations.
    /// - Parameters:
    ///   - durations: The iteration durations to check.
    ///   - totalIterations: The total number of iterations.
    internal static func reportSlowIterations(
        _ durations     : [(iteration: Int, duration: Duration)],
        totalIterations : Int
    )
    {
        guard durations.count >= 10
        else
        {
            return
        }
        
        let sorted  : [Duration]    = durations.map { $0.duration }.sorted()
        let median  : Duration      = sorted[sorted.count / 2 ]
        
        guard median > .zero
        else
        {
            return
        }
        
        let threshold   : Duration  = median * 10
        var lines       : [String]  = []
        
        for entry in durations
        {
            guard entry.duration > threshold
            else
            {
                continue
            }
            
            let ratio = Int(entry.duration.nanoseconds / median.nanoseconds)
            
            lines.append(
                "[\(entry.iteration)/\(totalIterations)]:"
                + "  \(entry.duration.readable) (ratio: \(ratio)x)"
            )
        }
        
        guard !lines.isEmpty
        else
        {
            return
        }
        
        let header: String
            = "Slow iteration\(lines.count == 1 ? "" : "s") detected"
            + " (median: \(median.readable)):"
        
        let message: String
            = ([header] + lines.map { "    " + $0 }).joined(separator: "\n")
        
        logger.warning("\(message)")
    }
    
    
    
    /// Reports ineffective shrinking.
    /// - Parameters:
    ///   - phase: The shrinking phase to report. Pass `nil` for generic.
    ///   - steps: The number of shrink steps.
    ///   - evaluated: The evaluated shrink candidates.
    ///   - filtered: The filtered shrink candidates.
    ///   - passed: The passed shrink caididates.
    ///   - hasPrecondition: Whether there was a precondition.
    internal static func reportShrinkEffectiveness(
        phase           : String?   = nil,
        steps           : Int,
        evaluated       : Int,
        filtered        : Int,
        passed          : Int,
        hasPrecondition : Bool
    )
    {
        guard
            evaluated > 0
            || filtered > 0
        else
        {
            return
        }
        
        var lines: [String] = []
        
        if steps == 0
        {
            let label: String = phase == nil
                ? "Shrinking"
                : "\(phase!) shrinking"
            
            lines.append(
                "\(label) produced no improvements"
                + " (\(evaluated) candidate\(evaluated == 1 ? "" : "s")"
                + " evaluated, none reproduced the failure)"
            )
        }
        
        if
            hasPrecondition,
            filtered > 0
        {
            let total: Int = evaluated + filtered
            
            let percentage = Int(Double(filtered) / Double(total) * 100)
            
            if percentage >= 50
            {
                lines.append(
                    "\(filtered)/\(total) shrink"
                    + " candidate\(total == 1 ? "" : "s")"
                    + " (\(percentage)%) filtered by precondition"
                )
            }
        }
        
        guard !lines.isEmpty
        else
        {
            return
        }
        
        for message in lines
        {
            logger.warning("\(message)")
        }
    }
}
