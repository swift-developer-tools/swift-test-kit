//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitBase



internal final class GenerationContextTests: XCTestCase
{
    // MARK: - Determinism
    
    func testSameSeedProducesSameSequence() throws
    {
        let context1    = GenerationContext(seed: 1)
        let context2    = GenerationContext(seed: 1)
        
        for _ in 0..<500
        {
            XCTAssertEqual(
                context1.randomInt(in: 0...1000),
                context2.randomInt(in: 0...1000)
            )
        }
    }
    
    
    
    func testDifferentSeedsProduceDifferentSequences() throws
    {
        let context1    = GenerationContext(seed: 1)
        let context2    = GenerationContext(seed: 2)
        
        /// Collect values and verify that at least one differs.
        let values1: [Int]
            = (0..<500).map { _ in context1.randomInt(in: 0...1000) }
        
        let values2: [Int]
            = (0..<500).map { _ in context2.randomInt(in: 0...1000) }
        
        XCTAssertNotEqual(values1, values2)
    }
    
    
    
    // MARK: - Initialization
    
    func testInitWithSeed() throws
    {
        let context = GenerationContext(seed: 50)
        
        XCTAssertEqual(context.seed, 50)
        XCTAssertEqual(context.size, 0)
    }
    
    
    
    func testInitWithSeedAndSize() throws
    {
        let context = GenerationContext(seed: 50, size: 100)
        
        XCTAssertEqual(context.seed, 50)
        XCTAssertEqual(context.size, 100)
    }
    
    
    
    // MARK: - Size
    
    func testSizeCanBeUpdated() throws
    {
        let context = GenerationContext(seed: 1)
        
        context.size = 2
        
        XCTAssertEqual(context.size, 2)
    }
    
    
    
    // MARK: - randomInt
    
    func testRandomIntClosedRangeRespectsBounds() throws
    {
        let context : GenerationContext     = .init(seed: 50)
        let range   : ClosedRange<Int>      = 10...20
        
        for _ in 0..<500
        {
            let value: Int = context.randomInt(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomIntClosedRangeSingleValue() throws
    {
        let context = GenerationContext(seed: 50)
        
        for _ in 0..<500
        {
            let value: Int = context.randomInt(in: 5...5)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomIntRangeRespectsBounds() throws
    {
        let context : GenerationContext     = .init(seed: 50)
        let range   : Range<Int>            = 10..<20
        
        for _ in 0..<500
        {
            let value: Int = context.randomInt(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    // MARK: - randomDouble
    
    func testRandomDoubleClosedRangeRespectsBounds() throws
    {
        let context : GenerationContext     = .init(seed: 50)
        let range   : ClosedRange<Double>   = 10...20
        
        for _ in 0..<500
        {
            let value: Double = context.randomDouble(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomDoubleClosedRangeSingleValue() throws
    {
        let context = GenerationContext(seed: 50)
        
        for _ in 0..<500
        {
            let value: Double = context.randomDouble(in: 5...5)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomDoubleRangeRespectsBounds() throws
    {
        let context : GenerationContext     = .init(seed: 50)
        let range   : Range<Double>         = 10..<20
        
        for _ in 0..<500
        {
            let value: Double = context.randomDouble(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    // MARK: - randomBool
    
    func testRandomBoolProducesBothValues() throws
    {
        let context     : GenerationContext     = .init(seed: 50)
        var hasTrue     : Bool                  = false
        var hasFalse    : Bool                  = false
        
        for _ in 0..<500
        {
            let value: Bool = context.randomBool()
            
            if value
            {
                hasTrue = true
            }
            else
            {
                hasFalse = true
            }
            
            if
                hasTrue,
                hasFalse
            {
                break
            }
        }
        
        XCTAssertTrue(hasTrue)
        XCTAssertTrue(hasFalse)
    }
    
    
    
    // MARK: - randomElement
    
    func testRandomElementReturnsElementFromCollection() throws
    {
        let context     : GenerationContext     = .init(seed: 50)
        let collection  : [String]              = ["a", "b", "c", "d"]
        
        for _ in 0..<500
        {
            let element: String? = context.randomElement(of: collection)
            
            XCTAssertNotNil(element)
            XCTAssertTrue(collection.contains(element!))
        }
    }
    
    
    
    func testRandomElementReturnsNilForEmptyCollection() throws
    {
        let context     : GenerationContext     = .init(seed: 50)
        let collection  : [Int]                 = []
        
        XCTAssertNil(context.randomElement(of: collection))
    }
}
