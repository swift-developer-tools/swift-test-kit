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
    // MARK: - Global fallback
    
    func testNilOptionsFallsBackToGlobal()
    {
        /// With `iterations` set to zero, the property vacuously passes.
        XCTKConfig.global.propertyOptions.iterations    = 0
        XCTKConfig.global.propertyOptions.seed          = 50
        
        XCTKForAll(options: nil)
        {
            (_: Int) in
            
            XCTKAssertTrue(false)
        }
        
        XCTKConfig.global.propertyOptions.iterations = 1
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(options: nil)
            {
                (_: Int) in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    func testExplicitOptionsOverrideGlobal()
    {
        /// With `iterations` set to zero, the property vacuously passes.
        XCTKConfig.global.propertyOptions.iterations = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let output: String? = withCapturedOutput(options: options)
        {
            _ in

            XCTKAssertTrue(false)
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    // MARK: - Seed
    
    func testSeedDeterminism()
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let property: (Int) throws -> Void =
        {
            (_: Int) in
            
            XCTKAssertTrue(false)
        }
        
        let output1: String? = withCapturedOutput(
            options:    options,
            property:   property
        )
        
        let output2: String? = withCapturedOutput(
            options:    options,
            property:   property
        )
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertEqual(output1, output2)
    }
    
    
    
    func testSeedAppearsInOutput()
    {
        let seed: UInt64 = 9876543210
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           seed
        )
        
        let output: String? = withCapturedOutput(options: options)
        {
            _ in

            XCTKAssertTrue(false)
        }
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.contains("Seed: \(seed)"))
    }
    
    
    
    // MARK: - Generation size
    
    func testMaxSizeAffectsGeneration()
    {
        /// With `maxSize` set to zero, every iteration generates at size zero.
        /// ``Int/arbitrary(using:)`` produces `0` at size zero, so the
        /// property passes.
        var options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        0,
            seed:           50
        )
        
        XCTKForAll(options: options)
        {
            (n: Int) in
            
            XCTKAssertEqual(n, 0)
        }
        
        
        
        /// With `maxSize` set to `100`, later iterations generate larger
        /// values, so the property fails.
        options.propertyOptions.maxSize = 100
        
        let output: String? = withCapturedOutput(options: options)
        {
            (n: Int) in
            
            XCTKAssertEqual(n, 0)
        }
        
        XCTAssertNotNil(output)
    }
    
    
    
    // MARK: - Shrinking
    
    func testMaxShrinkStepsZeroDisablesShrinking()
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            seed:               50
        )
        
        let output: String? = withCapturedOutput(options: options)
        {
            (n: Int) in

            XCTKAssertTrue(n <= 5)
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output!.contains("shrunk in"))
    }
    
    
    
    func testMaxShrinkStepsEnablesShrinking()
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               50
        )
        
        let output: String? = withCapturedOutput(options: options)
        {
            (n: Int) in

            XCTKAssertTrue(n <= 5)
        }
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.contains("shrunk in"))
    }
    
    
    
    // MARK: - Exhaustion
    
    func testMaxDiscardRatioTriggersExhaustion()
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               50
        )
        
        let output: String? = withCapturedOutput(
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
    private func withCapturedOutput(
        options     : TestOptions?,
        property    : @escaping (Int) throws -> Void
    ) -> String?
    {
        return withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (n: Int) in
                
                try property(n)
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
    private func withCapturedOutput(
        precondition    : @escaping (Int) -> Bool,
        options         : TestOptions?,
        property        : @escaping (Int) throws -> Void    = { _ in }
    ) -> String?
    {
        return withOneExpectedFailure
        {
            XCTKForAll(
                where:      precondition,
                options:    options
            )
            {
                (n: Int) in
                
                try property(n)
            }
        }
    }
}
