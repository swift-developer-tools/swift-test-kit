//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitCore



internal final class SampleGeneratorTests: TestKitCase
{
    // MARK: - Determinism
    
    func testSampleDeterminism()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let a   : [Int]     = generator.sample(count: 20, seed: 50)
        let b   : [Int]     = generator.sample(count: 20, seed: 50)
        
        XCTAssertEqual(a, b)
    }
    
    
    
    func testIndeterminism()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let a   : [Int]     = generator.sample(count: 20, seed: 50)
        let b   : [Int]     = generator.sample(count: 20, seed: 75)
        
        XCTAssertNotEqual(a, b)
    }
    
    
    
    // MARK: - Count
    
    func testGeneratesRequestedCount()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let samples: [Int] = generator.sample(count: 99, seed: 1)
        
        XCTAssertEqual(samples.count, 99)
    }
    
    
    
    func testGeneratesRequestedCountWithRandomSeed()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let samples: [Int] = generator.sample(count: 1, seed: nil)
        
        XCTAssertEqual(samples.count, 1)
    }
    
    
    
    func testZeroCount()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let samples: [Int] = generator.sample(count: 0, seed: 1)
        
        XCTAssertTrue(samples.isEmpty)
    }
    
    
    
    func testDefaultCount()
    {
        let generator = Generator<Int>.integer(in: 0...1000)
        
        let samples: [Int] = generator.sample(seed: 1)
        
        XCTAssertEqual(samples.count, 10)
    }
    
    
    
    // MARK: - Bounds
    
    func testSamplesRespectGeneratorBounds()
    {
        let generator = Generator<Int>.integer(in: 10...20)
        
        let samples: [Int] = generator.sample(count: 1000, seed: 1)
        
        for value in samples
        {
            XCTAssertGreaterThanOrEqual(value, 10)
            XCTAssertLessThanOrEqual(value, 20)
        }
    }
    
    
    
    // MARK: - Size
    
    func testLinearSizeScaling()
    {
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let samples: [Int] = generator.sample(
            count:      5,
            seed:       50,
            maxSize:    100
        )
        
        /// `size = index * maxSize / count` for `index in 0..<5`.
        XCTAssertEqual(samples, [0, 20, 40, 60, 80])
    }
    
    
    
    func testSamplesRespectMaxSize()
    {
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let samples: [Int] = generator.sample(
            count:      5,
            seed:       50,
            maxSize:    50
        )
        
        /// `size = index * maxSize / count` for `index in 0..<5`.
        XCTAssertEqual(samples, [0, 10, 20, 30, 40])
    }
    
    
    
    func testMaxSizeZeroKeepsSizeAtZero()
    {
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let samples: [Int] = generator.sample(
            count:      5,
            seed:       50,
            maxSize:    0
        )
        
        /// `size = index * maxSize / count` for `index in 0..<5`.
        /// Unless `count` is `0`, then `size` is also `0`.
        XCTAssertEqual(samples, [0, 0, 0, 0, 0])
    }
}
