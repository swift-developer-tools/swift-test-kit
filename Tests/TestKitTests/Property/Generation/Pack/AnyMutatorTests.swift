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



internal final class AnyMutatorTests: TestKitCase
{
    // MARK: - AnyMutator
    
    func testIntMutation()
    {
        let mutate: (Int, GenerationContext) -> Int =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        let result: Any = AnyMutator(mutate).mutate(
            50,
            using: .random
        )
        
        XCTAssertTrue(result is Int)
    }
    
    
    
    func testStringMutation()
    {
        let mutate: (String, GenerationContext) -> String =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        let result: Any = AnyMutator(mutate).mutate(
            "abc",
            using: .random
        )
        
        XCTAssertTrue(result is String)
    }
    
    
    
    func testBoolMutation()
    {
        let mutate: (Bool, GenerationContext) -> Bool =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        let result1: Any = AnyMutator(mutate).mutate(
            true,
            using: .random
        )
        
        let result2: Any = AnyMutator(mutate).mutate(
            false,
            using: .random
        )
        
        XCTAssertFalse(result1 as! Bool)
        XCTAssertTrue(result2 as! Bool)
    }
    
    
    
    func testOptionalMutation()
    {
        let mutate: (Optional<Int>, GenerationContext) -> Optional<Int> =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        let result: Any = AnyMutator(mutate).mutate(
            Optional<Int>(10) as Any,
            using: .random
        )
        
        XCTAssertTrue(result is Optional<Int>)
    }
    
    
    
    func testArrayMutation()
    {
        let mutate: ([Int], GenerationContext) -> [Int] =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        let result: Any = AnyMutator(mutate).mutate(
            [1, 2, 3],
            using: .random
        )
        
        XCTAssertTrue(result is [Int])
    }
    
    
    
    func testCustomMutate()
    {
        let mutate: (Int, GenerationContext) -> Int =
        {
            value, _ in
            
            return value * 2
        }
        
        let result: Any = AnyMutator(mutate).mutate(
            25,
            using: .random
        )
        
        XCTAssertEqual(result as! Int, 50)
    }
    
    
    
    func testMutatorDeterminism()
    {
        let mutate: (Int, GenerationContext) -> Int =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value: Int = .random(in: -100...100)
            
            let result1: Any = AnyMutator(mutate).mutate(
                value,
                using: context1
            )
            
            let result2: Any = AnyMutator(mutate).mutate(
                value,
                using: context2
            )
            
            XCTAssertEqual(result1 as! Int, result2 as! Int)
        }
    }
    
    
    
    func testMakeMutatorForType()
    {
        let mutator = AnyMutator.makeMutator(for: Int.self)
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value: Int = .random(in: -100...100)
            
            let erasedResult: Any = mutator.mutate(
                value,
                using: context1
            )
            
            let directResult: Any = value.mutate(using: context2)
            
            XCTAssertEqual(erasedResult as! Int, directResult as! Int)
        }
    }
    
    
    
    func testMakeMutatorFromGenerator()
    {
        let generator   = Generator<Int>.integer(in: 0...100)
        let mutator     = AnyMutator.makeMutator(from: generator)
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value: Int = .random(in: 0...100)
            
            let erasedResult: Any = mutator.mutate(
                value,
                using: context1
            )
            
            let directResult: Int = generator.mutate(
                value,
                context2
            )
            
            XCTAssertEqual(erasedResult as! Int, directResult)
        }
    }
    
    
    
    func testMakeMutatorFromGeneratorCustomMutate()
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { _, _ in 50 }
        )
        
        let mutator = AnyMutator.makeMutator(from: generator)
        
        let result: Any = mutator.mutate(
            999,
            using: .random
        )
        
        XCTAssertEqual(result as! Int, 50)
    }
    
    
    
    // MARK: - Integration
    
    func testMutateSingleElementMultipleElements()
    {
        let mutators: [AnyMutator] =
        [
            .makeMutator(for: Int.self),
            .makeMutator(for: String.self),
            .makeMutator(for: Bool.self)
        ]
        
        for _ in 0..<1000
        {
            let result: [Any] = AnyMutator.mutateSingleElement(
                of:     (10, "abc", true),
                with:   mutators,
                using:  .random
            )
            
            XCTAssertEqual(result.count, 3)
            
            var diffCount: Int = 0
            
            if (result[0] as! Int) != 10
            {
                diffCount += 1
            }
            
            if (result[1] as! String) != "abc"
            {
                diffCount += 1
            }
            
            if (result[2] as! Bool) != true
            {
                diffCount += 1
            }
            
            /// At most one element must differ. It is possible that mutation
            /// produces the same value, however.
            XCTAssertLessThanOrEqual(diffCount, 1)
        }
    }
    
    
    
    func testMutateSingleElementSingleEement() throws
    {
        let mutators: [AnyMutator] = [.makeMutator(for: Int.self),]
        
        for _ in 0..<1000
        {
            let result: [Any] = AnyMutator.mutateSingleElement(
                of:     50,
                with:   mutators,
                using:  .random
            )
            
            XCTAssertEqual(result.count, 1)
            
            _ = try XCTUnwrap(result[0] as? Int)
        }
    }
    
    
    
    func testMutateSingleElementSelectsAllPositions()
    {
        let mutators: [AnyMutator] =
        [
            AnyMutator({ (_: Int, _) in -999 }),
            AnyMutator({ (_: String, _) in "xyz" }),
            AnyMutator({ (_: Bool, _) in false })
        ]
        
        var mutatedPosition: Set<Int> = []
        
        for _ in 0..<1000
        {
            let result: [Any] = AnyMutator.mutateSingleElement(
                of:     (10, "abc", true),
                with:   mutators,
                using:  .random
            )
            
            if (result[0] as! Int) != 10
            {
                mutatedPosition.insert(0)
            }
            
            if (result[1] as! String) != "abc"
            {
                mutatedPosition.insert(1)
            }
            
            if (result[2] as! Bool) != true
            {
                mutatedPosition.insert(2)
            }
        }
        
        XCTAssertEqual(mutatedPosition, [0, 1, 2])
    }
    
    
    
    func testMutateSingleElementTuple() throws
    {
        let mutate: ((Int, String), GenerationContext) -> (Int, String) =
        {
            value, context in
            
            return (value.0 + 1, value.1)
        }
        
        let result: [Any] = AnyMutator.mutateSingleElement(
            of:     (10, "abc"),
            with:   [AnyMutator(mutate)],
            using:  .random
        )
        
        XCTAssertEqual(result.count, 1)
        
        let tuple = try XCTUnwrap(result[0] as? (Int, String))
        
        XCTAssertEqual(tuple.0, 10 + 1)
        XCTAssertEqual(tuple.1, "abc")
    }
    
    
    
    func testMutateSingleElementEmptyMutators()
    {
        let result: [Any] = AnyMutator.mutateSingleElement(
            of:     50,
            with:   [],
            using:  .random
        )
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0] as! Int, 50)
    }
    
    
    
    func testMutateSingleElementMutatorCountMismatch()
    {
        let mutators: [AnyMutator] =
        [
            .makeMutator(for: Int.self),
            .makeMutator(for: Int.self)
        ]
        
        let result: [Any] = AnyMutator.mutateSingleElement(
            of:     50,
            with:   mutators,
            using:  .random
        )
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0] as! Int, 50)
    }
    
    
    
    func testMutateSingleElementDeterminism()
    {
        let mutators: [AnyMutator] =
        [
            .makeMutator(for: Int.self),
            .makeMutator(for: String.self),
            .makeMutator(for: Bool.self)
        ]
        
        let value: (Int, String, Bool) = (35, "hello", true)
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let result1: [Any] = AnyMutator.mutateSingleElement(
                of:     value,
                with:   mutators,
                using:  context1
            )
            
            let result2: [Any] = AnyMutator.mutateSingleElement(
                of:     value,
                with:   mutators,
                using:  context2
            )
            
            XCTAssertEqual(result1[0] as! Int, result2[0] as! Int)
            XCTAssertEqual(result1[1] as! String, result2[1] as! String)
            XCTAssertEqual(result1[2] as! Bool, result2[2] as! Bool)
        }
    }
    
    
    
    func testMutateSingleElementPreservesUnselectedValues()
    {
        let mutators: [AnyMutator] =
        [
            AnyMutator({ (_: Int, _) in -999 }),
            AnyMutator({ (_: String, _) in "xyz" }),
            AnyMutator({ (_: Bool, _) in false })
        ]
        
        for _ in 0..<1000
        {
            let result: [Any] = AnyMutator.mutateSingleElement(
                of:     (10, "abc", true),
                with:   mutators,
                using:  .random
            )
            
            let intValue        = result[0] as! Int
            let stringValue     = result[1] as! String
            let boolValue       = result[2] as! Bool
            
            if intValue == -999
            {
                XCTAssertEqual(stringValue, "abc")
                XCTAssertEqual(boolValue, true)
            }
            else if stringValue == "xyz"
            {
                XCTAssertEqual(intValue, 10)
                XCTAssertEqual(boolValue, true)
            }
            else
            {
                XCTAssertEqual(intValue, 10)
                XCTAssertEqual(stringValue, "abc")
                XCTAssertFalse(boolValue)
            }
        }
    }
    
    
    
    func testMutateSingleElementUniformDistribution()
    {
        let mutators: [AnyMutator] =
        [
            AnyMutator({ (_: Int, _) in -999 }),
            AnyMutator({ (_: String, _) in "xyz" }),
            AnyMutator({ (_: Bool, _) in false })
        ]
        
        var counts      : [Int]     = [0, 0, 0]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            let result: [Any] = AnyMutator.mutateSingleElement(
                of:     (10, "abc", true),
                with:   mutators,
                using:  .random
            )
            
            if (result[0] as! Int) != 10
            {
                counts[0] += 1
            }
            
            if (result[1] as! String) != "abc"
            {
                counts[1] += 1
            }
            
            if (result[2] as! Bool) != true
            {
                counts[2] += 1
            }
        }
        
        for count in counts
        {
            XCTAssertGreaterThan(
                count,
                Int(Double(iterations) * (1 / 3) * 0.85)
            )
        }
    }
    
    
    
    func testMutatePassesContext()
    {
        let mutate: (Int, GenerationContext) -> Int =
        {
            _, context in
            
            return context.size
        }
        
        for _ in 0..<1000
        {
            let size: Int = GenerationContext.randomSize
            
            let result: Any = AnyMutator(mutate).mutate(
                0,
                using: .randomSeed(size: size)
            )
            
            XCTAssertEqual(result as! Int, size)
        }
    }
}
