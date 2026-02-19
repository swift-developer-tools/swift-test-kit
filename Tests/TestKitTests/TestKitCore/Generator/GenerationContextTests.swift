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



internal final class GenerationContextTests: XCTestCaseStopOnFail
{
    // MARK: - General
    
    func testInitWithSeed()
    {
        let context = GenerationContext(seed: 50)
        
        XCTAssertEqual(context.seed, 50)
        XCTAssertEqual(context.size, 0)
    }
    
    
    
    func testInitWithSeedAndSize()
    {
        let context = GenerationContext(seed: 50, size: 100)
        
        XCTAssertEqual(context.seed, 50)
        XCTAssertEqual(context.size, 100)
    }
    
    
    
    func testDifferentSeedsProduceDifferentSequences()
    {
        let context1    = GenerationContext.randomSize(seed: 1)
        let context2    = GenerationContext.randomSize(seed: 2)
        
        /// Collect values and verify that at least one differs.
        let values1: [Int]
        = (0..<1000).map { _ in context1.random(in: 0...1000) }
        
        let values2: [Int]
        = (0..<1000).map { _ in context2.random(in: 0...1000) }
        
        XCTAssertNotEqual(values1, values2)
    }
    
    
    
    func testSizeCanBeUpdated()
    {
        let context = GenerationContext.random
        
        context.size = 2
        
        XCTAssertEqual(context.size, 2)
    }
    
    
    
    // MARK: - random (integer)
    
    func testRandomIntDeterminism()
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
    
    
    
    func testRandomIntClosedRangeRespectsBounds()
    {
        let range: ClosedRange<Int> = 10...20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Int = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomIntClosedRangeSingleValue()
    {
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Int = context.random(in: 5...5)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomIntRangeRespectsBounds()
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
    
    func testRandomDoubleDeterminism()
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
    
    
    
    func testRandomDoubleClosedRangeRespectsBounds()
    {
        let range: ClosedRange<Double> = 10...20
        
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Double = context.random(in: range)
            
            XCTAssertTrue(range.contains(value))
        }
    }
    
    
    
    func testRandomDoubleClosedRangeSingleValue()
    {
        for _ in 0..<1000
        {
            let context = GenerationContext.random
            
            let value: Double = context.random(in: 5.0...5.0)
            
            XCTAssertEqual(value, 5)
        }
    }
    
    
    
    func testRandomDoubleRangeRespectsBounds()
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
    
    func testRandomBoolDeterminism()
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
    
    
    
    func testRandomBoolProducesBothValues()
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
    
    func testRandomElementDeterminism()
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
    
    
    
    func testRandomElementReturnsElementFromCollection()
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
    
    
    
    func testRandomElementReturnsNilForEmptyCollection()
    {
        let context     : GenerationContext     = .random
        let collection  : [Int]                 = []
        
        XCTAssertNil(context.randomElement(of: collection))
    }
    
    
    
    // MARK: - randomElement weighted
    
    func testWeightedRandomElementDeterminism()
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
    
    
    
    func testWeightedRandomElementReturnsNilForEmptyCollection()
    {
        let context     : GenerationContext     = .random
        let collection  : [Int]                 = []
        
        XCTAssertNil(
            context.randomElement(of: collection, weightedBy: { $0 })
        )
    }
    
    
    
    func testWeightedRandomElementSingleElementReturnsSame()
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
    
    
    
    func testWeightedRandomElementRespectsWeights()
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
    
    
    
    func testWeightedRandomElementProducesAllElements()
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
    
    
    
    // MARK: - withReducedSize
    
    func testWithReducedSizeHalvesSizeByDefault()
    {
        let context = GenerationContext(seed: 1, size: 100)
        
        context.withReducedSize
        {
            XCTAssertEqual(context.size, 50)
        }
    }
    
    
    
    func testWithReducedSizeRestoresSize()
    {
        let context = GenerationContext(seed: 1, size: 100)
        
        context.withReducedSize
        {
            XCTAssertEqual(context.size, 50)
        }
        
        XCTAssertEqual(context.size, 100)
    }
    
    
    
    func testWithReducedSizeCustomDivisor()
    {
        let context = GenerationContext(seed: 1, size: 100)
        
        context.withReducedSize(by: 4)
        {
            XCTAssertEqual(context.size, 25)
        }
        
        XCTAssertEqual(context.size, 100)
    }
    
    
    
    func testWithReducedSizeReturnValue()
    {
        let context = GenerationContext(seed: 1, size: 100)
        
        let result: String = context.withReducedSize
        {
            XCTAssertEqual(context.size, 50)
            return "hello world"
        }
        
        XCTAssertEqual(context.size, 100)
        XCTAssertEqual(result, "hello world")
    }
    
    
    
    func testWithReducedSizeNested()
    {
        let context = GenerationContext(seed: 1, size: 120)
        
        context.withReducedSize
        {
            XCTAssertEqual(context.size, 60)
            
            context.withReducedSize
            {
                XCTAssertEqual(context.size, 30)
                
                context.withReducedSize
                {
                    XCTAssertEqual(context.size, 15)
                }
                
                XCTAssertEqual(context.size, 30)
            }
            
            XCTAssertEqual(context.size, 60)
        }
        
        XCTAssertEqual(context.size, 120)
    }
    
    
    
    func testWithReducedSizeNestedCustomDivisor()
    {
        let context = GenerationContext(seed: 1, size: 120)
        
        context.withReducedSize(by: 3)
        {
            XCTAssertEqual(context.size, 40)
            
            context.withReducedSize(by: 4)
            {
                XCTAssertEqual(context.size, 10)
                
                context.withReducedSize(by: 5)
                {
                    XCTAssertEqual(context.size, 2)
                }
                
                XCTAssertEqual(context.size, 10)
            }
            
            XCTAssertEqual(context.size, 40)
        }
        
        XCTAssertEqual(context.size, 120)
    }
    
    
    
    func testWithReducedSizeFloorsAtZero()
    {
        let context0 = GenerationContext(seed: 1, size: 0)
        
        context0.withReducedSize
        {
            XCTAssertEqual(context0.size, 0)
        }
        
        XCTAssertEqual(context0.size, 0)
        
        let context1 = GenerationContext(seed: 1, size: 1)
        
        context1.withReducedSize
        {
            XCTAssertEqual(context1.size, 0)
        }
        
        XCTAssertEqual(context1.size, 1)
    }
    
    
    
    func testWithReducedSizeRNGContinuity()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value1: Int = context1.withReducedSize
            {
                return context1.random(in: 0...1000)
            }
            
            let value2: Int = context2.withReducedSize
            {
                return context2.random(in: 0...1000)
            }
            
            XCTAssertEqual(value1, value2)
        }
    }
    
    
    
    func testWithReducedSizeIntegerDivisionTruncation()
    {
        let context1 = GenerationContext(seed: 1, size: 7)
        
        context1.withReducedSize
        {
            XCTAssertEqual(context1.size, 3)
        }
        
        XCTAssertEqual(context1.size, 7)
        
        let context2 = GenerationContext(seed: 1, size: 5)
        
        context2.withReducedSize(by: 3)
        {
            XCTAssertEqual(context2.size, 1)
        }
        
        XCTAssertEqual(context2.size, 5)
    }
    
    
    
    func testWithReducedSizeDivisorLargerThanSize()
    {
        let context = GenerationContext(seed: 1, size: 3)
        
        context.withReducedSize(by: 10)
        {
            XCTAssertEqual(context.size, 0)
        }
        
        XCTAssertEqual(context.size, 3)
    }
    
    
    
    func testWithReducedSizeSequentialDoesNotAccumulateDepth()
    {
        let context = GenerationContext(seed: 1, size: 100)
        
        for _ in 0..<1000
        {
            context.withReducedSize { }
        }
        
        XCTAssertEqual(context.size, 100)
    }
    
    
    
    func testWithReducedSizeDoesNotAffectRNGSequence()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value1: Int = context1.withReducedSize
            {
                return context1.random(in: 0...1000)
            }
            
            let value2: Int = context2.random(in: 0...1000)
            
            XCTAssertEqual(value1, value2)
        }
    }
}
