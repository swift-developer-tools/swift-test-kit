//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension BidirectionalCollection where Element : Equatable
{
    /// Computes the difference needed to transform the given collection into
    /// the receiver collection, using a deterministic Myers diff algorithm.
    ///
    /// Unlike `BidirectionalCollection.difference(from:)`, this produces
    /// identical results across all platforms and OS versions. The standard
    /// library results vary between OS releases.
    ///
    /// Both this implementation and the standard library have time complexity
    /// of `O((N+M)×D)`, where `D` is the number of differences. This also has
    /// space complexity of `O((N+M)×D)`, since it stores snapshots for
    /// traceback. The standard library has space complexity of `O(N+M)`, since
    /// it uses a linear-space approach, but that approach is not deterministic.
    ///
    /// - Parameter other: The collection to compare.
    /// - Returns: The difference needed to transform `other` into `self`.
    internal func deterministicDifference<C>(
        from other: C
    ) -> CollectionDifference<Element>
        where C : BidirectionalCollection, C.Element == Element
    {
        let old : [Element]     = Array(other)
        let new : [Element]     = Array(self)
        let n   : Int           = old.count
        let m   : Int           = new.count
        
        guard
            n > 0
            || m > 0
        else
        {
            return CollectionDifference<Element>([])!
        }
        
        
        
        // MARK: - Prefix/suffix trimming
        
        var prefixCount : Int   = 0
        var suffixCount : Int   = 0
        
        while
            prefixCount < n,
            prefixCount < m,
            old[prefixCount] == new[prefixCount]
        {
            prefixCount += 1
        }
        
        while
            suffixCount < (n - prefixCount),
            suffixCount < (m - prefixCount),
            old[n - 1 - suffixCount] == new[m - 1 - suffixCount]
        {
            suffixCount += 1
        }
        
        
        
        let trimmedOld: ArraySlice<Element>
            = old[prefixCount..<(n - suffixCount)]
        
        let trimmedNew: ArraySlice<Element>
            = new[prefixCount..<(m - suffixCount)]
        
        let tn  : Int   = trimmedOld.count
        let tm  : Int   = trimmedNew.count
        
        guard
            tn > 0
            || tm > 0
        else
        {
            /// The collections are equal after trimming.
            return CollectionDifference<Element>([])!
        }
        
        
        
        /// Handle cases where only one side is empty after trimming.
        /// All remaining elements are either removals or insertions.
        
        if tn == 0
        {
            let changes: [CollectionDifference<Element>.Change]
                = trimmedNew.enumerated().map
            {
                return .insert(
                    offset:             prefixCount + $0.offset,
                    element:            $0.element,
                    associatedWith:     nil
                )
            }
            
            return CollectionDifference<Element>(changes)!
        }
        
        if tm == 0
        {
            let changes: [CollectionDifference<Element>.Change]
                = trimmedOld.enumerated().map
            {
                return .remove(
                    offset:             prefixCount + $0.offset,
                    element:            $0.element,
                    associatedWith:     nil
                )
            }
            
            return CollectionDifference<Element>(changes)!
        }
        
        
        
        // MARK: - Forward pass
        
        let a   : [Element]     = Array(trimmedOld)
        let b   : [Element]     = Array(trimmedNew)
        
        /// The `v` array is indexed by a diagonal (`k`) of matching elements
        /// `k ∈ [-maxD, maxD]`, where `k = x - y`. `v[k + offset]` stores
        /// the furthest x-coordinate reached on the diagonal.
        let maxD    : Int       = tn + tm
        let offset  : Int       = maxD
        let size    : Int       = 2 * maxD + 1
        var foundD  : Int       = 0
        var v       : [Int]     = Array(repeating: 0, count: size)
        
        /// Snapshots of the `v` array after each completed step, to be used
        /// during traceback to reconstruct the edit path.
        var snapshots: [[Int]] = []
        
        snapshots.reserveCapacity(maxD + 1)
        
        
        
        search: for d in 0...maxD
        {
            for k in stride(from: -d, through: d, by: 2)
            {
                var x: Int
                
                if
                    k == -d
                    || (
                        k != d
                        && v[k - 1 + offset] < v[k + 1 + offset]
                    )
                {
                    /// Move down. Insertion from new.
                    x = v[k + 1 + offset]
                }
                else
                {
                    /// Move right. Deletion from old.
                    x = v[k - 1 + offset] + 1
                }
                
                var y: Int = x - k
                
                /// Follow the diagonal (matching elements).
                while
                    x < tn,
                    y < tm,
                    a[x] == b[y]
                {
                    x += 1
                    y += 1
                }
                
                v[k + offset] = x
                
                if
                    x >= tn,
                    y >= tm
                {
                    foundD = d
                    snapshots.append(v)
                    break search
                }
            }
            
            snapshots.append(v)
        }
        
        
        
        // MARK: - Traceback
        
        /// Walk backward through the snapshots to extract the edit operations.
        /// At each step, determine whether the edit was a deletion (moved
        /// right) or an insertion (moved down).
        ///
        /// When two predecessors reach the same x-coordinate, prefer deletion.
        var changes: [CollectionDifference<Element>.Change] = []
        
        changes.reserveCapacity(foundD)
        
        var x   : Int   = tn
        var y   : Int   = tm
        
        for d in stride(from: foundD, through: 1, by: -1)
        {
            let k           : Int       = x - y
            let snapshot    : [Int]     = snapshots[d - 1]
            let prevK       : Int
            
            if k == -d
            {
                /// At the lower boundary. The predecessor must be on the
                /// diagonal `k + 1`.
                prevK = k + 1
            }
            else if k == d
            {
                /// At the upper boundary. The predecessor must be on the
                /// diagonal `k - 1`.
                prevK = k - 1
            }
            else if snapshot[k - 1 + offset] < snapshot[k + 1 + offset]
            {
                /// The predecessor on diagonal `k + 1` reached further.
                prevK = k + 1
            }
            else
            {
                /// The predecessor on diagonal `k - 1` reached at least as
                /// far. Prefer deletion for determinism.
                prevK = k - 1
            }
            
            let prevX   : Int   = snapshot[prevK + offset]
            let prevY   : Int   = prevX - prevK
            
            if prevK == k - 1
            {
                changes.append(.remove(
                    offset:             prefixCount + prevX,
                    element:            a[prevX],
                    associatedWith:     nil
                ))
            }
            else
            {
                changes.append(.insert(
                    offset:             prefixCount + prevY,
                    element:            b[prevY],
                    associatedWith:     nil
                ))
            }
            
            x = prevX
            y = prevY
        }
        
        
        
        return CollectionDifference<Element>(changes)!
    }
}
