//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



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
    
    
    
    func testTestOptions()
    {
        let options = TestOptions()
        
        XCTAssertEqual(options.diffEnabled, true)
        XCTAssertEqual(options.diffOptions, DiffOptions())
        XCTAssertEqual(options.formatOptions, FormatOptions())
        XCTAssertEqual(options.propertyOptions, PropertyOptions())
        XCTAssertEqual(options.temporalOptions, TemporalOptions())
        XCTAssertEqual(options.performanceOptions, PerformanceOptions())
    }
    
    
    
    func testDiffOptions()
    {
        let options = DiffOptions()
        
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
        XCTAssertEqual(options.statistics, [])
        XCTAssertNil(options.seed)
    }
    
    
    
    func testTemporalOptions()
    {
        let options = TemporalOptions()
        
        XCTAssertEqual(options.timeout, .seconds(2))
        XCTAssertEqual(options.interval, .milliseconds(50))
        XCTAssertFalse(options.showAllFailures)
    }
    
    
    
    func testPerformanceOptions()
    {
        let options = PerformanceOptions()
        
        XCTAssertEqual(options.runs, 5)
        XCTAssertEqual(options.warmupRuns, 1)
        XCTAssertNil(options.timeLimit)
        XCTAssertNil(options.memoryLimit)
        XCTAssertFalse(options.showAllFailures)
    }
    
    
    
    func testGlobalConfigAssignment()
    {
        var options = TC.global
        
        TKAssertEqual(options.diffEnabled, true)
        TKAssertEqual(options.diffOptions.maxRecursionDepth, 20)
        TKAssertEqual(options.formatOptions.maxLineLength, 80)
        
        options.diffEnabled                     = false
        options.diffOptions.maxRecursionDepth   = 1
        options.formatOptions.maxLineLength     = 40

        TC.global = options
        
        TKAssertEqual(options.diffEnabled, false)
        TKAssertEqual(TC.global.diffOptions.maxRecursionDepth, 1)
        TKAssertEqual(TC.global.formatOptions.maxLineLength, 40)
    }
    
    
    
    func testGlobalConfigReturnsDefaultOptions()
    {
        let options = TC.global
        
        TKAssertEqual(options.diffEnabled, true)
        TKAssertEqual(options.diffOptions, DiffOptions())
        TKAssertEqual(options.formatOptions, FormatOptions())
    }
    
    
    
    func testGlobalConfigDirectModification()
    {
        TKAssertTrue(TC.global.diffEnabled)
        
        TC.global.diffEnabled = false
        
        TKAssertFalse(TC.global.diffEnabled)
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
}
