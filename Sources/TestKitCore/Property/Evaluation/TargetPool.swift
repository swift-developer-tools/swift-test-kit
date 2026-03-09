//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The pool of high-target-value entries retained for mutation during
/// targeted property-based testing.
internal struct TargetPool<T>
{
    /// The maximum pool capacity.
    private let capacity    : Int
    
    /// The pool entries, sorted by ascending target value.
    private var entries     : [Entry]
    
    
    
    /// Initializes a ``TargetPool`` instance from the given capacity.
    ///
    /// - Precondition: `capacity` must be positive.
    ///
    /// - Parameter capacity: The maximum pool capacity.
    internal init(
        capacity: Int
    )
    {
        precondition(
            capacity > 0,
            "capacity must be positive"
        )
        
        self.capacity   = capacity
        self.entries    = []
        
        self.entries.reserveCapacity(capacity)
    }
    
    
    
    /// Whether the pool is empty.
    internal var isEmpty: Bool
    {
        return entries.isEmpty
    }
    
    
    
    /// Inserts the specified entry into the pool.
    /// - Parameters:
    ///   - value: The entry's value.
    ///   - target: The entry's target value.
    internal mutating func insert(
        value   : T,
        target  : Double
    )
    {
        let entry = Entry(
            value:      value,
            target:     target
        )
        
        if entries.count < capacity
        {
            entries.insert(
                entry,
                at: insertionIndex(for: target)
            )
        }
        else if target > entries[0].target
        {
            entries.removeFirst()
            
            entries.insert(
                entry,
                at: insertionIndex(for: target)
            )
        }
    }
    
    
    
    /// Selects a random entry from the pool for mutation, biased toward
    /// high-target-value entries.
    ///
    /// Entries are weighted by rank, not magnitude. For example, if the pool
    /// has three entries with target values of `100`, `110`, and `200`, then
    /// their weights will be `1 / 6`, `2 / 6`, and `3 / 6`, respectively.
    /// The weights are derived from the sorted positions (`index + 1`). The
    /// entry with a target value of `110` has twice the weight of the
    /// next-lowest target (`100`), although it represents only a 10%
    /// improvement.
    ///
    /// Ranked-based weighting avoids complications with negative or zero
    /// target values that would be introduced by absolute-value weighting.
    /// The tradeoff is that there is no sensitivity to how much better one
    /// entry is than another.
    ///
    /// - Precondition: The pool must not be empty.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: The selected entry.
    internal func select(
        using context: GenerationContext
    ) -> T
    {
        precondition(
            !isEmpty,
            "Cannot select from an empty pool"
        )
        
        let selected: (offset: Int, element: Entry)?
            = context.randomElement(
                of:             Array(entries.enumerated()),
                weightedBy:     { $0.offset + 1 }
            )
        
        return selected!.element.value
    }
    
    
    
    // MARK: - Support
    
    /// An entry in the target pool.
    private struct Entry
    {
        /// The entry's value.
        let value   : T
        
        /// The entry's target value.
        let target  : Double
    }
    
    
    
    /// Computes the index at which an entry with the given target value
    /// shoudl be inserted to maintain ascending sort order.
    /// - Parameter target: The entry's target value.
    /// - Returns: The computed index.
    private func insertionIndex(
        for target: Double
    ) -> Int
    {
        var low     : Int   = 0
        var high    : Int   = entries.count
        
        while low < high
        {
            let mid: Int = low + (high - low) / 2
            
            if entries[mid].target < target
            {
                low = mid + 1
            }
            else
            {
                high = mid
            }
        }
        
        return low
    }
}
