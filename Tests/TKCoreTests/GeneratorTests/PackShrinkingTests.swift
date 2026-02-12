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



internal final class PackShrinkingTests: XCTestCaseStopOnFail
{
    // MARK: - AnyShrinker
    
    func testIntShrinking() throws
    {
        let shrinker = AnyShrinker({ (v: Int) in v.shrinkTowardZero() })
        
        let input       : Int       = 50
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [Int]     = input.shrinkTowardZero()
        
        XCTAssertGreaterThan(candidates.count, 0)
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testStringShrinking() throws
    {
        let shrinker = AnyShrinker({ (v: String) in v.shrinkTowardEmpty() })
        
        let input       : String    = "abc"
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [String]  = input.shrinkTowardEmpty()
        
        XCTAssertGreaterThan(candidates.count, 0)
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? String)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testBoolShrinking() throws
    {
        let shrinker = AnyShrinker({ (v: Bool) in v.shrink() })
        
        let trueCandidates  : [Any]     = shrinker.shrink(true)
        let falseCandidates : [Any]     = shrinker.shrink(false)
        
        XCTAssertEqual(trueCandidates.count, 1)
        XCTAssertTrue(falseCandidates.isEmpty)
        
        let value = try XCTUnwrap(trueCandidates.first as? Bool)
        
        XCTAssertEqual(value, false)
    }
    
    
    
    func testNoShrinkCandidates() throws
    {
        let shrinker = AnyShrinker({ (v: Int) in v.shrinkTowardZero() })
        
        let candidates: [Any] = shrinker.shrink(0)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testPreservesOrder() throws
    {
        let shrinker = AnyShrinker({ (v: Int) in v.shrinkTowardZero() })
        
        let input       : Int       = 100
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [Int]     = input.shrinkTowardZero()
        
        XCTAssertGreaterThan(candidates.count, 0)
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testCustomShrinkFunction() throws
    {
        let shrinker = AnyShrinker({
            (v: Int) -> [Int] in
            
            guard v != 0
            else
            {
                return []
            }
            
            var candidates  : [Int]     = [0]
            let half        : Int       = v / 2
            
            if half != 0
            {
                candidates.append(half)
            }
            
            return candidates
        })
        
        let candidates: [Any] = shrinker.shrink(20)
        
        XCTAssertEqual(candidates.count, 2)
        
        let first   = try XCTUnwrap(candidates[0] as? Int)
        let second  = try XCTUnwrap(candidates[1] as? Int)
        
        XCTAssertEqual(first, 0)
        XCTAssertEqual(second, 10)
    }
    
    
    
    func testArrayShrinking() throws
    {
        let shrinker = AnyShrinker({ (v: [Int]) in v.shrink() })
        
        let input       : [Int]     = [1, 2, 3]
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [[Int]]   = input.shrink()
        
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? [Int])
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testOptionalShrinking() throws
    {
        let shrinker = AnyShrinker({ (v: Optional<Int>) in v.shrink() })
        
        let input       : Optional<Int>     = 10
        let candidates  : [Any]             = shrinker.shrink(input as Any)
        let expected    : [Optional<Int>]   = input.shrink()
        
        XCTAssertEqual(candidates.count, expected.count)
        XCTAssertTrue(candidates[0] is Optional<Int>)
        XCTAssertNil(candidates[0] as! Optional<Int>)
        
        for index in 1..<candidates.count
        {
            let value   = try XCTUnwrap(candidates[index] as? Optional<Int>)
            let exp     = try XCTUnwrap(expected[index])
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testMakeShrinkerForType() throws
    {
        let shrinker = AnyShrinker.makeShrinker(for: Int.self)
        
        let input       : Int       = 50
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [Int]     = input.shrink()
        
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testMakeShrinkerForTypeNoCandidates() throws
    {
        let shrinker = AnyShrinker.makeShrinker(for: Int.self)
        
        let candidates: [Any] = shrinker.shrink(0)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testMakeShrinkerFromGenerator() throws
    {
        let generator   : Generator<Int>    = .integer(in: 0...100)
        let shrinker    : AnyShrinker       = .makeShrinker(from: generator)
        
        let input       : Int       = 99
        let candidates  : [Any]     = shrinker.shrink(input)
        let expected    : [Int]     = input.shrink()
        
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testMakeShrinkerFromGeneratorCustomShrink() throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [1, 2, 3] }
        )
        
        let shrinker = AnyShrinker.makeShrinker(from: generator)
        
        let candidates: [Any] = shrinker.shrink(999)
        
        XCTAssertEqual(candidates.count, 3)
        
        let first   = try XCTUnwrap(candidates[0] as? Int)
        let second  = try XCTUnwrap(candidates[1] as? Int)
        let third   = try XCTUnwrap(candidates[2] as? Int)
        
        XCTAssertEqual(first, 1)
        XCTAssertEqual(second, 2)
        XCTAssertEqual(third, 3)
    }
    
    
    
    // MARK: - PackIndex
    
    func testSingleNextCall() throws
    {
        let packIndex = PackIndex()
        
        XCTAssertEqual(packIndex.next(), 0)
    }
    
    
    
    func testSequentialFromZero() throws
    {
        let packIndex = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex.next(), index)
        }
    }
    
    
    
    func testNewInstanceStartsAtZero() throws
    {
        let packIndex1 = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex1.next(), index)
        }
        
        let packIndex2 = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex2.next(), index)
        }
    }
    
    
    
    // MARK: - Integration
    
    func testPerPositionIndependence() throws
    {
        /// Zip-style shrinking (shrinking one value while holding others
        /// constant) must produce candidates with only one input changed.
        
        for count in 2...8
        {
            let values: [Any] = (0..<count).map { ($0 + 1) * 10 }
            
            let shrinkers: [AnyShrinker] = (0..<count).map
            {
                _ in
                
                return AnyShrinker({ (v: Int) in v.shrinkTowardZero() })
            }
            
            let candidates: [[Any]] = computeShrinkCandidates(
                of:     values,
                using:  shrinkers
            )
            
            
            
            for i in 0..<count
            {
                let found: Bool = candidates.contains
                {
                    candidate in
                    
                    for j in 0..<count
                    {
                        let original    = values[j]     as! Int
                        let current     = candidate[j]  as! Int
                        
                        if j == i
                        {
                            if current == original
                            {
                                return false
                            }
                        }
                        else
                        {
                            if current != original
                            {
                                return false
                            }
                        }
                    }
                    
                    return true
                }
                
                XCTAssertTrue(found)
            }
        }
    }
    
    
    
    func testMixedTypes() throws
    {
        let values: [Any] = [35, "hello", true]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in       v.shrinkTowardZero() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() }),
            AnyShrinker({ (v: Bool) in      v.shrink() })
        ]
        
        
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        
        
        /// `values[0]` should have shrink candidates. Others held constant.
        let intCandidates: [[Any]] = candidates.filter
        {
            let v = $0[0] as! Int
            
            return v != 35
        }
        
        XCTAssertFalse(intCandidates.isEmpty)
        
        for candidate in intCandidates
        {
            let string  = try XCTUnwrap(candidate[1] as? String)
            let bool    = try XCTUnwrap(candidate[2] as? Bool)
            
            XCTAssertEqual(string, "hello")
            XCTAssertEqual(bool, true)
        }
        
        
        
        /// `values[1]` should have shrink candidates. Others held constant.
        let stringCandidates: [[Any]] = candidates.filter
        {
            let v = $0[1] as! String
            
            return v != "hello"
        }
        
        XCTAssertFalse(stringCandidates.isEmpty)
        
        for candidate in stringCandidates
        {
            let int     = try XCTUnwrap(candidate[0] as? Int)
            let bool    = try XCTUnwrap(candidate[2] as? Bool)
            
            XCTAssertEqual(int, 35)
            XCTAssertEqual(bool, true)
        }
        
        
        
        /// `values[2]` should have shrink candidates. Others held constant.
        let boolCandidates: [[Any]] = candidates.filter
        {
            let v = $0[2] as! Bool
            
            return v != true
        }
        
        XCTAssertEqual(boolCandidates.count, 1)
        
        let boolCandidate: [Any] = boolCandidates[0]
        
        XCTAssertEqual(boolCandidate[0] as! Int, 35)
        XCTAssertEqual(boolCandidate[1] as! String, "hello")
        XCTAssertEqual(boolCandidate[2] as! Bool, false)
    }
    
    
    
    func testPackIndexArrayReconstruction() throws
    {
        let values: [Any] = ["a", 1, true, 2.5]
        
        let packIndex = PackIndex()
        
        let a   = values[packIndex.next()] as! String
        let b   = values[packIndex.next()] as! Int
        let c   = values[packIndex.next()] as! Bool
        let d   = values[packIndex.next()] as! Double
        
        XCTAssertEqual(a, "a")
        XCTAssertEqual(b, 1)
        XCTAssertEqual(c, true)
        XCTAssertEqual(d, 2.5)
    }
    
    
    
    func testNewPackIndexPerCandidate() throws
    {
        let values: [Any] = [10, "x", true]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in       v.shrinkTowardZero() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() }),
            AnyShrinker({ (v: Bool) in      v.shrink() })
        ]
        
        
        
        var reconstructed: [(Int, String, Bool)] = []
        
        for index in values.indices
        {
            for shrunken in shrinkers[index].shrink(values[index])
            {
                var copy: [Any] = values
                
                copy[index] = shrunken
                
                /// Mirror the ``Generator/zip(_:)`` pattern and use a new
                /// ``PackIndex`` instance per candidate.
                let packIndex = PackIndex()
                
                let tuple: (Int, String, Bool) = (
                    copy[packIndex.next()] as! Int,
                    copy[packIndex.next()] as! String,
                    copy[packIndex.next()] as! Bool
                )
                
                reconstructed.append(tuple)
            }
        }
        
        XCTAssertFalse(reconstructed.isEmpty)
        
        for tuple in reconstructed
        {
            var diffCount: Int = 0
            
            if tuple.0 != 10
            {
                diffCount += 1
            }
            
            if tuple.1 != "x"
            {
                diffCount += 1
            }
            
            if tuple.2 != true
            {
                diffCount += 1
            }
            
            XCTAssertEqual(diffCount, 1)
        }
    }
    
    
    
    func testSingleElementTuple() throws
    {
        let input   : Int       = 37
        let values  : [Any]     = [input]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in v.shrinkTowardZero() })
        ]
        
        
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        let expected: [Int] = input.shrinkTowardZero()
        
        XCTAssertEqual(candidates.count, expected.count)
        
        
        
        for (candidate, exp) in zip(candidates, expected)
        {
            XCTAssertEqual(candidate.count, 1)
            
            let value = try XCTUnwrap(candidate[0] as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testPositionWithNoCandidates() throws
    {
        let input   : Int       = 24
        let values  : [Any]     = [false, input]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Bool) in  v.shrink() }),
            AnyShrinker({ (v: Int) in   v.shrinkTowardZero() })
        ]
        
        
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        let expectedIntCandidates: [Int] = input.shrinkTowardZero()
        
        XCTAssertEqual(candidates.count, expectedIntCandidates.count)
        
        
        
        for candidate in candidates
        {
            let bool = try XCTUnwrap(candidate[0] as? Bool)
            
            /// Position `0` should be held constant.
            XCTAssertFalse(bool)
        }
    }
    
    
    
    func testAllPositionsUnshrinkable() throws
    {
        let values: [Any] = [0, false, ""]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in       v.shrinkTowardZero() }),
            AnyShrinker({ (v: Bool) in      v.shrink() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() })
        ]
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testShrinkCandidateCountEqualsSumOfPositions() throws
    {
        /// The total number of shrink candidates must equal the sum of
        /// shrink candidates from each position independently.
        
        let values: [Any] = [10, "ab", true, 5.75]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in       v.shrinkTowardZero() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() }),
            AnyShrinker({ (v: Bool) in      v.shrink() }),
            AnyShrinker({ (v: Double) in    v.shrinkTowardZero() })
        ]
        
        
        
        var candidates      : [[Any]]   = []
        var expectedTotal   : Int       = 0
        
        for index in values.indices
        {
            let positionCandidates: [Any]
                = shrinkers[index].shrink(values[index])
            
            expectedTotal += positionCandidates.count
            
            for shrunken in positionCandidates
            {
                var copy: [Any] = values
                
                copy[index] = shrunken
                
                candidates.append(copy)
            }
        }
        
        XCTAssertEqual(candidates.count, expectedTotal)
        XCTAssertGreaterThan(expectedTotal, 0)
    }
    
    
    
    func testNoCandidateEqualsOriginalValues() throws
    {
        let values: [Any] = [100.25, "abc", true]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Double) in    v.shrinkTowardZero() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() }),
            AnyShrinker({ (v: Bool) in      v.shrink() })
        ]
        
        
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            let isIdentical: Bool =
                (candidate[0] as! Double) == (values[0] as! Double)
                && (candidate[1] as! String) == (values[1] as! String)
                && (candidate[2] as! Bool) == (values[2] as! Bool)
            
            XCTAssertFalse(isIdentical)
        }
    }
    
    
    
    func testEachCandidateDiffersInExactlyOnePosition() throws
    {
        let values: [Any] = [20, "abc", true, 77.0]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in       v.shrinkTowardZero() }),
            AnyShrinker({ (v: String) in    v.shrinkTowardEmpty() }),
            AnyShrinker({ (v: Bool) in      v.shrink() }),
            AnyShrinker({ (v: Double) in    v.shrinkTowardZero() })
        ]
        
        
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            var diffCount: Int = 0
            
            if (candidate[0] as! Int) != (values[0] as! Int)
            {
                diffCount += 1
            }
            
            if (candidate[1] as! String) != (values[1] as! String)
            {
                diffCount += 1
            }
            
            if (candidate[2] as! Bool) != (values[2] as! Bool)
            {
                diffCount += 1
            }
            
            if (candidate[3] as! Double) != (values[3] as! Double)
            {
                diffCount += 1
            }
            
            XCTAssertEqual(diffCount, 1)
        }
    }
    
    
    
    func testSameTypeDifferentShrinkStrategies() throws
    {
        /// The same types but with different shrink strategies must produce
        /// independent shrink candidates according to their own strategy.
        
        let values: [Any] = [50, 50]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in   v.shrinkTowardZero() }),
            AnyShrinker({ _ in          [1] })
        ]
        
        
        
        var candidatesP0    : [[Any]]   = []
        var candidatesP1    : [[Any]]   = []
        
        for index in values.indices
        {
            for shrunken in shrinkers[index].shrink(values[index])
            {
                var copy: [Any] = values
                
                copy[index] = shrunken
                
                if index == 0
                {
                    candidatesP0.append(copy)
                }
                else
                {
                    candidatesP1.append(copy)
                }
            }
        }
        
        
        
        /// Position 0 uses standard shrinking with multiple candidates.
        let expectedP0: [Int] = 50.shrinkTowardZero()
        
        XCTAssertEqual(candidatesP0.count, expectedP0.count)
        
        /// Position 1 uses custom shrinking with only one candidate.
        XCTAssertEqual(candidatesP1.count, 1)
        XCTAssertEqual(candidatesP1[0][0] as! Int, 50)
        XCTAssertEqual(candidatesP1[0][1] as! Int, 1)
    }
    
    
    
    func testShrinkCandidateOrderMatchesPositionOrder() throws
    {
        /// All candidates from position 0 must appear first, then position 1,
        /// and then position 2, matching the iteration order of the
        /// ``Generator/zip(_:)`` shrink loop.
        
        let values: [Any] = [10, true, 20]
        
        let shrinkers: [AnyShrinker] =
        [
            AnyShrinker({ (v: Int) in   v.shrinkTowardZero() }),
            AnyShrinker({ (v: Bool) in  v.shrink() }),
            AnyShrinker({ (v: Int) in   v.shrinkTowardZero() })
        ]
        
        
        
        let p0Count: Int = shrinkers[0].shrink(values[0]).count
        let p1Count: Int = shrinkers[1].shrink(values[1]).count
        let p2Count: Int = shrinkers[2].shrink(values[2]).count
        
        let candidates: [[Any]] = computeShrinkCandidates(
            of:     values,
            using:  shrinkers
        )
        
        XCTAssertEqual(candidates.count, p0Count + p1Count + p2Count)
        
        
        
        for index in 0..<p0Count
        {
            XCTAssertNotEqual(candidates[index][0] as! Int, 10)
            XCTAssertEqual(candidates[index][1] as! Bool, true)
            XCTAssertEqual(candidates[index][2] as! Int, 20)
        }
        
        for index in p0Count..<(p0Count + p1Count)
        {
            XCTAssertEqual(candidates[index][0] as! Int, 10)
            XCTAssertNotEqual(candidates[index][1] as! Bool, true)
            XCTAssertEqual(candidates[index][2] as! Int, 20)
        }
        
        for index in (p0Count + p1Count)..<(p0Count + p1Count + p2Count)
        {
            XCTAssertEqual(candidates[index][0] as! Int, 10)
            XCTAssertEqual(candidates[index][1] as! Bool, true)
            XCTAssertNotEqual(candidates[index][2] as! Int, 20)
        }
    }
    
    
    
    func testShrinkCandidatesMultiElement() throws
    {
        let shrinkers: [AnyShrinker] =
        [
            .makeShrinker(for: Int.self),
            .makeShrinker(for: String.self)
        ]
        
        let p0Count: Int = shrinkers[0].shrink(10).count
        let p1Count: Int = shrinkers[1].shrink("abc").count
        
        let candidates: [[Any]] = AnyShrinker.shrinkCandidates(
            of:     (10, "abc"),
            using:  shrinkers
        )
        
        XCTAssertEqual(candidates.count, p0Count + p1Count)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 2)
            
            var diffCount: Int = 0
            
            if (candidate[0] as! Int) != 10
            {
                diffCount += 1
            }
            
            if (candidate[1] as! String) != "abc"
            {
                diffCount += 1
            }
            
            XCTAssertEqual(diffCount, 1)
        }
        
        
        
        for index in 0..<p0Count
        {
            XCTAssertNotEqual(candidates[index][0] as! Int, 10)
            XCTAssertEqual(candidates[index][1] as! String, "abc")
        }
        
        for index in p0Count..<(p0Count + p1Count)
        {
            XCTAssertEqual(candidates[index][0] as! Int, 10)
            XCTAssertNotEqual(candidates[index][1] as! String, "abc")
        }
    }
    
    
    
    func testShrinkCandidatesSingleElementPack() throws
    {
        let shrinkers   : [AnyShrinker]     = [.makeShrinker(for: Int.self)]
        let input       : Int               = 50
        
        let candidates: [[Any]] = AnyShrinker.shrinkCandidates(
            of:     input,
            using:  shrinkers
        )
        
        let expected: [Int] = input.shrinkTowardZero()
        
        XCTAssertEqual(candidates.count, expected.count)
        
        for (candidate, exp) in zip(candidates, expected)
        {
            let value = try XCTUnwrap(candidate[0] as? Int)
            
            XCTAssertEqual(value, exp)
        }
    }
    
    
    
    func testShrinkCandidatesEmptyValuesWrongShrinkerCount() throws
    {
        /// No shrinkers or values. Nothing to shrink.
        let zeroResult: [[Any]] = AnyShrinker.shrinkCandidates(
            of:     40,
            using:  []
        )
        
        XCTAssertTrue(zeroResult.isEmpty)
        
        /// Two shrinkers, no values. Mismatch. Does not count as a
        /// single-element pack.
        let twoResult: [[Any]] = AnyShrinker.shrinkCandidates(
            of: 40,
            using:
            [
                .makeShrinker(for: Int.self),
                .makeShrinker(for: Int.self)
            ]
        )
        
        XCTAssertTrue(twoResult.isEmpty)
    }
    
    
    
    func testShrinkCandidatesAllUnshrinkable() throws
    {
        let candidates: [[Any]] = AnyShrinker.shrinkCandidates(
            of: (0, false, ""),
            using:
            [
                .makeShrinker(for: Int.self),
                .makeShrinker(for: Bool.self),
                .makeShrinker(for: String.self)
            ]
        )
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testShrinkCandidatesSingleElementPackUnshrinkable() throws
    {
        let candidates: [[Any]] = AnyShrinker.shrinkCandidates(
            of:     0,
            using:  [.makeShrinker(for: Int.self)]
        )
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testShrinkCandidatesSingleElementPackTupleValue() throws
    {
        /// When `T = (Int, String)` in a single-element parameter pack,
        /// `(repeat each T)` collapses to `(Int, String)`. The `Mirror`
        /// reflects this as a tuple with two children, but there is only
        /// one shrinker. The mismatch must be detected and fall through
        /// to the single-element path.
        
        let shrinker = AnyShrinker({
            (v: (Int, String)) -> [(Int, String)] in
            
            var candidates: [(Int, String)] = []
            
            for shrunkenInt in v.0.shrinkTowardZero()
            {
                candidates.append((shrunkenInt, v.1))
            }
            
            return candidates
        })
        
        let value: (Int, String) = (50, "abc")
        
        let candidates: [[Any]] = AnyShrinker.shrinkCandidates(
            of:     value,
            using:  [shrinker]
        )
        
        let expected: [Int] = (50 as Int).shrinkTowardZero()
        
        XCTAssertEqual(candidates.count, expected.count)
        XCTAssertGreaterThan(candidates.count, 0)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
            
            let tuple = try XCTUnwrap(candidate[0] as? (Int, String))
            
            XCTAssertEqual(tuple.1, "abc")
        }
    }
}



// MARK: - Extensions

extension PackShrinkingTests
{
    /// Computes the shrink candidates of the given values.
    /// - Parameters:
    ///   - values: The values for which to compute shrink candidates.
    ///   - shrinkers: The shrinkers to use.
    /// - Returns: The shrink candidates of the given values.
    private func computeShrinkCandidates(
        of      values      : [Any],
        using   shrinkers   : [AnyShrinker]
    ) -> [[Any]]
    {
        var candidates: [[Any]] = []
        
        for index in values.indices
        {
            for shrunken in shrinkers[index].shrink(values[index])
            {
                var copy: [Any] = values
                
                copy[index] = shrunken
                
                candidates.append(copy)
            }
        }
        
        return candidates
    }
}
