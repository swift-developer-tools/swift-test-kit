//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import SwiftTestKit
import XCTest
import XCTestKit
import Synchronization



internal final class OptionsTests: TestKitCase
{
    private typealias TC = TestConfiguration
    
    
    
    override func setUp()
    {
        super.setUp()
        
        TC.global = TestOptions()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    override func tearDown()
    {
        TC.global = TestOptions()
        
        super.tearDown()
    }
    
    
    
    // MARK: - Structs
    
    func testTestOptions()
    {
        let options = TestOptions()
        
        XCTAssertEqual(options.diffOptions, DiffOptions())
        XCTAssertEqual(options.formatOptions, FormatOptions())
        XCTAssertEqual(options.propertyOptions, PropertyOptions())
        XCTAssertEqual(options.temporalOptions, TemporalOptions())
        XCTAssertEqual(options.performanceOptions, PerformanceOptions())
    }
    
    
    
    func testDiffOptions()
    {
        let options = DiffOptions()
        
        XCTAssertTrue(options.enabled)
        XCTAssertEqual(options.maxRecursionDepth, 20)
        XCTAssertNil(options.characterDiffThreshold)
    }
    
    
    
    func testFormatOptions()
    {
        let options = FormatOptions()
        
        XCTAssertEqual(options.indentationSpaces, 4)
        XCTAssertEqual(options.maxLineLength, 80)
        XCTAssertEqual(options.maxDiffs, nil)
        XCTAssertEqual(options.countDiffs, false)
        XCTAssertEqual(options.showAllEvaluated, true)
        XCTAssertEqual(options.showNotEvaluatedCount, true)
    }
    
    
    
    func testPropertyOptions()
    {
        let options = PropertyOptions()
        
        XCTAssertEqual(options.iterations, 100)
        XCTAssertEqual(options.maxShrinkSteps, 100)
        XCTAssertEqual(options.maxSize, 100)
        XCTAssertEqual(options.maxDiscardRatio, 10)
        XCTAssertEqual(options.maxCommandCount, 100)
        XCTAssertEqual(options.poolSize, 20)
        XCTAssertEqual(options.explorationRatio, 0.3)
        XCTAssertNil(options.timeout)
        XCTAssertEqual(options.diagnostics, [])
        XCTAssertEqual(options.statistics, [])
        XCTAssertNil(options.seed)
        XCTAssertNotNil(options.resolvedSeed)
    }
    
    
    
    func testPropertyOptionsResolvedSeedEqualsExplicitSeed()
    {
        var options : PropertyOptions   = .init()
        let seed    : UInt64            = GenerationContext.randomSeed
        
        XCTAssertNil(options.seed)
        XCTAssertNotNil(options.resolvedSeed)
        
        options.seed = seed
        
        XCTAssertEqual(options.seed, seed)
        XCTAssertEqual(options.resolvedSeed, seed)
    }
    
    
    
    func testTemporalOptions()
    {
        let options = TemporalOptions()
        
        XCTAssertEqual(options.timeout, .seconds(2))
        XCTAssertEqual(options.interval, .milliseconds(50))
    }
    
    
    
    func testPerformanceOptions()
    {
        let options = PerformanceOptions()
        
        XCTAssertEqual(options.runs, 10)
        XCTAssertEqual(options.warmupRuns, 1)
        XCTAssertNil(options.timeLimit)
        XCTAssertNil(options.memoryLimit)
    }
    
    
    
    // MARK: - with
    
    func testWithTestOptionsModified()
    {
        let options = TestOptions()
        
        XCTAssertTrue(options.diffOptions.enabled)
        XCTAssertNil(options.propertyOptions.seed)
        XCTAssertEqual(options.performanceOptions.runs, 10)
        
        let modified: TestOptions = options.with
        {
            $0.diffOptions.enabled      = false
            $0.propertyOptions.seed     = 12345
            $0.performanceOptions.runs  = 100
        }
        
        XCTAssertTrue(options.diffOptions.enabled)
        XCTAssertNil(options.propertyOptions.seed)
        XCTAssertEqual(options.performanceOptions.runs, 10)
        
        XCTAssertFalse(modified.diffOptions.enabled)
        XCTAssertEqual(modified.propertyOptions.seed, 12345)
        XCTAssertEqual(modified.performanceOptions.runs, 100)
    }
    
    
    
    func testWithTestOptionsNotModified()
    {
        let options     : TestOptions   = .init()
        let modified    : TestOptions   = options.with { _ in }
        
        XCTAssertEqual(options, modified)
    }
    
    
    
    // MARK: - Direct assignment
    
    func testGlobalConfigAssignment()
    {
        var options = TC.global
        
        TKAssertEqual(options.diffOptions.enabled, true)
        TKAssertEqual(options.diffOptions.maxRecursionDepth, 20)
        TKAssertEqual(options.formatOptions.maxLineLength, 80)
        
        options.diffOptions.enabled             = false
        options.diffOptions.maxRecursionDepth   = 1
        options.formatOptions.maxLineLength     = 40

        TC.global = options
        
        TKAssertEqual(options.diffOptions.enabled, false)
        TKAssertEqual(TC.global.diffOptions.maxRecursionDepth, 1)
        TKAssertEqual(TC.global.formatOptions.maxLineLength, 40)
    }
    
    
    
    func testGlobalConfigReturnsDefaultOptions()
    {
        let options = TC.global
        
        TKAssertEqual(options.diffOptions.enabled, true)
        TKAssertEqual(options.diffOptions, DiffOptions())
        TKAssertEqual(options.formatOptions, FormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification()
    {
        TKAssertTrue(TC.global.diffOptions.enabled)
        
        TC.global.diffOptions.enabled = false
        
        TKAssertFalse(TC.global.diffOptions.enabled)
    }
    
    
    
    @Reasync
    func testExplicitOptionsOverrideGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        TC.global.propertyOptions.iterations = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let property: (Int) async throws -> Void =
        {
            _ async in

            TKAssertTrue(false)
        }
        
        let output: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (n: Int) async throws in
                
                try await property(n)
            }
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    func testAssertionOptionsOverridePrecedence()
    {
        TC.global.diffOptions.enabled = true
        
        let output1: String? = withOneExpectedFailure
        {
            TKAssertEqual(1, 2)
        }
        
        let output2: String? = withOneExpectedFailure
        {
            let options = TestOptions(diffOptions: .init(enabled: false))
            
            TKAssertEqual(1, 2, options: options)
        }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertNotEqual(output1, output2)
    }
    
    
    
    // MARK: - Scoped assignment
    
    @Reasync
    func testWithOptionsDirectValue() async
    {
        TC.global.propertyOptions.iterations = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     0,
            seed:           50
        )
        
        await TC.withOptions(options)
        {
            await TKForAll(options: TC.current)
            {
                (_: Int) async in
                
                TKAssertTrue(false)
            }
        }
    }
    
    
    
    @Reasync
    func testWithOptionsMutation() async
    {
        TC.global.propertyOptions.iterations    = 100
        TC.global.propertyOptions.seed          = 50
        
        /// With `iterations` set to zero, the property vacuously passes.
        await TC.withOptions({ $0.propertyOptions.iterations = 0 })
        {
            await TKForAll(options: TC.current)
            {
                (_: Int) async in
                
                TKAssertTrue(false)
            }
            
            TKAssertEqual(TC.current.propertyOptions.seed, 50)
        }
    }
    
    
    
    @Reasync
    func testWithOptionsNesting() async
    {
        TC.global.propertyOptions.iterations = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     5,
            seed:           50
        )
        
        await TC.withOptions(options)
        {
            TKAssertEqual(TC.current.propertyOptions.iterations, 5)
            
            await TC.withOptions({ $0.propertyOptions.iterations = 0 })
            {
                await TKForAll
                {
                    (_: Int) async in
                    
                    TKAssertEqual(TC.current.propertyOptions.iterations, 0)
                    TKAssertEqual(TC.current.propertyOptions.seed, 50)
                }
            }
            
            TKAssertEqual(TC.current.propertyOptions.iterations, 5)
        }
        
        TKAssertEqual(TC.current.propertyOptions.iterations, 100)
    }
    
    
    
    @Reasync
    func testWithOptionsRevertsOnExit() async
    {
        TC.global.diffOptions.enabled = true
        
        let options = TestOptions(diffOptions: .init(enabled: false))
        
        await TC.withOptions(options)
        {
            await TKForAll
            {
                (_: Int) async in
                
                TKAssertFalse(TC.current.diffOptions.enabled)
            }
        }
        
        TKAssertTrue(TC.current.diffOptions.enabled)
    }
    
    
    
    @Reasync
    func testWithOptionsRevertsOnThrow() async
    {
        TC.global.diffOptions.enabled = true
        
        let options = TestOptions(diffOptions: .init(enabled: false))
        
        try? await TC.withOptions(options)
        {
            await TKForAll
            {
                (_: Int) async throws in
                
                TKAssertFalse(TC.current.diffOptions.enabled)
            }
            
            throw TestError()
        }
        
        TKAssertTrue(TC.current.diffOptions.enabled)
    }
    
    
    
    @Reasync
    func testWithOptionsOverrideWithOptions() async
    {
        TC.global.propertyOptions.iterations = 100
        
        let outerOptions: TestOptions = .propertyOptions(
            iterations:     0,
            seed:           50
        )
        
        await TC.withOptions(outerOptions)
        {
            let innerOptions: TestOptions = .propertyOptions(
                iterations:     1,
                seed:           50
            )
            
            /// The outer options set `iterations` to zero, so the property
            /// would vacuously pass. In this case, it must fail since the
            /// inner options are used to override that behavior.
            await withOneExpectedFailure
            {
                await TKForAll(options: innerOptions)
                {
                    (_: Int) async in
                    
                    TKAssertTrue(false)
                }
            }
        }
    }
    
    
    
    // MARK: - Frameworks
    
    @Reasync
    func testXCTKNilOptionsFallsBackToGlobal() async
    {
        TC.global.propertyOptions.iterations    = 3
        TC.global.propertyOptions.seed          = 50
        
        let count = Mutex<Int>(0)
        
        await XCTKForAll(options: nil)
        {
            (_: Int) async in
            
            count.withLock { $0 += 1 }
        }
        
        /// There would be `100` iterations if default local options were used.
        XCTAssertEqual(count.withLock { $0 }, 3)
    }
    
    
    
    @Reasync
    func testSTKNilOptionsFallsBackToGlobal() async
    {
        TC.global.propertyOptions.iterations    = 3
        TC.global.propertyOptions.seed          = 50
        
        let count = Mutex<Int>(0)
        
        await STKForAll(options: nil)
        {
            (_: Int) async in
            
            count.withLock { $0 += 1 }
        }
        
        /// There would be `100` iterations if default local options were used.
        XCTAssertEqual(count.withLock { $0 }, 3)
    }
}
