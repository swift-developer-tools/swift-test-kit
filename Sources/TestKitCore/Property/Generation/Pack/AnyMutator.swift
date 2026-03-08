//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A type-erased mutator for indexed mutation of parameter pack elements.
internal struct AnyMutator
{
    /// Mutates the given value.
    private let _mutate: (Any, GenerationContext) -> Any
    
    
    
    /// Initializes an ``mutator`` instance from the given mutate function.
    /// - Parameter mutate: The function to mutate a given value.
    internal init<T>(
        _ mutate: @escaping (T, GenerationContext) -> T
    )
    {
        self._mutate =
        {
            value, context in
            
            return mutate(value as! T, context) as Any
        }
    }
    
    
    
    /// Mutates the given value.
    /// - Parameters:
    ///   - value: The value to mutate.
    ///   - context: The generation context.
    /// - Returns: The mutated value.
    internal func mutate(
        _       value   : Any,
        using   context : GenerationContext
    ) -> Any
    {
        return _mutate(value, context)
    }
    
    
    
    /// Creates a mutator for the given type.
    /// - Parameter type: The type to use.
    /// - Returns: A mutator for the given type.
    internal static func makeMutator<T>(
        for type: T.Type
    ) -> AnyMutator where T : Arbitrary
    {
        let mutate: (T, GenerationContext) -> T =
        {
            value, context in
            
            return value.mutate(using: context)
        }
        
        return AnyMutator(mutate)
    }
    
    
    
    /// Creates a mutator from the given generator.
    /// - Parameter generator: The generator to use.
    /// - Returns: A mutator from the given generator.
    internal static func makeMutator<T>(
        from generator: Generator<T>
    ) -> AnyMutator
    {
        return AnyMutator(generator.mutate)
    }
    
    
    
    /// Mutates a single element of the given value.
    /// - Parameters:
    ///   - value: The value to mutate. For multi-element packs, this is a
    ///   tuple. For single-element packs, this is the element itself.
    ///   - mutators: The mutators for each element.
    ///   - context: The generation context.
    /// - Returns: The type-erased components with one element mutated.
    internal static func mutateSingleElement(
        of      value       : Any,
        with    mutators    : [AnyMutator],
        using   context     : GenerationContext
    ) -> [Any]
    {
        let mirror  : Mirror    = .init(reflecting: value)
        let values  : [Any]     = mirror.children.map { $0.value }
        
        /// See comment in ``AnyShrinker/shrinkCandidates(of:with:)``.
        guard
            mirror.displayStyle == .tuple,
            values.count == mutators.count
        else
        {
            guard mutators.count == 1
            else
            {
                return [value]
            }
            
            let mutated: Any = mutators[0].mutate(
                value,
                using: context
            )
            
            return [mutated]
        }
        
        
        
        let index: Int = context.random(in: 0..<mutators.count)
        
        var copy: [Any] = values
        
        copy[index] = mutators[index].mutate(
            values[index],
            using: context
        )
        
        return copy
    }
}
