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
internal struct AnyShrinker
{
    /// Shrinks the given value.
    private let _shrink: (Any) -> [Any]
    
    
    
    /// Initializes an ``AnyShrinker`` instance from the given shrink function.
    /// - Parameter shrink: The function to shrink a given value.
    internal init<T>(
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
    internal func shrink(
        _ value: Any
    ) -> [Any]
    {
        return _shrink(value)
    }
    
    
    
    /// Creates a shrinker for the given type.
    /// - Parameter type: The type to use.
    /// - Returns: A shrinker for the given type.
    internal static func makeShrinker<T>(
        for type: T.Type
    ) -> AnyShrinker where T : Arbitrary
    {
        return AnyShrinker({ (value: T) in value.shrink() })
    }
    
    
    
    /// Creates a shrinker from the given generator.
    /// - Parameter generator: The generator to use.
    /// - Returns: A shrinker from the given generator.
    internal static func makeShrinker<T>(
        from generator: Generator<T>
    ) -> AnyShrinker
    {
        return AnyShrinker(generator.shrink)
    }
    
    
    
    /// Generates the shrink candidates of the given value.
    ///
    /// Each candidate is a copy of the given value's components with one
    /// element replaced by a shrunken alternative.
    ///
    /// - Parameters:
    ///   - value: The value to shrink. For multi-element packs, this is a
    ///   tuple. For single-element packs, this is the element itself.
    ///   - shrinkers: The shrinkers for each element.
    /// - Returns: The type-erased shrink candidates.
    internal static func shrinkCandidates(
        of      value       : Any,
        using   shrinkers   : [AnyShrinker]
    ) -> [[Any]]
    {
        var candidates  : [[Any]]   = []
        let mirror      : Mirror    = .init(reflecting: value)
        let values      : [Any]     = mirror.children.map { $0.value }
        
        
        
        /// Multi-element packs produces tuples. Single-element packs are
        /// flattened to the underlying element (`(T)` becomes `T`), so
        /// `Mirror` reflects the type's own structure rather than tuple
        /// members. For example, for a single-element parameter pack where
        /// `T = [Int]`, `(repeat each T)` collapses to `[Int]`, and the
        /// `Mirror` of this array reflects the elements as children.
        ///
        /// Check that the display style reflects a tuple, not an array or
        /// struct whose mirror children happen to match the count.
        ///
        /// Check that the counts match between `values` and `shrinkers`,
        /// to guard against a single-element pack whose value is itself a
        /// tuple (for example, `T = (Int, String)`).
        guard
            mirror.displayStyle == .tuple,
            values.count == shrinkers.count
        else
        {
            guard shrinkers.count == 1
            else
            {
                return []
            }
            
            for shrunken in shrinkers[0].shrink(value)
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
internal final class PackIndex
{
    /// The current pack index.
    private var current: Int = 0
    
    
    
    /// Initializes a ``PackIndex`` instance.
    internal init() { }
    
    
    
    /// Gets the next pack index.
    ///
    /// Each call to this method returns and increments ``current``. This
    /// allows `repeat array[index.next()] as! each T` to map each pack
    /// position to the correct array parameter.
    ///
    /// - Returns: The next pack index.
    internal func next() -> Int
    {
        defer
        {
            current += 1
        }
        
        return current
    }
}
