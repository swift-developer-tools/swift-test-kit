//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog



private let logger = Logger(
    subsystem:  "swift-test-kit",
    category:   "StatefulRunner"
)



/// Runs stateful property-based tests.
internal struct StatefulRunner<C> where C : Stateful
{
    // MARK: - Run
    
    /// Runs a stateful property check.
    /// - Parameters:
    ///   - command: The command type.
    ///   - model: A factory that creates a new model instance.
    ///   - system: A factory that creates a new system instance.
    ///   - invariant: An optional closure that checks invariants after each
    ///   command.
    ///   - options: The options for testing.
    /// - Returns: The result of the stateful property check.
    internal static func run(
        command     : C.Type,
        model       : () -> C.Model,
        system      : () -> C.System,
        invariant   : ((C.Model, C.System) async throws -> Void)?,
        options     : TestOptions
    ) async -> StatefulResult<C>
    {
        let opts: PropertyOptions = options.propertyOptions
        
        let seed: UInt64 = opts.seed
            ?? .random(in: UInt64.min...UInt64.max)
        
        let interceptor         : PropertyInterceptor   = .init()
        let context             : GenerationContext     = .init(seed: seed)
        let maxSize             : Int                   = opts.maxSize
        let maxDiscardRatio     : Int                   = opts.maxDiscardRatio
        let maxCommandCount     : Int                   = opts.maxCommandCount
        var iterations          : Int                   = opts.iterations
        var iteration           : Int                   = 0
        var discarded           : Int                   = 0
        var succeeded           : Int                   = 0
        var commandPresence     : [String : Int]        = [:]
        var commandFrequency    : [String : Int]        = [:]
        var sequenceCounts      : [Int]                 = []
        
        let deadline: ContinuousClock.Instant?
            = opts.timeout.map { ContinuousClock.now.advanced(by: $0) }
        
        let verbose: Bool = opts.diagnostics.contains(.verbose)
        
        
        
        while succeeded < iterations
        {
            if
                let deadline,
                ContinuousClock.now >= deadline
            {
                let ratio: String = "\(succeeded) of \(iterations) iterations"
                
                logger.warning("Stateful test timed out after \(ratio)")
                break
            }
            
            iteration       += 1
            context.size    = succeeded * maxSize / iterations
            
            /// When `succeeded` is `0`, nothing is generated and an iteration
            /// is wasted. Start from `1` instead. ``PropertyRunner`` has a
            /// similar pattern, but a size of `0` there still generates a
            /// usable (minimal) value.
            let sequenceCount: Int
                = max(1, succeeded * maxCommandCount / iterations)
            
            let commands: [C] = generateSequence(
                count:      sequenceCount,
                model:      model,
                context:    context
            )
            
            if verbose
            {
                let descriptions: String = commands
                    .map { String(describing: $0) }
                    .joined(separator: ", ")
                
                let message: String
                    = "[\(iteration)/\(iterations)]"
                    + " generation size = \(context.size),"
                    + " \(commands.count)"
                    + " command\(commands.count == 1 ? "" : "s")"
                    + " [\(descriptions)]"
                
                logger.info("\(message)")
            }
            
            let result: ReplayResult = await replaySequence(
                commands:               commands,
                model:                  model,
                system:                 system,
                invariant:              invariant,
                interceptor:            interceptor,
                checkPreconditions:     false
            )
            
            switch result
            {
                case .passed:
                    
                    interceptor.finalizeIteration()
                    
                    succeeded += 1
                    
                    accumulateStatistics(
                        commands:   commands,
                        presence:   &commandPresence,
                        frequency:  &commandFrequency,
                        counts:     &sequenceCounts,
                        options:    opts.statistics
                    )
                    
                case .failed:
                    
                    let counterexample: Counterexample<[C]>
                        = await makeCounterexample(
                            commands:   commands,
                            model:      model,
                            system:     system,
                            invariant:  invariant,
                            seed:       seed,
                            iteration:  iteration,
                            options:    options,
                            deadline:   deadline
                        )
                    
                    let result: PropertyResult<[C]> = .failed(
                        counterexample:     counterexample,
                        distribution:       interceptor.distribution,
                        tableDistribution:  interceptor.tableDistribution
                    )
                    
                    let statistics: String? = formatStatistics(
                        presence:   commandPresence,
                        frequency:  commandFrequency,
                        counts:     sequenceCounts,
                        succeeded:  succeeded,
                        options:    opts.statistics
                    )
                    
                    return StatefulResult(
                        property:       result,
                        statistics:     statistics
                    )
                    
                case .discarded:
                    
                    discarded += 1
                    
                    if verbose
                    {
                        logger.info("[\(iteration)/\(iterations)] discarded")
                    }
                    
                    if discarded > maxDiscardRatio * iterations
                    {
                        let result: PropertyResult<[C]> = .exhausted(
                            discarded:          discarded,
                            succeeded:          succeeded,
                            ratio:              maxDiscardRatio,
                            seed:               seed,
                            distribution:       interceptor.distribution,
                            tableDistribution:  interceptor.tableDistribution
                        )
                        
                        let statistics: String? = formatStatistics(
                            presence:   commandPresence,
                            frequency:  commandFrequency,
                            counts:     sequenceCounts,
                            succeeded:  succeeded,
                            options:    opts.statistics
                        )
                        
                        return StatefulResult(
                            property:       result,
                            statistics:     statistics
                        )
                    }
                    
                case .invalid:
                    
                    /// This should not occur since preconditions are verified
                    /// during sequence generation. If it does occur, it means
                    /// ``Stateful/advance(model:)`` and
                    /// ``Stateful/run(model:system:)`` may advance the model
                    /// differently. Treat it as a discard.
                    logger.warning("Precondition failed during replay")
                    
                    discarded += 1
                    
                    if verbose
                    {
                        logger.info("[\(iteration)/\(iterations)] invalid")
                    }
                    
                    if discarded > maxDiscardRatio * iterations
                    {
                        let result: PropertyResult<[C]> = .exhausted(
                            discarded:          discarded,
                            succeeded:          succeeded,
                            ratio:              maxDiscardRatio,
                            seed:               seed,
                            distribution:       interceptor.distribution,
                            tableDistribution:  interceptor.tableDistribution
                        )
                        
                        let statistics: String? = formatStatistics(
                            presence:   commandPresence,
                            frequency:  commandFrequency,
                            counts:     sequenceCounts,
                            succeeded:  succeeded,
                            options:    opts.statistics
                        )
                        
                        return StatefulResult(
                            property:       result,
                            statistics:     statistics
                        )
                    }
            }
        }
        
        
        
        /// If the test timed out, `succeeded` is less than `iterations`.
        /// Otherwise, the two values are the same. Adjust `iterations` so if
        /// the test timed out, subsequent logic reflects the actual number
        /// of completed iterations.
        iterations = succeeded
        
        
        
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
            let result: PropertyResult<[C]> = .coverageNotMet(
                unmet:              unmet,
                iterations:         iterations,
                seed:               seed,
                distribution:       interceptor.distribution,
                tableDistribution:  interceptor.tableDistribution
            )
            
            let statistics: String? = formatStatistics(
                presence:   commandPresence,
                frequency:  commandFrequency,
                counts:     sequenceCounts,
                succeeded:  succeeded,
                options:    opts.statistics
            )
            
            return StatefulResult(
                property:       result,
                statistics:     statistics
            )
        }
        
        
        
        var loggedDistribution: Bool = false
        
        let header: String =
            "Stateful test passed \(iterations)"
            + " iteration\(iterations == 1 ? "" : "s")"
        
        if
            !interceptor.distribution.isEmpty
            || !interceptor.tableDistribution.isEmpty
        {
            var flatLines: [String]
                = PropertyResult<[C]>.formatDistribution(
                    interceptor.distribution,
                    iterations: iterations
                )
            
            let tableLines: [String]
                = PropertyResult<[C]>.formatTableDistribution(
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
            
            logger.info("\(header)\n\(summary)")
            
            loggedDistribution = true
        }
        
        
        
        let result: PropertyResult<[C]> = .passed(
            iterations:         iterations,
            seed:               seed,
            distribution:       interceptor.distribution,
            tableDistribution:  interceptor.tableDistribution
        )
        
        let statistics: String? = formatStatistics(
            presence:   commandPresence,
            frequency:  commandFrequency,
            counts:     sequenceCounts,
            succeeded:  succeeded,
            options:    opts.statistics
        )
        
        if let statistics
        {
            if loggedDistribution
            {
                logger.info("\n\(statistics)")
            }
            else
            {
                logger.info("\(header)\n\(statistics)")
            }
        }
        
        return StatefulResult(
            property:       result,
            statistics:     statistics
        )
    }
    
    
    
    // MARK: - Generate
    
    /// Generates a command sequence of the given count.
    ///
    /// Commands are generated using ``Stateful/arbitrary(using:model:)`` and
    /// validated against ``Stateful/precondition(model:)``. The model is
    /// advanced after each command using ``Stateful/next(model:)``.
    ///
    /// - Precondition: A valid command must be produced within 1,000 attempts
    /// at each step.
    ///
    /// - Parameters:
    ///   - count: The number of commands to generate.
    ///   - model: A factory that creates a new model instance.
    ///   - context: The generation context.
    /// - Returns: The generated command sequence.
    private static func generateSequence(
        count   : Int,
        model   : () -> C.Model,
        context : GenerationContext
    ) -> [C]
    {
        var currentModel    : C.Model   = model()
        var commands        : [C]       = []
        
        commands.reserveCapacity(count)
        
        for _ in 0..<count
        {
            var foundValidCommand: Bool = false
            
            for _ in 0..<1000
            {
                let command = C.arbitrary(
                    using:  context,
                    model:  currentModel
                )
                
                if command.precondition(model: currentModel)
                {
                    commands.append(command)
                    command.advance(model: &currentModel)
                    
                    foundValidCommand = true
                    break
                }
            }
            
            if !foundValidCommand
            {
                preconditionFailure(
                    "Stateful command generation failed to produce a valid"
                    + " command after 1000 attempts. The precondition may be"
                    + " too restrictive for the current model state, or"
                    + " arbitrary(using:model:) is not generating commands"
                    + " compatible with the model"
                )
            }
        }
        
        return commands
    }
    
    
    
    // MARK: - Replay
    
    /// Replays the given command sequence against new model and system
    /// instances.
    /// - Parameters:
    ///   - commands: The command sequence to replay.
    ///   - model: A factory that creates a new model instance.
    ///   - system: A factory that creates a new system instance.
    ///   - invariant: An optional closure that checks invariants after each
    ///   command.
    ///   - interceptor: The property interceptor to use.
    ///   - checkPreconditions: Whether to check preconditions before each
    ///   command. Pass `true` when replaying modified sequences during
    ///   shrinking.
    /// - Returns: The replay result.
    private static func replaySequence(
        commands            : [C],
        model               : () -> C.Model,
        system              : () -> C.System,
        invariant           : ((C.Model, C.System) async throws -> Void)?,
        interceptor         : PropertyInterceptor,
        checkPreconditions  : Bool
    ) async -> ReplayResult
    {
        interceptor.reset()
        
        var currentModel    : C.Model   = model()
        var currentSystem   : C.System  = system()
        
        for (index, command) in commands.enumerated()
        {
            if checkPreconditions
            {
                if !command.precondition(model: currentModel)
                {
                    return .invalid
                }
            }
            
            
            
            var discarded   : Bool      = false
            var thrownError : Error?    = nil
            
            await FailureInterceptor.$current.withValue(interceptor)
            {
                do
                {
                    try await command.run(
                        model:      &currentModel,
                        system:     &currentSystem
                    )
                }
                catch is DiscardError
                {
                    discarded = true
                }
                catch
                {
                    thrownError = error
                }
            }
            
            if discarded
            {
                return .discarded
            }
            
            if
                interceptor.didFail
                || thrownError != nil
            {
                let failure = ReplayFailure(
                    step:       index + 1,
                    failures:   interceptor.failures,
                    error:      thrownError
                )
                
                return .failed(failure)
            }
            
            
            
            let postconditionSuccess: Bool = command.postcondition(
                model:      currentModel,
                system:     currentSystem
            )
            
            if !postconditionSuccess
            {
                interceptor.recordFailure(
                    message:    "Postcondition failed after command:"
                                + " \(command) (step \(index + 1))",
                    fileID:     "",
                    file:       "",
                    line:       0,
                    column:     0
                )
                
                let failure = ReplayFailure(
                    step:       index + 1,
                    failures:   interceptor.failures,
                    error:      nil
                )
                
                return .failed(failure)
            }
            
            
            
            if let invariant
            {
                var discarded   : Bool      = false
                var thrownError : Error?    = nil
                
                await FailureInterceptor.$current.withValue(interceptor)
                {
                    do
                    {
                        try await invariant(
                            currentModel,
                            currentSystem
                        )
                    }
                    catch is DiscardError
                    {
                        discarded = true
                    }
                    catch
                    {
                        thrownError = error
                    }
                }
                
                if discarded
                {
                    return .discarded
                }
                
                if
                    interceptor.didFail
                    || thrownError != nil
                {
                    let failure = ReplayFailure(
                        step:       index + 1,
                        failures:   interceptor.failures,
                        error:      thrownError
                    )
                    
                    return .failed(failure)
                }
            }
        }
        
        return .passed
    }
    
    
    
    /// Replays the given moden through the given commands.
    /// - Parameters:
    ///   - model: The model to replay.
    ///   - commands: The commands to use.
    /// - Returns: The replayed model.
    private static func replayModel(
        _ model             : () -> C.Model,
        through commands    : ArraySlice<C>
    ) -> C.Model?
    {
        var currentModel: C.Model = model()
        
        for command in commands
        {
            if !command.precondition(model: currentModel)
            {
                /// The sequence is in an inconsistent state. This should not
                /// happen since removal shrinking already validated the
                /// preconditions.
                return nil
            }
            
            command.advance(model: &currentModel)
        }
        
        return currentModel
    }
    
    
    
    // MARK: - Counterexample
    
    /// Creates the counterexample for the given failing command sequence.
    /// - Parameters:
    ///   - commands: The failing command sequence.
    ///   - model: A factory that creates a new model instance.
    ///   - system: A factory that creates a new system instance.
    ///   - invariant: An optional closure that checks invariants after each
    ///   command.
    ///   - seed: The seed used to initialize the random number generator.
    ///   - iteration: The iteration at which the failure occurred.
    ///   - options: The options for testing.
    ///   - deadline: The timeout deadline.
    /// - Returns: The counterexample for the given failing command sequence.
    private static func makeCounterexample(
        commands    : [C],
        model       : () -> C.Model,
        system      : () -> C.System,
        invariant   : ((C.Model, C.System) async throws -> Void)?,
        seed        : UInt64,
        iteration   : Int,
        options     : TestOptions,
        deadline    : ContinuousClock.Instant?
    ) async -> Counterexample<[C]>
    {
        let shrunken: ShrunkenSequence = await shrinkSequence(
            commands:   commands,
            model:      model,
            system:     system,
            invariant:  invariant,
            options:    options,
            deadline:   deadline
        )
        
        /// Run one more time to capture the assertion output.
        let interceptor: PropertyInterceptor = .init()
        
        let replayResult: ReplayResult = await replaySequence(
            commands:               shrunken.commands,
            model:                  model,
            system:                 system,
            invariant:              invariant,
            interceptor:            interceptor,
            checkPreconditions:     false
        )
        
        var replayFailure: ReplayFailure? = nil
        
        if case let .failed(failure) = replayResult
        {
            replayFailure = failure
        }
        
        return Counterexample(
            value:          shrunken.commands,
            originalValue:  commands,
            seed:           seed,
            iteration:      iteration,
            shrinkSteps:    shrunken.shrinkSteps,
            failures:       replayFailure?.failures ?? [],
            failingStep:    replayFailure?.step ?? shrunken.commands.count,
            error:          replayFailure?.error
        )
    }
    
    
    
    // MARK: - Shrink
    
    /// Shrinks the given failing command sequence.
    ///
    /// This applies two layers of shrinking:
    ///
    /// 1. Removal shrinking: Binary search removal of command chunks.
    /// 2. Argument shrinking: Shrinking of individual command arguments.
    ///
    /// Each successful shrink (whether removal or argument substitution)
    /// counts as a step toward ``PropertyOptions/maxShrinkSteps``.
    ///
    /// - Parameters:
    ///   - commands: The failing command sequence to shrink.
    ///   - model: A factory that creates a new model instance.
    ///   - system: A factory that creates a new system instance.
    ///   - invariant: An optional closure that checks invariants after each
    ///   command.
    ///   - options: The options for testing.
    ///   - deadline: The timeout deadline.
    /// - Returns: The shrunken command sequence.
    private static func shrinkSequence(
        commands    : [C],
        model       : () -> C.Model,
        system      : () -> C.System,
        invariant   : ((C.Model, C.System) async throws -> Void)?,
        options     : TestOptions,
        deadline    : ContinuousClock.Instant?
    ) async -> ShrunkenSequence
    {
        let maxSteps: Int = options.propertyOptions.maxShrinkSteps
        
        let interceptor : PropertyInterceptor   = .init()
        var current     : [C]                   = commands
        var steps       : Int                   = 0
        
        let pastDeadline: () -> Bool =
        {
            if let deadline
            {
                return ContinuousClock.now >= deadline
            }
            
            return false
        }
        
        let verbose: Bool = options.propertyOptions.diagnostics
            .contains(.verbose)
        
        
        
        /// Removal shrinking.
        var chunkSize: Int = current.count / 2
        
        while
            chunkSize >= 1,
            steps < maxSteps
        {
            var offset      : Int   = 0
            var improved    : Bool  = false
            
            while
                offset + chunkSize <= current.count,
                steps < maxSteps,
                !pastDeadline()
            {
                var candidate: [C] = current
                
                candidate.removeSubrange(offset..<(offset + chunkSize))
                
                let replayResult: ReplayResult = await replaySequence(
                    commands:               candidate,
                    model:                  model,
                    system:                 system,
                    invariant:              invariant,
                    interceptor:            interceptor,
                    checkPreconditions:     true
                )
                
                if case .failed = replayResult
                {
                    current     = candidate
                    steps       += 1
                    improved    = true
                    
                    if verbose
                    {
                        let message: String
                            = "Removal shrink step \(steps): \(current.count)"
                            + " command\(current.count == 1 ? "" : "s"),"
                            + " chunk size = \(chunkSize)"
                        
                        logger.info("\(message)")
                    }
                    
                    /// Restart with a new chunk size based on the shorter
                    /// sequence.
                    break
                }
                
                offset += chunkSize
            }
            
            if improved
            {
                chunkSize = current.count / 2
            }
            else
            {
                chunkSize = chunkSize / 2
            }
        }
        
        
        
        /// Argument shrinking.
        var index: Int = 0
        
        while
            index < current.count,
            steps < maxSteps,
            !pastDeadline()
        {
            let modelAtIndex: C.Model? = replayModel(
                model,
                through: current[..<index]
            )
            
            guard let modelAtIndex
            else
            {
                index += 1
                continue
            }
            
            let candidates  : [C]   = current[index].shrink(model: modelAtIndex)
            var improved    : Bool  = false
            
            for candidate in candidates
            {
                if steps >= maxSteps
                {
                    break
                }
                
                var sequence: [C] = current
                
                sequence[index] = candidate
                
                let replayResult: ReplayResult = await replaySequence(
                    commands:               sequence,
                    model:                  model,
                    system:                 system,
                    invariant:              invariant,
                    interceptor:            interceptor,
                    checkPreconditions:     true
                )
                
                if case .failed = replayResult
                {
                    current     = sequence
                    steps       += 1
                    improved    = true
                    
                    if verbose
                    {
                        let message: String
                            = "Argument shrink step \(steps):"
                            + " replaced command at index \(index)"
                            + " with \(String(describing: candidate))"
                        
                        logger.info("\(message)")
                    }
                    
                    /// Restart from the start of the sequence.
                    break
                }
            }
            
            if improved
            {
                index = 0
            }
            else
            {
                index += 1
            }
        }
        
        
        
        if
            verbose,
            steps > 0
        {
            let message: String 
                = "Shrinking complete at step \(steps)"
                + " (\(current.count) command\(current.count == 1 ? "" : "s"))"
            
            logger.info("\(message)")
        }
        
        return ShrunkenSequence(
            commands:       current,
            shrinkSteps:    steps
        )
    }
    
    
    
    // MARK: - Statistics
    
    /// Accumulates statistics for the given commands, based on the given
    /// options.
    /// - Parameters:
    ///   - commands: The commands.
    ///   - presence: The accumulated command presence statistics.
    ///   - frequency: The accumulated command frequency statistics.
    ///   - counts: The accumulated command sequence count statistics.
    ///   - options: The options for reporting command statistics.
    private static func accumulateStatistics(
        commands    : [C],
        presence    : inout [String : Int],
        frequency   : inout [String : Int],
        counts      : inout [Int],
        options     : CommandStatistics
    )
    {
        guard !options.isEmpty
        else
        {
            return
        }
        
        if options.contains(.sequenceCount)
        {
            counts.append(commands.count)
        }
        
        guard
            options.contains(.presence)
            || options.contains(.frequency)
        else
        {
            return
        }
        
        var names: Set<String> = []
        
        for command in commands
        {
            let name: String = name(of: command)
            
            if
                options.contains(.presence),
                names.insert(name).inserted
            {
                presence[name, default: 0] += 1
            }
            
            if options.contains(.frequency)
            {
                frequency[name, default: 0] += 1
            }
        }
    }
    
    
    
    /// Gets the name of the given command.
    /// - Parameter command: The command.
    /// - Returns: The name of the given command.
    private static func name(
        of command: C
    ) -> String
    {
        if let label: String
            = Mirror(reflecting: command).children.first?.label
        {
            return label
        }
        
        return String(describing: command)
    }
    
    
    
    /// Formats command statistics based on the given accumulators.
    /// - Parameters:
    ///   - presence: The accumulated command presence statistics.
    ///   - frequency: The accumulated command frequency statistics.
    ///   - counts: The accumulated command sequence count statistics.
    ///   - succeeded: The number of successful iterations.
    ///   - options: The options for reporting command statistics.
    /// - Returns: The formatted command statistics, or `nil` if no statistics
    /// are enabled.
    private static func formatStatistics(
        presence    : [String : Int],
        frequency   : [String : Int],
        counts      : [Int],
        succeeded   : Int,
        options     : CommandStatistics
    ) -> String?
    {
        guard !options.isEmpty
        else
        {
            return nil
        }
        
        
        
        var sections: [String] = []
        
        if
            options.contains(.presence),
            !presence.isEmpty
        {
            let header: String 
                = "Command presence (\(succeeded)"
                + " iteration\(succeeded == 1 ? "" : "s")):"
            
            let lines: [String] = PropertyResult<[C]>.formatDistribution(
                presence,
                iterations: succeeded
            )
            
            sections.append(([header] + lines).joined(separator: "\n"))
        }
        
        
        
        if
            options.contains(.frequency),
            !frequency.isEmpty
        {
            let total: Int = frequency.values.reduce(0, +)
            
            let header: String
                = "Command frequency (\(total)"
                + " command\(total == 1 ? "" : "s")):"
            
            let lines: [String] = PropertyResult<[C]>.formatDistribution(
                frequency,
                iterations: total
            )
            
            sections.append(([header] + lines).joined(separator: "\n"))
        }
        
        
        
        if
            options.contains(.sequenceCount),
            !counts.isEmpty
        {
            let minimum : Int   = counts.min()!
            let maximum : Int   = counts.max()!
            
            let average = Double(counts.reduce(0, +)) / Double(counts.count)
            
            let minString   = String(minimum)
            let maxString   = String(maximum)
            
            let averageString: String = average == average.rounded()
                ? String(Int(average))
                : String(format: "%.1f", average)
            
            let digitWidth: Int = max(
                max(minString.count, maxString.count),
                averageString.count
            )
            
            let minPadding = String(
                repeating:  " ",
                count:      digitWidth - minString.count + 1
            )
            
            let maxPadding = String(
                repeating:  " ",
                count:      digitWidth - maxString.count + 1
            )
            
            let averagePadding = String(
                repeating:  " ",
                count:      digitWidth - averageString.count + 1
            )
            
            var lines: [String] = []
            
            lines.append(
                "Command sequence count (\(succeeded)"
                + " iteration\(succeeded == 1 ? "" : "s")):"
            )
            
            lines.append("    Minimum:\(minPadding)\(minString)")
            lines.append("    Maximum:\(maxPadding)\(maxString)")
            lines.append("    Average:\(averagePadding)\(averageString)")
            
            sections.append(lines.joined(separator: "\n"))
        }
        
        
        
        if sections.isEmpty
        {
            return nil
        }
        
        return sections.joined(separator: "\n\n")
    }
    
    
    
    
    // MARK: - Support
    
    /// The result of replaying a command sequence.
    private enum ReplayResult: Sendable
    {
        /// All commands passed.
        case passed
        
        /// A command or invariant failed.
        case failed(ReplayFailure)
        
        /// The sequence was discarded.
        case discarded
        
        /// A precondition failed during replay.
        ///
        /// This indicates that the candidate sequence is invalid (used during
        /// shrinking).
        case invalid
    }
    
    
    
    /// A replay failure.
    private struct ReplayFailure: Sendable
    {
        /// The 1-indexed step at which the failure occurred.
        let step        : Int
        
        /// The assertion failures from the final run with the shrunken value.
        let failures    : [InterceptedFailure]
        
        /// The error thrown by the property body.
        let error       : Error?
    }
    
    
    
    /// A shrunken command sequence.
    private struct ShrunkenSequence: Sendable
    {
        /// The shrunken command sequence.
        let commands    : [C]
        
        /// The number of shrink steps performed.
        let shrinkSteps : Int
    }
}
