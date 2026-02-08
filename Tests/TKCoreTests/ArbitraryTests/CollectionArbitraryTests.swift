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



internal final class CollectionArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testArrayGeneration() throws
    {
        testGeneration(of: Array<Int>.self)
    }
    
    
    
    func testDictionaryGeneration() throws
    {
        testGeneration(of: Dictionary<Int, Int>.self)
    }
    
    
    
    func testSetGeneration() throws
    {
        testGeneration(of: Set<Int>.self)
    }
    
    
    
    func testCollectionOfOneGenerationDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let first   = CollectionOfOne<Int>.arbitrary(using: context1)
            let second  = CollectionOfOne<Int>.arbitrary(using: context2)
            
            XCTAssertEqual(Array(first), Array(second))
        }
    }
    
    
    
    func testCollectionOfOneGenerationSizeZeroProducesZeroElement() throws
    {
        for _ in 0..<1000
        {
            let value = CollectionOfOne<Int>.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value[value.startIndex], 0)
        }
    }
    
    
    
    // MARK: - Array shrinking
    
    func testArrayShrinkEmpty() throws
    {
        let value: [Int] = []
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testArrayShrinkSingleElementNoElementShrink() throws
    {
        let value: [Int] = [0]
        
        XCTAssertEqual(value.shrink(), [[]])
    }
    
    
    
    func testArrayShrinkSingleElementWithElementShrink() throws
    {
        let value       : [Int]     = [50]
        let candidates  : [[Int]]   = value.shrink()
        var expected    : [[Int]]   = []
        
        /// Empty + no halves + removal of the single element (same as empty,
        /// but de-duplicated).
        expected.append([])
        
        /// Shrink individual elements.
        for shrunk in value[0].shrink()
        {
            expected.append([shrunk])
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testArrayShrinkEvenCount() throws
    {
        let value       : [Int]     = [10, 20]
        let candidates  : [[Int]]   = value.shrink()
        var expected    : [[Int]]   = []
        
        /// Empty.
        expected.append([])
        
        /// Halves.
        expected.append([10])
        expected.append([20])
        
        /// Remove individual elements.
        expected.append([20])
        expected.append([10])
        
        /// Shrink individual elements.
        for shrunk in 10.shrink()
        {
            expected.append([shrunk, 20])
        }
        
        for shrunk in 20.shrink()
        {
            expected.append([10, shrunk])
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testArrayShrinkOddCount() throws
    {
        let value       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = value.shrink()
        var expected    : [[Int]]   = []
        
        /// Empty.
        expected.append([])
        
        /// Halves. With an odd count, the middle element is dropped here,
        /// but still covered by individual removal.
        expected.append([10])
        expected.append([30])
        
        /// Remove individual elements.
        expected.append([20, 30])
        expected.append([10, 30])
        expected.append([10, 20])
        
        /// Shrink individual elements.
        for shrunk in 10.shrink()
        {
            expected.append([shrunk, 20, 30])
        }
        
        for shrunk in 20.shrink()
        {
            expected.append([10, shrunk, 30])
        }
        
        for shrunk in 30.shrink()
        {
            expected.append([10, 20, shrunk])
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testArrayShrinkCandidateCount() throws
    {
        let values: [[Int]] =
        [
            [],
            [0],
            [5],
            [1, 2, 3],
            [10, 0, 20, 0, 30]
        ]
        
        for value in values
        {
            let candidates  : [[Int]]   = value.shrink()
            let halves      : Int       = value.count > 1 ? 2 : 0
            let removals    : Int       = value.count == 1 ? 0 : value.count
            
            let elementShrinks: Int
                = value.reduce(0) { $0 + $1.shrink().count }
            
            let expectedCount: Int = value.isEmpty
                ? 0
                : 1 + halves + removals + elementShrinks
            
            XCTAssertEqual(candidates.count, expectedCount)
        }
    }
    
    
    
    func testArrayShrinkFirstCandidateEmpty() throws
    {
        let values: [[Int]] =
        [
            [0],
            [1, 2],
            [5, 10, 15, 20]
        ]
        
        for value in values
        {
            let candidates: [[Int]] = value.shrink()
            
            XCTAssertEqual(candidates.first, [])
        }
    }
    
    
    
    func testArrayShrinkNoCandidateEqualsOriginal() throws
    {
        let values: [[Int]] =
        [
            [0],
            [1, 2],
            [5, 10, 15, 20]
        ]
        
        for value in values
        {
            for candidate in value.shrink()
            {
                XCTAssertNotEqual(candidate, value)
            }
        }
    }
    
    
    
    func testArrayShrinkElementShrinkHoldsOthersConstant() throws
    {
        let value       : [Int]     = [10, 20]
        let candidates  : [[Int]]   = value.shrink()
        
        /// Empty (1) + halves (2) + removals (2) = 5.
        XCTAssertGreaterThanOrEqual(candidates.count, 5)
        
        let elementShrinks = Array(candidates[candidates.count...])
        
        for candidate in elementShrinks
        {
            let differences: Int = zip(value, candidate)
                .filter { $0 != $1 }
                .count
            
            XCTAssertEqual(differences, 1)
        }
    }
    
    
    
    // MARK: - CollectionOfOne shrinking
    
    func testCollectionOfOneShrinkingZeroElement() throws
    {
        let candidates: [CollectionOfOne] = CollectionOfOne<Int>(0).shrink()
        
        XCTAssertEqual(candidates.map { Array($0) }, [])
    }
    
    
    
    func testCollectionOfOneShrinkMatchesElementShrink() throws
    {
        let values: [Int] = [1, 5, 40, -7, -100]
        
        for value in values
        {
            let candidates: [CollectionOfOne] = CollectionOfOne(value).shrink()
            
            let expected: [CollectionOfOne]
                = value.shrink().map { CollectionOfOne($0) }
            
            XCTAssertEqual(
                candidates.map { Array($0) },
                expected.map { Array($0) }
            )
        }
    }
    
    
    
    // MARK: - Dictionary shrinking
    
    func testDictionaryShrinkEmpty() throws
    {
        let value: [Int : Int] = [:]
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testDictionaryShrinkSingleEntryWithValueShrink() throws
    {
        let value       : [Int : Int]       = [0: 50]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        let valueCandidates: [Int] = 50.shrink()
        
        for shrunk in valueCandidates
        {
            XCTAssertTrue(candidates.contains([0: shrunk]))
        }
    }
    
    
    
    func testDictionaryShrinkSingleEntryWithKeyShrink() throws
    {
        let value       : [Int : Int]       = [50: 0]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, [:])
        
        let keyCandidates: [Int] = 50.shrink()
        
        for shrunk in keyCandidates
        {
            XCTAssertTrue(candidates.contains([shrunk: 0]))
        }
    }
    
    
    
    func testDictionaryShrinkFirstCandidateEmpty() throws
    {
        let values: [[Int : Int]] =
        [
            [0: 0],
            [1: 2, 3: 4],
            [10: 20, 30: 40, 50: 60]
        ]
        
        for value in values
        {
            let candidates: [[Int : Int]] = value.shrink()
            
            XCTAssertEqual(candidates.first, [:])
        }
    }
    
    
    
    func testDictionaryShrinkNoCandidateEqualsOriginalAndAllSmaller() throws
    {
        let values: [[Int : Int]] =
        [
            [0: 0],
            [1: 2, 3: 4],
            [10: 20, 30: 40, 50: 60]
        ]
        
        for value in values
        {
            for candidate in value.shrink()
            {
                XCTAssertLessThanOrEqual(candidate.count, value.count)
                XCTAssertNotEqual(candidate, value)
            }
        }
    }
    
    
    
    func testDictionaryShrinkKeyCollisionSkipped() throws
    {
        /// When a key shrinks to a value that already exists as a key in the
        /// dictionary, that candidate is skipped.
        let value       : [Int : String]    = [0: "a", 1: "b"]
        let candidates  : [[Int : String]]  = value.shrink()
        
        for candidate in candidates
        {
            if candidate.count == value.count
            {
                if
                    candidate[0] != nil,
                    candidate[1] != nil
                {
                    /// If both original keys are present, then this is a
                    /// value shrink.
                    continue
                }
                
                /// One key changed. The shrunken key must not map to the
                /// other entry's value, which would indicate a collision
                /// that was not skipped.
                ///
                /// `1` shrinks to `0`, but `0` already exists. So no candidate
                /// may have a key of `0` mapped to a value of `"b"`.
                if let valueAt0: String = candidate[0]
                {
                    XCTAssertEqual(valueAt0, "a")
                }
            }
        }
    }
    
    
    
    func testDictionaryShrinkContainsSubsetsOfExpectedSizes() throws
    {
        let value       : [Int : Int]       = [10: 1, 20: 2, 30: 3, 40: 4]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        XCTAssertTrue(candidates.contains([:]))
        
        /// Halving produces two 2-element subsets. Removal produces four
        /// 3-element subsets.
        let sizes: Set<Int> = Set(candidates.map { $0.count })
        
        XCTAssertTrue(sizes.contains(0))
        XCTAssertTrue(sizes.contains(2))
        XCTAssertTrue(sizes.contains(3))
    }
    
    
    
    func testDictionaryShrinkTwoEntriesContainsAllSingletons() throws
    {
        let value       : [Int : Int]       = [10: 1, 20: 2]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        XCTAssertTrue(candidates.contains([10: 1]))
        XCTAssertTrue(candidates.contains([20: 2]))
    }
    
    
    
    func testDictionaryShrinkValuesPreservesKeys() throws
    {
        /// Value shrink candidates must preserve all original keys.
        let value       : [Int : Int]       = [0: 50, 1: 100]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        let sameCountCandidates: [[Int : Int]]
            = candidates.filter { $0.count == value.count }
        
        for candidate in sameCountCandidates
        {
            let originalKeys: Set<Int> = Set(value.keys)
            
            let allPossibleKeys: Set<Int> = originalKeys.union(
                value.keys.flatMap { $0.shrink() }
            )
            
            /// Same-count candidates come from key or value shrinking.
            /// In either case, the candidate's key set must not be subset
            /// of the expanded key set (original keys + shrunken keys).
            XCTAssertTrue(Set(candidate.keys).isSubset(of: allPossibleKeys))
        }
    }
    
    
    
    func testDictionaryShrinkRemovalProducesCorrectSubsets() throws
    {
        /// Each removal candidate must be a strict subset of the original,
        /// with exactly one entry missing.
        let value       : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = value.shrink()
        
        let removalCandidates: [[Int : Int]]
            = candidates.filter { $0.count == value.count - 1 }
        
        /// There must be one removal candidate per entry.
        XCTAssertEqual(removalCandidates.count, value.count)
        
        for candidate in removalCandidates
        {
            for (key, val) in candidate
            {
                /// Every key-value pair in the candidate must exist in the
                /// original.
                XCTAssertEqual(value[key], val)
            }
        }
    }
    
    
    
    // MARK: - Set shrinking
    
    func testSetShrinkEmpty() throws
    {
        let value: Set<Int> = []
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testSetShrinkSingleZeroElement() throws
    {
        let value       : Set<Int>      = [0]
        let candidates  : [Set<Int>]    = value.shrink()
        
        XCTAssertEqual(candidates, [Set()])
    }
    
    
    
    func testSetShrinkSingleNonZeroElement() throws
    {
        let value       : Set<Int>      = [5]
        let candidates  : [Set<Int>]    = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, Set())
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, value)
        }
    }
    
    
    
    func testSetShrinkFirstCandidateEmpty() throws
    {
        let values: [Set<Int>] =
        [
            [0],
            [1, 2],
            [5, 10, 15, 20]
        ]
        
        for value in values
        {
            let candidates: [Set<Int>] = value.shrink()
            
            XCTAssertEqual(candidates.first, Set())
        }
    }
    
    
    
    func testSetShrinkNoCandidateEqualsOriginal() throws
    {
        let values: [[Int]] =
        [
            [0],
            [1, 2],
            [5, 10, 15],
            [10, 20, 30, 40]
        ]
        
        for value in values
        {
            for candidate in value.shrink()
            {
                XCTAssertNotEqual(candidate, value)
            }
        }
    }
    
    
    
    func testSetShrinkCandidatesContainShrunkenElements() throws
    {
        /// Use a set in which the elements do not shrink to each other,
        /// so singletons remain distinct after array shrinking.
        let value       : Set<Int>      = [50]
        let candidates  : [Set<Int>]    = value.shrink()
        
        let elementCandidates: [Int] = 50.shrink()
        
        XCTAssertFalse(elementCandidates.isEmpty)
        
        for shrunk in elementCandidates
        {
            XCTAssertTrue(candidates.contains([shrunk]))
        }
    }
    
    
    
    func testSetShrinkContainsEmptyAndSubsets() throws
    {
        let value       : Set<Int>      = [10, 20]
        let candidates  : [Set<Int>]    = value.shrink()
        
        XCTAssertTrue(candidates.contains(Set()))
        XCTAssertTrue(candidates.contains([10]))
        XCTAssertTrue(candidates.contains([20]))
    }
    
    
    
    func testSetShrinkDuplicatesCollapsing() throws
    {
        let value       : Set<Int>      = [10, 20]
        let candidates  : [Set<Int>]    = value.shrink()
        
        let singletons: [Set<Int>] = candidates.filter { $0.count == 1 }
        
        XCTAssertFalse(singletons.isEmpty)
    }
    
    
    
    func testSetShrinkFourElements() throws
    {
        let value       : Set<Int>      = [10, 20, 30, 40]
        let candidates  : [Set<Int>]    = value.shrink()
        
        XCTAssertTrue(candidates.contains(Set()))
        
        /// Halving produces two 2-element subsets. Removal produces four
        /// 3-element subsets.
        let sizes: Set<Int> = Set(candidates.map { $0.count })
        
        XCTAssertTrue(sizes.contains(0))
        XCTAssertTrue(sizes.contains(2))
        XCTAssertTrue(sizes.contains(3))
    }
    
    
    
    func testSetShrinkCandidateCountMatchesArrayShrink() throws
    {
        let values: [Set<Int>] =
        [
            [],
            [0],
            [5],
            [1, 2, 3],
            [10, 20, 30, 40]
        ]
        
        for value in values
        {
            let setCandidates   : [Set<Int>]    = value.shrink()
            let arrayCandidates : [[Int]]       = Array(value).shrink()
            
            XCTAssertEqual(setCandidates.count, arrayCandidates.count)
        }
    }
    
    
    
    func testSetShrinkAllCandidatesStrictlySmaller() throws
    {
        let values: [Set<Int>] =
        [
            [5],
            [1, 2],
            [10, 20, 30],
            [5, 10, 15, 20]
        ]
        
        for value in values
        {
            for candidate in value.shrink()
            {
                XCTAssertLessThanOrEqual(candidate.count, value.count)
                XCTAssertNotEqual(candidate, value)
            }
        }
    }
}



// MARK: - Extensions

private extension CollectionArbitraryTests
{
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    func testGeneration<T>(
        of type: T.Type
    ) where T : Arbitrary & Collection & Equatable
    {
        validateDeterminism(of: type)
        validateSizeZeroProducesEmpty(for: type)
        validateCountRespectsSizeBounds(for: type)
        validateProducesEmptyAndNonEmpty(for: type)
        validateProducesVariousCounts(for: type)
    }
    
    
    
    /// Validates that arbitrary value generation of the given type is
    /// deterministic.
    /// - Parameter type: The type to evaluate.
    func validateDeterminism<T>(
        of type: T.Type
    ) where T : Arbitrary & Collection & Equatable
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                T.arbitrary(using: context1),
                T.arbitrary(using: context2)
            )
        }
    }
    
    
    
    /// Validates that a size of zero produces empty collections.
    /// - Parameter type: The type to evaluate.
    func validateSizeZeroProducesEmpty<T>(
        for type: T.Type
    ) where T : Arbitrary & Collection
    {
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomZeroSize)
            
            XCTAssertTrue(value.isEmpty)
        }
    }
    
    
    
    /// Validates generated collection counts do not exceed the generation size.
    /// - Parameter type: The type to evaluate.
    func validateCountRespectsSizeBounds<T>(
        for type: T.Type
    ) where T : Arbitrary & Collection
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let value = T.arbitrary(using: context)
            
            XCTAssertLessThanOrEqual(value.count, size)
        }
    }
    
    
    
    /// Validates that arbitrary value generation produces both empty and
    /// non-empty collections.
    /// - Parameter type: The type to evaluate.
    func validateProducesEmptyAndNonEmpty<T>(
        for type: T.Type
    ) where T : Arbitrary & Collection
    {
        var hasEmpty    : Bool  = false
        var hasNonEmpty : Bool  = false
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .random)
            
            if value.isEmpty
            {
                hasEmpty = true
            }
            else
            {
                hasNonEmpty = true
            }
            
            if
                hasEmpty,
                hasNonEmpty
            {
                break
            }
        }
        
        XCTAssertTrue(hasEmpty)
        XCTAssertTrue(hasNonEmpty)
    }
    
    
    
    /// Validates that arbitrary value generation produces collections of
    /// various counts.
    /// - Parameter type: The type to evaluate.
    func validateProducesVariousCounts<T>(
        for type: T.Type
    ) where T : Arbitrary & Collection
    {
        let size    : Int       = 20
        var counts  : Set<Int>  = []
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let value = T.arbitrary(using: context)
            
            counts.insert(value.count)
        }
        
        XCTAssertGreaterThan(counts.count, 10)
    }
}
