//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Set: Arbitrary where Element : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A set formed from an arbitrary array. The resulting count
    /// may be less than the array's count due to duplicate elimination.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Set
    {
        return Set(Array.arbitrary(using: context))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates are produced by converting to an array, shrinking the
    /// array, and converting back to a set. Candidate ordering is
    /// non-deterministic.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Set]
    {
        /// Set shrinking is not deterministic since the array is not sorted,
        /// so the same set can produce shrink candidates in different orders.
        ///
        /// The array is not sorted since that would require constraining
        /// the elements to `Comparable`. It could be sorted by `hashValue`,
        /// but that is not guaranteed to be equal across executions.
        let arrays: [[Element]] = Array(self).shrink()
        
        return arrays.map { Set($0) }
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated set.
    public func mutate(
        using context: GenerationContext
    ) -> Set
    {
        /// There is a 70% chance of mutating in place, 15% chance of
        /// inserting an element, and 15% chance if removing an element.
        
        if isEmpty
        {
            return Set([Element.arbitrary(using: context)])
        }
        
        let chance  : Int   = context.random(in: 1...20)
        var copy    : Set   = self
        
        if
            chance <= 14
            || copy.count == 1
        {
            let index: Int = context.random(in: 0...(copy.count - 1))
            
            let elements    : [Element]     = Array(self)
            let original    : Element       = elements[index]
            
            copy.remove(original)
            copy.insert(original.mutate(using: context))
        }
        else if chance <= 17
        {
            copy.insert(Element.arbitrary(using: context))
        }
        else
        {
            let index: Int = context.random(in: 0...(copy.count - 1))
            
            let elements    : [Element]     = Array(self)
            let original    : Element       = elements[index]
            
            copy.remove(original)
        }
        
        return copy
    }
}
