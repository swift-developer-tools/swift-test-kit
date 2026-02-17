//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class ForAllOptionsTests: XCTestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Global fallback
    
    @Reasync
    func testNilOptionsFallsBackToGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        XCTKConfig.global.propertyOptions.iterations    = 0
        XCTKConfig.global.propertyOptions.seed          = 50
        
        await XCTKForAll(options: nil)
        {
            (_: Int) async in
            
            XCTKAssertTrue(false)
        }
        
        XCTKConfig.global.propertyOptions.iterations = 1
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: nil)
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    @Reasync
    func testExplicitOptionsOverrideGlobal() async
    {
        /// With `iterations` set to zero, the property vacuously passes.
        XCTKConfig.global.propertyOptions.iterations = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let output: String? = await withCapturedOutput(options: options)
        {
            _ async in

            XCTKAssertTrue(false)
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    // MARK: - Seed
    
    @Reasync
    func testSeedDeterminism() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let property: (Int) async throws -> Void =
        {
            (_: Int) async in
            
            XCTKAssertTrue(false)
        }
        
        let output1: String? = await withCapturedOutput(
            options:    options,
            property:   property
        )
        
        let output2: String? = await withCapturedOutput(
            options:    options,
            property:   property
        )
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertEqual(output1, output2)
    }
    
    
    
    @Reasync
    func testSeedAppearsInOutput() async
    {
        let seed: UInt64 = 9876543210
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           seed
        )
        
        let output: String? = await withCapturedOutput(options: options)
        {
            _ async in

            XCTKAssertTrue(false)
        }
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.contains("Seed: \(seed)"))
    }
    
    
    
    // MARK: - Generation size
    
    @Reasync
    func testMaxSizeAffectsGeneration() async
    {
        /// With `maxSize` set to zero, every iteration generates at size zero.
        /// ``Int/arbitrary(using:)`` produces `0` at size zero, so the
        /// property passes.
        var options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        0,
            seed:           50
        )
        
        await XCTKForAll(options: options)
        {
            (n: Int) async in
            
            XCTKAssertEqual(n, 0)
        }
        
        
        
        /// With `maxSize` set to `100`, later iterations generate larger
        /// values, so the property fails.
        options.propertyOptions.maxSize = 100
        
        let output: String? = await withCapturedOutput(options: options)
        {
            (n: Int) async in
            
            XCTKAssertEqual(n, 0)
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    // MARK: - Shrinking
    
    @Reasync
    func testMaxShrinkStepsZeroDisablesShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            seed:               50
        )
        
        let output: String? = await withCapturedOutput(options: options)
        {
            (n: Int) async in

            XCTKAssertTrue(n <= 5)
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output!.contains("shrunk in"))
    }
    
    
    
    @Reasync
    func testMaxShrinkStepsEnablesShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               50
        )
        
        let output: String? = await withCapturedOutput(options: options)
        {
            (n: Int) async in

            XCTKAssertTrue(n <= 5)
        }
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.contains("shrunk in"))
    }
    
    
    
    // MARK: - Exhaustion
    
    @Reasync
    func testMaxDiscardRatioTriggersExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               50
        )
        
        let output: String? = await withCapturedOutput(
            precondition:   { _ in false },
            options:        options
        )
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.contains("exhausted"))
    }
}



// MARK: - Support

extension ForAllOptionsTests
{
    /// Runs the property evaluator with a single `Int` parameter, using the
    /// given values, and captures the failure output.
    /// - Parameters:
    ///   - options: The options to use.
    ///   - property: The property body.
    /// - Returns: The captured failure message, or `nil` if no failure
    /// occurred.
    @Reasync
    private func withCapturedOutput(
        options     : TestOptions?,
        property    : @escaping (Int) async throws -> Void
    ) async -> String?
    {
        return await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (n: Int) async throws in
                
                try await property(n)
            }
        }
    }
    
    
    
    /// Runs the conditional property evaluator with a single `Int` parameter,
    /// using the values, and captures the failure output.
    /// - Parameters:
    ///   - precondition: The precondition for generated inputs.
    ///   - options: The options to use.
    ///   - property: The property body.
    /// - Returns: The captured failure message, or `nil` if no failure
    /// occurred.
    @Reasync
    private func withCapturedOutput(
        precondition    : @escaping (Int) -> Bool,
        options         : TestOptions?,
        property        : @escaping (Int) async throws -> Void = { _ async in }
    ) async -> String?
    {
        return await withOneExpectedFailure
        {
            await XCTKForAll(
                where:      precondition,
                options:    options
            )
            {
                (n: Int) async throws in
                
                try await property(n)
            }
        }
    }
}
