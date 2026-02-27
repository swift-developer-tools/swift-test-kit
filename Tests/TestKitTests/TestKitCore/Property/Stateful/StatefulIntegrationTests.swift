//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class StatefulIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Passing
    
    func testPassingWithInvariant() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
            }
        )
    }
    
    
    
    func testPassingWithoutInvariant() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options
        )
    }
    
    
    
    func testPassingWithPrecondition() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    StackCommand.self,
            options:    Self.options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
                TKAssertGreaterThanOrEqual(model, 0)
            }
        )
    }
    
    
    
    func testZeroIterationsVacuouslyPasses() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     0,
            seed:           Self.seed
        )
        
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    options
        )
    }
    
    
    
    func testSingleIterationSuccess() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
            }
        )
    }
    
    
    
    func testPreconditionConstrainedCommand() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    BoundCommand.self,
            options:    Self.options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
                TKAssertLessThanOrEqual(model, BoundCommand.bound)
            }
        )
    }
    
    
    
    // MARK: - Failing
    
    func testInvariantFailure() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    Self.options,
                invariant:
                {
                    model, _ async in
                    
                    TKAssertLessThan(model, 3)
                }
            )
        }
    }
    
    
    
    func testRunFailure() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunFailCommand.self,
                options:    Self.options
            )
        }
    }
    
    
    
    func testRunThrowFailure() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunThrowCommand.self,
                options:    Self.options
            )
        }
    }
    
    
    
    func testInvariantThrowFailure() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    Self.options,
                invariant:  { _, _ async throws in throw TestError() }
            )
        }
    }
    
    
    
    func testSingleIterationFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, system async in
                    
                    TKAssertNotEqual(model, system)
                }
            )
        }
    }
    
    
    
    func testRunFailThrow() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunFailThrowCommand.self,
                options:    Self.options
            )
        }
    }
    
    
    
    func testDivergentAdvanceAndRun() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    DivergentCommand.self,
                options:    Self.options,
                invariant:
                {
                    model, _ async in
                    
                    TKAssertLessThan(model, DivergentCommand.threshold)
                }
            )
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testArgumentShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     1,
            seed:               Self.seed
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    AmountCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKAssertLessThanOrEqual(model, 5)
                }
            )
        }
    }
    
    
    
    func testRemovalShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKAssertLessThanOrEqual(model, 3)
                }
            )
        }
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustionFromRunDiscard() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    Self.options
            )
        }
    }
    
    
    
    func testExhaustionFromInvariantDiscard() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    Self.options,
                invariant:  { _, _ async throws in throw DiscardError() }
            )
        }
    }
    
    
    
    // MARK: - Coverage
    
    func testCoverageMet() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options,
            invariant:
            {
                _, _ async in
                
                TKCover(50, "always", when: true)
            }
        )
    }
    
    
    
    func testCoverageNotMet() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    CoverNeverCommand.self,
                options:    Self.options
            )
        }
    }
    
    
    
    func testTableCoverageMet() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options,
            invariant:
            {
                _, _ async in
                
                TKTabulate("table", "always")
                TKCoverTable("table", (100, "always"))
            }
        )
    }
    
    
    
    func testTableCoverageNotMet() async
    {
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    Self.options,
                invariant:
                {
                    _, _ async in
                    
                    TKCoverTable("table", (100, "never"))
                }
            )
        }
    }
    
    
    
    // MARK: - Classify
    
    func testClassificationPassThrough() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    ClassifyCommand.self,
            options:    Self.options
        )
    }
    
    
    
    // MARK: - Concurrency
    
    func testConcurrentIsolation() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        async let a: Void = TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
            }
        )
        
        async let b: Void = TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    StackCommand.self,
            options:    options,
            invariant:
            {
                model, system async in
                
                TKAssertEqual(model, system)
                TKAssertGreaterThanOrEqual(model, 0)
            }
        )
        
        await a
        await b
    }
    
    
    
    // MARK: - ForAll
    
    func testForAllPassingInsideInvariant() async
    {
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options,
            invariant:
            {
                _, _ async in
                
                await TKForAll(options: forAllOptions)
                {
                    (n: Int) async in
                    
                    TKAssertEqual(n + 0, n)
                }
            }
        )
    }
    
    
    
    func testForAllGeneratorPassingInsideInvariant() async
    {
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    IncrementCommand.self,
            options:    Self.options,
            invariant:
            {
                _, _ async in
                
                await TKForAll(
                    using:      Generator<Int>.integer(in: 1...100),
                    options:    forAllOptions
                )
                {
                    (n: Int) async in
                    
                    TKAssertGreaterThan(n, 0)
                }
            }
        )
    }
    
    
    
    func testForAllFailingInsideInvariant() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                }
            )
        }
    }
    
    
    
    func testForAllFailingAtThresholdInsideInvariant() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 3
                    {
                        await TKForAll(options: forAllOptions)
                        {
                            (_: Int) async in
                            
                            TKAssertTrue(false)
                        }
                    }
                }
            )
        }
    }
    
    
    
    func testForAllPassingInsideRun() async
    {
        await TKStateful(
            model:      { 0 },
            system:     { 0 },
            command:    ForAllPassCommand.self,
            options:    Self.options
        )
    }
    
    
    
    func testForAllFailingInsideRun() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    ForAllFailCommand.self,
                options:    statefulOptions
            )
        }
    }
    
    
    
    func testForAllFailingInsideRunWithShrinking() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    ForAllFailCommand.self,
                options:    statefulOptions
            )
        }
    }
    
    
    
    func testMultipleForAllsFirstPassingSecondFailing() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions1: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        let forAllOptions2: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions1)
                    {
                        (n: Int) async in
                        
                        TKAssertEqual(n + 0, n)
                    }
                    
                    await TKForAll(options: forAllOptions2)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                }
            )
        }
    }
    
    
    
    func testMultipleForAllsBothFailing() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertEqual(1, 2)
                    }
                }
            )
        }
    }
}



// MARK: - Support

extension StatefulIntegrationTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
    
    
    
    private static let options: TestOptions = .propertyOptions(
        iterations:         50,
        maxCommandCount:    10,
        seed:               seed
    )
}
