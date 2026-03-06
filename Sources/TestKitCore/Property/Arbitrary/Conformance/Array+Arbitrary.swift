//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Array: Arbitrary where Element : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An array of with a length in the range `0...context.size`,
    /// filled with arbitrary elements.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Array
    {
        let count: Int = context.random(in: 0...context.size)
        
        return (0..<count).map { _ in Element.arbitrary(using: context) }
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates include the empty array, each half of the array, the array
    /// with individual elements removed, and the array with individual
    /// elements shrunk.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Array]
    {
        return shrinkTowardEmpty()
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated array.
    public func mutate(
        using context: GenerationContext
    ) -> Array
    {
        return mutateElements(
            using:          context,
            mutateElement:  { $0.mutate(using: $1 )},
            makeElement:    { Element.arbitrary(using: $0) }
        )
    }
    
    
    
    // MARK: - Support
    
    /// Shrinks the array by removing elements and shrinking individual
    /// elements.
    /// - Returns: The shrink candidates.
    internal func shrinkTowardEmpty() -> [[Element]]
    {
        return shrinkToward(minCount: 0)
    }
    
    
    
    /// Shrinks the array by removing elements (down to the given minimum
    /// count) and shrinking individual elements.
    ///
    /// Candidates include the minimum-length prefix, halves clamped to the
    /// minimum count, individual element removals, and individual element
    /// shrinks.
    ///
    /// - Parameter minCount: The minimum number of elements.
    /// - Returns: The shrink candidates.
    internal func shrinkToward(
        minCount: Int
    ) -> [[Element]]
    {
        return shrinkToward(
            minCount:           minCount,
            shrinkElements:     self.shrinkElements
        )
    }
    
    
    
    /// Shrinks individual elements of the array, holding the others constant.
    /// - Returns: The shrink candidates.
    internal func shrinkElements() -> [[Element]]
    {
        return shrinkElements(by: { $0.shrink() })
    }
}



extension Array
{
    /// Shrinks the array by removing elements (down to the given minimum
    /// count) and shrinking individual elements.
    ///
    /// Candidates include the minimum-length prefix, halves clamped to the
    /// minimum count, individual element removals, and individual element
    /// shrinks.
    ///
    /// - Parameters:
    ///   - minCount: The minimum number of elements.
    ///   - shrinkElements: Shrinks individual elements of the array.
    ///   ``Array/shrinkElements()``.
    /// - Returns: The shrink candidates.
    internal func shrinkToward(
        minCount        : Int,
        shrinkElements  : () -> [[Element]]
    ) -> [[Element]]
    {
        guard !isEmpty
        else
        {
            return []
        }
        
        var candidates: [[Element]] = []
        
        if minCount == 0
        {
            candidates.append([])
        }
        
        
        
        /// Minimum count.
        if
            minCount != 0,
            count > minCount
        {
            candidates.append(Array(prefix(minCount)))
        }
        
        
        
        /// Halves, clamped to the minimum count.
        if count > minCount + 1
        {
            let halfCount: Int = Swift.max(count / 2, minCount)
            
            if
                halfCount != minCount,
                halfCount != count
            {
                /// If the count is odd, the middle element is dropped here,
                /// but will be included in the individual removal step.
                candidates.append(Array(prefix(halfCount)))
                candidates.append(Array(suffix(halfCount)))
            }
            
            /// Remove individual elements.
            for index in indices
            {
                var copy: [Element] = self
                
                copy.remove(at: index)
                
                candidates.append(copy)
            }
        }
        
        
        
        /// Shrink individual elements.
        candidates.append(contentsOf: shrinkElements())
        
        
        
        return candidates
    }
    
    
    
    /// Shrinks individual elements of the array, holding the others constant.
    /// - Parameter shrink: Shrinks the given element.
    /// - Returns: The shrink candidates.
    internal func shrinkElements(
        by shrink: (Element) -> [Element]
    ) -> [[Element]]
    {
        var candidates: [[Element]] = []
        
        for index in indices
        {
            for shrunkenElement in shrink(self[index])
            {
                var copy: [Element] = self
                
                copy[index] = shrunkenElement
                
                candidates.append(copy)
            }
        }
        
        return candidates
    }
    
    
    
    /// Mutates the value by modifying, inserting, or removing an element.
    ///
    /// There is a 70% chance of mutating in place, 15% chance of inserting
    /// an element, and 15% chance if removing an element.
    /// 
    /// - Parameters:
    ///   - context: The generation context.
    ///   - mutateElement: Mutates the given element.
    ///   - makeElement: Creates an element.
    /// - Returns: A mutated array.
    internal func mutateElements(
        using context   : GenerationContext,
        mutateElement   : (Element, GenerationContext) -> Element,
        makeElement     : (GenerationContext) -> Element
    ) -> [Element]
    {
        var copy: [Element] = self
        
        if copy.isEmpty
        {
            copy.append(makeElement(context))
            
            return copy
        }
        
        let chance: Int = context.random(in: 1...20)
        
        if
            chance <= 14
            || copy.count == 1
        {
            let index: Int = context.random(in: 0...(copy.count - 1))
            
            copy[index] = mutateElement(copy[index], context)
        }
        else if chance <= 17
        {
            let index: Int = context.random(in: 0...copy.count)
            
            copy.insert(
                makeElement(context),
                at: index
            )
        }
        else
        {
            let index: Int = context.random(in: 0...(copy.count - 1))
            
            copy.remove(at: index)
        }
        
        return copy
    }
}
