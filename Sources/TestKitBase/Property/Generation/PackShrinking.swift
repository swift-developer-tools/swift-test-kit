//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - AnyShrinker

/// A type-erased shrinker for indexed shrinking of parameter pack elements.
package struct AnyShrinker
{
    /// Shrinks the given value.
    private let _shrink: (Any) -> [Any]
    
    
    
    /// Initializes an ``AnyShrinker`` instance from the given shrink function.
    /// - Parameter shrink: The function to shrink a given value.
    package init<T>(
        _ shrink: @escaping (T) -> [T]
    )
    {
        self._shrink =
        {
            value in
            
            return shrink(value as! T).map { $0 as Any }
        }
    }
    
    
    
    /// Shrinks the given value.
    /// - Parameter value: The value to shrink.
    /// - Returns: The shrink candidates.
    package func shrink(
        _ value: Any
    ) -> [Any]
    {
        return _shrink(value)
    }
    

    
    /// Generates shrink candidates from the given values.
    ///
    /// Each candidate is a copy of `values` with one element replace by a
    /// shrunken alternative.
    ///
    /// - Parameters:
    ///   - values: The mirrored tuple children, or an empty array for
    ///   single-element packs.
    ///   - original: The original tuple value. This is used only for
    ///   single-element packs.
    ///   - shrinkers: The shrinkers for each element.
    /// - Returns: The type-erased shrink candidates.
    package static func shrinkCandidates(
        values      : [Any],
        original    : Any,
        shrinkers   : [AnyShrinker]
    ) -> [[Any]]
    {
        var candidates: [[Any]] = []
        
        /// Single-element packs are flattened to the underlying element
        /// (`(T)` becomes `T`). `Mirror` has no children for non-tuple values.
        guard !values.isEmpty
        else
        {
            guard shrinkers.count == 1
            else
            {
                return []
            }
            
            for shrunken in shrinkers[0].shrink(original)
            {
                candidates.append([shrunken])
            }
            
            return candidates
        }
        
        
        
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



// MARK: - PackIndex

/// A sequential counter for reconstructing typed tuples from arrays via
/// pack expansion.
package final class PackIndex
{
    /// The current pack index.
    private var current: Int = 0
    
    
    
    /// Initializes a ``PackIndex`` instance.
    package init() { }
    
    
    
    /// Gets the next pack index.
    ///
    /// Each call to this method returns and increments ``current``. This
    /// allows `repeat array[index.next()] as! each T` to map each pack
    /// position to the correct array parameter.
    ///
    /// - Returns: The next pack index.
    package func next() -> Int
    {
        defer
        {
            current += 1
        }
        
        return current
    }
}
