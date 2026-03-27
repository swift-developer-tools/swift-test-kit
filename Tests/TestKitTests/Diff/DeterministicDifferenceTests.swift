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



internal final class DeterministicDifferenceTests: TestKitCase
{
    // MARK: - Determinism
    
    func testDeterminism()
    {
        for _ in 0..<1000
        {
            let old : [Int]     = .arbitrary(using: .random)
            let new : [Int]     = .arbitrary(using: .random)
            
            let diff1: CollectionDifference<Int>
                = new.deterministicDifference(from: old)
            
            let diff2: CollectionDifference<Int>
                = new.deterministicDifference(from: old)
            
            XCTAssertEqual(diff1, diff2)
        }
    }
    
    
    
    // MARK: - Empty
    
    func testBothEmpty()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [],
            to:     []
        )
        
        XCTAssertTrue(diff.isEmpty)
    }
    
    
    
    // MARK: - Equal
    
    func testEqualCollections()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3],
            to:     [1, 2, 3]
        )
        
        XCTAssertTrue(diff.isEmpty)
    }
    
    
    
    // MARK: - Single element
    
    func testSingleElementDifference()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1],
            to:     [2]
        )
        
        assertChanges(
            diff,
            removals:       [(offset: 0, element: 1)],
            insertions:     [(offset: 0, element: 2)]
        )
    }
    
    
    
    // MARK: - Only insertions
    
    func testOnlyInsertions()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [],
            to:     [1, 2, 3]
        )
        
        assertChanges(
            diff,
            removals: [],
            insertions:
            [
                (offset: 0, element: 1),
                (offset: 1, element: 2),
                (offset: 2, element: 3)
            ]
        )
    }
    
    
    
    // MARK: - Only removals
    
    func testOnlyRemovals()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3],
            to:     []
        )
        
        assertChanges(
            diff,
            removals:
            [
                (offset: 0, element: 1),
                (offset: 1, element: 2),
                (offset: 2, element: 3)
            ],
            insertions: []
        )
    }
    
    
    
    // MARK: - Duplicates
    
    func testDuplicateElements()
    {
        assertDiff(
            from:   [1, 1, 1, 2, 2, 2, 3],
            to:     [1, 1, 2, 1, 1, 3, 3]
        )
    }
    
    
    
    // MARK: - Trimming
    
    func testCommonPrefixDiffAtEnd()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3],
            to:     [1, 2, 4]
        )
        
        assertChanges(
            diff,
            removals:       [(offset: 2, element: 3)],
            insertions:     [(offset: 2, element: 4)]
        )
    }
    
    
    
    func testCommonSuffixDiffAtStart()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3],
            to:     [4, 2, 3]
        )
        
        assertChanges(
            diff,
            removals:       [(offset: 0, element: 1)],
            insertions:     [(offset: 0, element: 4)]
        )
    }
    
    
    
    func testCommonPrefixAndSuffixDiffInMiddle()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3, 4],
            to:     [1, 5, 6, 4]
        )
        
        assertChanges(
            diff,
            removals:
            [
                (offset: 1, element: 2),
                (offset: 2, element: 3)
            ],
            insertions:
            [
                (offset: 1, element: 5),
                (offset: 2, element: 6)
            ]
        )
    }
    
    
    
    func testInsertionsAfterTrimming()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2],
            to:     [1, 3, 4, 2]
        )
        
        assertChanges(
            diff,
            removals: [],
            insertions:
            [
                (offset: 1, element: 3),
                (offset: 2, element: 4)
            ]
        )
    }
    
    
    
    func testRemovalsAfterTrimming()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 3, 4, 2],
            to:     [1, 2]
        )
        
        assertChanges(
            diff,
            removals:
            [
                (offset: 1, element: 3),
                (offset: 2, element: 4)
            ],
            insertions: []
        )
    }
    
    
    
    // MARK: - Other
    
    func testSingleSubstituationInMiddle()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3, 4, 5],
            to:     [1, 2, 9, 4, 5]
        )
        
        assertChanges(
            diff,
            removals:       [(offset: 2, element: 3)],
            insertions:     [(offset: 2, element: 9)]
        )
    }
    
    
    
    func testMultipleScatteredChanges()
    {
        let diff: CollectionDifference<Int> = assertDiff(
            from:   [1, 2, 3, 4, 5],
            to:     [1, 9, 3, 8, 5]
        )
        
        assertChanges(
            diff,
            removals:
            [
                (offset: 1, element: 2),
                (offset: 3, element: 4)
            ],
            insertions:
            [
                (offset: 1, element: 9),
                (offset: 3, element: 8)
            ]
        )
    }
    
    
    
    func testCompletelyDifferent()
    {
        let old : [Int]     = [1, 2, 3]
        let new : [Int]     = [4, 5, 6]
        
        let diff: CollectionDifference<Int> = assertDiff(
            from:   old,
            to:     new
        )
        
        XCTAssertEqual(
            diff.removals.count + diff.insertions.count,
            old.count + new.count
        )
    }
}



// MARK: - Support

extension DeterministicDifferenceTests
{
    /// Computes the diff of the given values, and validates that applying the
    /// diff to `old` produces `new`.
    /// - Parameters:
    ///   - old: The old value.
    ///   - new: The new value.
    /// - Returns: The diff.
    @discardableResult
    private func assertDiff<T>(
        from    old : [T],
        to      new : [T]
    ) -> CollectionDifference<T> where T : Equatable
    {
        let diff: CollectionDifference<T>
            = new.deterministicDifference(from: old)
        
        let applied: [T]? = old.applying(diff)
        
        XCTAssertEqual(applied, new)
        
        return diff
    }
    
    
    
    /// Asserts that the given diff contains exactly the expected removals
    /// and insertions.
    /// - Parameters:
    ///   - diff: The diff to validate.
    ///   - removals: The expected removals.
    ///   - insertions: The expected insertions.
    private func assertChanges<T>(
        _ diff      : CollectionDifference<T>,
        removals    : [(offset: Int, element: T)],
        insertions  : [(offset: Int, element: T)]
    ) where T : Equatable
    {
        let expectedRemovals: [CollectionDifference<T>.Change]
            = removals.map
        {
            return .remove(
                offset:             $0.offset,
                element:            $0.element,
                associatedWith:     nil
            )
        }
        
        let expectedInsertions: [CollectionDifference<T>.Change]
            = insertions.map
        {
            return .insert(
                offset:             $0.offset,
                element:            $0.element,
                associatedWith:     nil
            )
        }
        
        XCTAssertEqual(Array(diff.removals), expectedRemovals)
        XCTAssertEqual(Array(diff.insertions), expectedInsertions)
    }
}
