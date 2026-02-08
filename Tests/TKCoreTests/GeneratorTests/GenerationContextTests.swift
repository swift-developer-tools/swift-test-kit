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



internal final class GenerationContextTests: XCTestCaseStopOnFail
{
    // MARK: - General
    
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
    
    
    
    func testDifferentSeedsProduceDifferentSequences() throws
    {
        let context1 = GenerationContext(
            seed: 1,
            size: GenerationContext.randomSize
        )
        
        let context2 = GenerationContext(
            seed: 2,
            size: GenerationContext.randomSize
        )
        
        /// Collect values and verify that at least one differs.
        let values1: [Int]
            = (0..<1000).map { _ in context1.random(in: 0...1000) }
        
        let values2: [Int]
            = (0..<1000).map { _ in context2.random(in: 0...1000) }
        
        XCTAssertNotEqual(values1, values2)
    }
    
    
    
    func testSizeCanBeUpdated() throws
    {
        let context = GenerationContext.random
        
        context.size = 2
        
        XCTAssertEqual(context.size, 2)
    }
    
    
    
    // MARK: - random (integer)
    
    func testRandomIntDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                context1.random(in: 0...1000),
                context2.random(in: 0...1000)
            )
        }
    }
    
    
    
    func testRandomIntClosedRangeRespectsBounds() throws
    {
        let range: ClosedRange<Int> = 10...20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Int = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomIntClosedRangeSingleValue() throws
    {
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Int = context.random(in: 5...5)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomIntRangeRespectsBounds() throws
    {
        let range: Range<Int> = 10..<20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Int = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    // MARK: - random (floating)
    
    func testRandomDoubleDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                context1.random(in: 0.0...1000.0),
                context2.random(in: 0.0...1000.0)
            )
        }
    }
    
    
    
    func testRandomDoubleClosedRangeRespectsBounds() throws
    {
        let range: ClosedRange<Double> = 10...20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Double = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomDoubleClosedRangeSingleValue() throws
    {
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Double = context.random(in: 5.0...5.0)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomDoubleRangeRespectsBounds() throws
    {
        let range: Range<Double> = 10..<20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Double = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    // MARK: - randomBool
    
    func testRandomBoolDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                context1.randomBool(),
                context2.randomBool()
            )
        }
    }
    
    
    
    func testRandomBoolProducesBothValues() throws
    {
        var hasTrue     : Bool  = false
        var hasFalse    : Bool  = false
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
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
    
    func testRandomElementDeterminism() throws
    {
        let elements: [String] = ["a", "b", "c", "d"]
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                context1.randomElement(of: elements),
                context2.randomElement(of: elements)
            )
        }
    }
    
    
    
    func testRandomElementReturnsElementFromCollection() throws
    {
        let collection: [String] = ["a", "b", "c", "d"]
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let element: String? = context.randomElement(of: collection)
            
            XCTAssertNotNil(element)
            XCTAssertTrue(collection.contains(element!))
        }
    }
    
    
    
    func testRandomElementReturnsNilForEmptyCollection() throws
    {
        let context     : GenerationContext     = .random
        let collection  : [Int]                 = []
        
        XCTAssertNil(context.randomElement(of: collection))
    }
    
    
    
    // MARK: - randomElement weighted
    
    func testWeightedRandomElementDeterminism() throws
    {
        let elements: [String] = ["a", "b", "c", "d"]
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                context1.randomElement(of: elements, weightedBy: { _ in 1 }),
                context2.randomElement(of: elements, weightedBy: { _ in 1 })
            )
        }
    }
    
    
    
    func testWeightedRandomElementReturnsNilForEmptyCollection() throws
    {
        let context     : GenerationContext     = .random
        let collection  : [Int]                 = []
        
        XCTAssertNil(
            context.randomElement(of: collection, weightedBy: { $0 })
        )
    }
    
    
    
    func testWeightedRandomElementSingleElementReturnsSame() throws
    {
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let element: String? = context.randomElement(
                of:             ["hello"],
                weightedBy:     { _ in 1 }
            )
            
            XCTAssertEqual(element, "hello")
        }
    }
    
    
    
    func testWeightedRandomElementRespectsWeights() throws
    {
        let elements: [(String, Int)] =
        [
            ("high", 1000),
            ("low", 10)
        ]
        
        var counts      : [String : Int]    = ["high": 0, "low": 0]
        let iterations  : Int               = 10_000
        
        for _ in 0..<iterations
        {
            let context = GenerationContext.random
            
            let element: (String, Int)? = context.randomElement(
                of:             elements,
                weightedBy:     { $0.1 }
            )
            
            XCTAssertNotNil(element)
            
            counts[element!.0, default: 0] += 1
        }
        
        XCTAssertGreaterThan(counts["high"]!, Int(Double(iterations) * 0.95))
        XCTAssertLessThan(counts["low"]!, Int(Double(iterations) * 0.05))
    }
    
    
    
    func testWeightedRandomElementProducesAllElements() throws
    {
        let elements    : [String]      = ["a", "b", "c"]
        var seen        : Set<String>   = []
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let element: String? = context.randomElement(
                of:             elements,
                weightedBy:     { _ in 1 }
            )
            
            XCTAssertNotNil(element)
            
            seen.insert(element!)
        }
        
        XCTAssertEqual(seen, Set(elements))
    }
}
