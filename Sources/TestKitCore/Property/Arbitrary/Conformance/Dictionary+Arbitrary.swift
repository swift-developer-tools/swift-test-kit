//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Dictionary : Arbitrary where Key : Arbitrary, Value : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A dictionary with `0...context.size` entries, filled with
    /// arbitrary keys and values. Duplicate keys are resolved by keeping the
    /// latest value.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Dictionary
    {
        let count: Int = context.random(in: 0...context.size)
        
        let keys: [Key]
            = (0..<count).map { _ in Key.arbitrary(using: context) }
        
        let values: [Value]
            = (0..<count).map { _ in Value.arbitrary(using: context) }
        
        return Dictionary(
            zip(keys, values),
            uniquingKeysWith: { _, latest in latest }
        )
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates include the empty dictionary, each of the entries, the
    /// dictionary with individual entries removed, and the dictionary with
    /// individual keys or values shrunk. Key shrink candidates that would
    /// collide with an existing key are skipped.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Dictionary]
    {
        guard !isEmpty
        else
        {
            return []
        }
        
        var candidates  : [Dictionary]      = []
        let entries     : [(Key, Value)]    = Array(self)
        
        candidates.append([:])
        
        
        
        if entries.count > 1
        {
            /// If the count is odd, the middle entry is dropped here,
            /// but will be included in the individual removal step.
            let firstHalf = Dictionary(
                uniqueKeysWithValues: entries.prefix(entries.count / 2)
            )
            
            let secondHalf = Dictionary(
                uniqueKeysWithValues: entries.suffix(entries.count / 2)
            )
            
            candidates.append(firstHalf)
            candidates.append(secondHalf)
        }
        
        
        
        /// Remove individual entries.
        for index in entries.indices
        {
            var copy: [(Key, Value)] = entries
            
            copy.remove(at: index)
            
            candidates.append(Dictionary(uniqueKeysWithValues: copy))
        }
        
        
        
        /// Shrink individual keys and values.
        for index in entries.indices
        {
            let (key, value): (Key, Value) = entries[index]
            
            
            
            for shrunkenKey in key.shrink()
            {
                guard self[shrunkenKey] == nil
                else
                {
                    /// Skip if the shrunken key would collide with an
                    /// existing key.
                    continue
                }
                
                var copy: [(Key, Value)] = entries
                
                copy[index] = (shrunkenKey, value)
                
                candidates.append(Dictionary(uniqueKeysWithValues: copy))
            }
            
            
            
            for shrunkenValue in value.shrink()
            {
                var copy: [(Key, Value)] = entries
                
                copy[index] = (key, shrunkenValue)
                
                candidates.append(Dictionary(uniqueKeysWithValues: copy))
            }
        }
        
        
        
        return candidates
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated dictionary.
    public func mutate(
        using context: GenerationContext
    ) -> Dictionary
    {
        /// There is a 70% chance of mutating in place, 15% chance of
        /// inserting an element, and 15% chance if removing an element.
        
        if isEmpty
        {
            let key     = Key.arbitrary(using: context)
            let value   = Value.arbitrary(using: context)
            
            return [key: value]
        }
        
        let chance  : Int           = context.random(in: 1...20)
        var copy    : Dictionary    = self
        
        if chance <= 14
        {
            let keys : [Key] = Array(self.keys)
            let key  : Key   = keys[context.random(in: 0...(keys.count - 1))]
            
            copy[key] = copy[key]!.mutate(using: context)
        }
        else if chance <= 17
        {
            let key = Key.arbitrary(using: context)
            
            copy[key] = Value.arbitrary(using: context)
        }
        else
        {
            let keys : [Key] = Array(self.keys)
            let key  : Key   = keys[context.random(in: 0...(keys.count - 1))]
            
            copy.removeValue(forKey: key)
        }
        
        return copy
    }
}
