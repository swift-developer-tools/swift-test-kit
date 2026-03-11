//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator
{
    // MARK: - Generator exact
    
    /// Creates a generator that produces dictionaries with exactly the given
    /// count of entries.
    ///
    /// Since the count of entries is fixed, shrinking only applies to
    /// individual keys and values.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `keyGenerator` must produce at least `count` distinct
    /// keys within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    ///   - count: The exact count of entries.
    /// - Returns: A generator that produces dictionaries with exactly the
    /// given count of entries.
    public static func dictionary<K, V>(
        keys    keyGenerator    : Generator<K>,
        values  valueGenerator  : Generator<V>,
        count                   : Int
    ) -> Generator<[K : V]> where G == [K : V], K : Hashable
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<[K : V]>(
            generate:
            {
                context in
                
                let uniqueKeys: [K] = generateUniqueElements(
                    count:      count,
                    generator:  keyGenerator,
                    context:    context
                )
                
                let entries: [(K, V)] = uniqueKeys.map
                {
                    key in
                    
                    return (key, valueGenerator.generate(context))
                }
                
                return Dictionary(uniqueKeysWithValues: entries)
            },
            shrink:
            {
                dictionary in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let shrinkElements: () -> [[(K, V)]] =
                {
                    return shrinkDictionary(
                        entries,
                        keys:       keyGenerator,
                        values:     valueGenerator
                    )
                }
                
                return entries.shrinkToward(
                    minCount:           count,
                    shrinkElements:     shrinkElements
                ).map { Dictionary(uniqueKeysWithValues: $0) }
            },
            mutate:
            {
                dictionary, context in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let mutated: [(K, V)] = mutateDictionary(
                    entries,
                    minCount:   count,
                    maxCount:   count,
                    keys:       keyGenerator,
                    values:     valueGenerator,
                    using:      context
                )
                
                return Dictionary(uniqueKeysWithValues: mutated)
            }
        )
    }
    
    
    
    // MARK: - Generator range
    
    /// Creates a generator that produces dictionaries with a count of entries
    /// within the given range.
    ///
    /// Shrinking reduces the count of entries toward the lower bound and
    /// shrinks individual keys and values.
    ///
    /// - Precondition: `range.lowerBound` must not be negative.
    /// - Precondition: `keyGenerator` must produce at least `range.upperBound`
    /// distinct keys within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    ///   - range: The range of entry counts.
    /// - Returns: A generator that produces dictionaries with a count of
    /// entries within the given range.
    public static func dictionary<K, V>(
        keys    keyGenerator    : Generator<K>,
        values  valueGenerator  : Generator<V>,
        count   range           : ClosedRange<Int>
    ) -> Generator<[K : V]> where G == [K : V], K : Hashable
    {
        precondition(
            range.lowerBound >= 0,
            "range.lowerBound must not be negative"
        )
        
        return Generator<[K : V]>(
            generate:
            {
                context in
                
                let uniqueKeys: [K] = generateUniqueElements(
                    count:      context.random(in: range),
                    generator:  keyGenerator,
                    context:    context
                )
                
                let entries: [(K, V)] = uniqueKeys.map
                {
                    key in
                    
                    return (key, valueGenerator.generate(context))
                }
                
                return Dictionary(uniqueKeysWithValues: entries)
            },
            shrink:
            {
                dictionary in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let shrinkElements: () -> [[(K, V)]] =
                {
                    return shrinkDictionary(
                        entries,
                        keys:       keyGenerator,
                        values:     valueGenerator
                    )
                }
                
                return entries.shrinkToward(
                    minCount:           range.lowerBound,
                    shrinkElements:     shrinkElements
                ).map { Dictionary(uniqueKeysWithValues: $0) }
            },
            mutate:
            {
                dictionary, context in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let mutated: [(K, V)] = mutateDictionary(
                    entries,
                    minCount:   range.lowerBound,
                    maxCount:   range.upperBound,
                    keys:       keyGenerator,
                    values:     valueGenerator,
                    using:      context
                )
                
                return Dictionary(uniqueKeysWithValues: mutated)
            }
        )
    }
    
    
    
    /// Creates a generator that produces dictionaries with a count of entries
    /// within the given range.
    ///
    /// Shrinking reduces the count of entries toward the lower bound and
    /// shrinks individual keys and values.
    ///
    /// - Precondition: `range` must not be empty.
    /// - Precondition: `range.lowerBound` must not be negative.
    /// - Precondition: `keyGenerator` must produce at least
    /// `range.upperBound - 1` distinct keys within a reasonable number of
    /// attempts.
    ///
    /// - Parameters:
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    ///   - range: The range of entry counts.
    /// - Returns: A generator that produces dictionaries with a count of
    /// entries within the given range.
    public static func dictionary<K, V>(
        keys    keyGenerator    : Generator<K>,
        values  valueGenerator  : Generator<V>,
        count   range           : Range<Int>
    ) -> Generator<[K : V]> where G == [K : V], K : Hashable
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        precondition(
            range.lowerBound >= 0,
            "range.lowerBound must not be negative"
        )
        
        return dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      range.lowerBound...(range.upperBound - 1)
        )
    }
    
    
    
    // MARK: - Arbitrary exact
    
    /// Creates a generator that produces dictionaries with exactly the given
    /// count of entries.
    ///
    /// Since the count of entries is fixed, shrinking only applies to
    /// individual keys and values.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `keyType` must produce at least `count` distinct
    /// keys within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - keyType: The key type. The default value is inferred.
    ///   - valueType: The value type. The default value is inferred.
    ///   - count: The exact count of entries.
    /// - Returns: A generator that produces dictionaries with exactly the
    /// given count of entries.
    public static func dictionary<K, V>(
        key     keyType     : K.Type    = K.self,
        value   valueType   : V.Type    = V.self,
        count               : Int
    ) -> Generator<[K : V]>
        where G == [K : V], K : Arbitrary & Hashable, V : Arbitrary
    {
        return .dictionary(
            keys:       .arbitrary(),
            values:     .arbitrary(),
            count:      count
        )
    }
    
    
    
    // MARK: - Arbitrary range
    
    /// Creates a generator that produces dictionaries with a count of entries
    /// within the given range.
    ///
    /// Shrinking reduces the count of entries toward the lower bound and
    /// shrinks individual keys and values.
    ///
    /// - Precondition: `range.lowerBound` must not be negative.
    /// - Precondition: `keyType` must produce at least `range.upperBound`
    /// distinct keys within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - keyType: The key type. The default value is inferred.
    ///   - valueType: The value type. The default value is inferred.
    ///   - range: The range of entry counts.
    /// - Returns: A generator that produces dictionaries with a count of
    /// entries within the given range.
    public static func dictionary<K, V>(
        key     keyType     : K.Type            = K.self,
        value   valueType   : V.Type            = V.self,
        count   range       : ClosedRange<Int>
    ) -> Generator<[K : V]>
        where G == [K : V], K : Arbitrary & Hashable, V : Arbitrary
    {
        return .dictionary(
            keys:       .arbitrary(),
            values:     .arbitrary(),
            count:      range
        )
    }
    
    
    
    /// Creates a generator that produces dictionaries with a count of entries
    /// within the given range.
    ///
    /// Shrinking reduces the count of entries toward the lower bound and
    /// shrinks individual keys and values.
    ///
    /// - Precondition: `range` must not be empty.
    /// - Precondition: `range.lowerBound` must not be negative.
    /// - Precondition: `keyType` must produce at least `range.upperBound - 1`
    /// distinct keys within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - keyType: The key type. The default value is inferred.
    ///   - valueType: The value type. The default value is inferred.
    ///   - range: The range of entry counts.
    /// - Returns: A generator that produces dictionaries with a count of
    /// entries within the given range.
    public static func dictionary<K, V>(
        key     keyType     : K.Type        = K.self,
        value   valueType   : V.Type        = V.self,
        count   range       : Range<Int>
    ) -> Generator<[K : V]>
        where G == [K : V], K : Arbitrary & Hashable, V : Arbitrary
    {
        return .dictionary(
            keys:       .arbitrary(),
            values:     .arbitrary(),
            count:      range
        )
    }
    
    
    
    // MARK: - Non-empty
    
    /// Creates a generator that produces non-empty dictionaries.
    ///
    /// The produced dictionaries have a count of entries within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameters:
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    /// - Returns: A generator that produces non-empty dictionaries.
    public static func nonEmptyDictionary<K, V>(
        keys    keyGenerator    : Generator<K>,
        values  valueGenerator  : Generator<V>
    ) -> Generator<[K : V]> where G == [K : V], K : Hashable
    {
        return Generator<[K : V]>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let count   : Int               = context.random(in: range)
                
                let uniqueKeys: [K] = generateUniqueElements(
                    count:      count,
                    generator:  keyGenerator,
                    context:    context
                )
                
                let entries: [(K, V)] = uniqueKeys.map
                {
                    key in
                    
                    return (key, valueGenerator.generate(context))
                }
                
                return Dictionary(uniqueKeysWithValues: entries)
            },
            shrink:
            {
                dictionary in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let shrinkElements: () -> [[(K, V)]] =
                {
                    return shrinkDictionary(
                        entries,
                        keys:       keyGenerator,
                        values:     valueGenerator
                    )
                }
                
                return entries.shrinkToward(
                    minCount:           1,
                    shrinkElements:     shrinkElements
                ).map { Dictionary(uniqueKeysWithValues: $0) }
            },
            mutate:
            {
                dictionary, context in
                
                let entries: [(K, V)] = Array(dictionary)
                
                let mutated: [(K, V)] = mutateDictionary(
                    entries,
                    minCount:   1,
                    maxCount:   nil,
                    keys:       keyGenerator,
                    values:     valueGenerator,
                    using:      context
                )
                
                return Dictionary(uniqueKeysWithValues: mutated)
            }
        )
    }
    
    
    
    /// Creates a generator that produces non-empty dictionaries.
    ///
    /// The produced dictionaries have a count of entries within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameters:
    ///   - keyType: The key type. The default value is inferred.
    ///   - valueType: The value type. The default value is inferred.
    /// - Returns: A generator that produces non-empty dictionaries.
    public static func nonEmptyDictionary<K, V>(
        key     keyType     : K.Type    = K.self,
        value   valueType   : V.Type    = V.self
    ) -> Generator<[K : V]>
        where G == [K : V], K : Arbitrary & Hashable, V : Arbitrary
    {
        return .nonEmptyDictionary(
            keys:       .arbitrary(),
            values:     .arbitrary()
        )
    }
    
    
    
    // MARK: - Support
    
    /// Shrinks individual entries of the given dictionary entries,
    /// independently shrinking each key and value.
    /// - Parameters:
    ///   - entries: The entries to shrink.
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    /// - Returns: The shrink candidates.
    internal static func shrinkDictionary<K, V>(
        _       entries         : [(K, V)],
        keys    keyGenerator    : Generator<K>,
        values  valueGenerator  : Generator<V>
    ) -> [[(K, V)]] where K: Hashable
    {
        let existingKeys    : Set<K>        = Set(entries.map { $0.0 })
        var candidates      : [[(K, V)]]    = []
        
        for index in entries.indices
        {
            let (key, value)    : (K, V)    = entries[index]
            var otherKeys       : Set<K>    = existingKeys
            
            otherKeys.remove(key)
            
            for shrunkenKey in keyGenerator.shrink(key)
            {
                guard !otherKeys.contains(shrunkenKey)
                else
                {
                    continue
                }
                
                var copy: [(K, V)] = entries
                
                copy[index] = (shrunkenKey, value)
                
                candidates.append(copy)
            }
            
            for shrunkenValue in valueGenerator.shrink(value)
            {
                var copy: [(K, V)] = entries
                
                copy[index] = (key, shrunkenValue)
                
                candidates.append(copy)
            }
        }
        
        return candidates
    }
    
    
    
    /// Mutates the given dictionary entries.
    /// - Parameters:
    ///   - entries: The entries to mutate.
    ///   - minCount: The minimum count of entries.
    ///   - maxCount: The maximum count of entries.
    ///   - keyGenerator: The key generator.
    ///   - valueGenerator: The value generator.
    ///   - context: The generation context.
    /// - Returns: The mutated entries.
    internal static func mutateDictionary<K, V>(
        _           entries         : [(K, V)],
        minCount                    : Int,
        maxCount                    : Int?,
        keys        keyGenerator    : Generator<K>,
        values      valueGenerator  : Generator<V>,
        using       context         : GenerationContext
    ) -> [(K, V)] where K: Hashable
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { entries.count < $0 } ?? true
        
        guard !entries.isEmpty
        else
        {
            guard canInsert
            else
            {
                return entries
            }
            
            return [(
                keyGenerator.generate(context),
                valueGenerator.generate(context)
            )]
        }
        
        let canRemove       : Bool  = entries.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var copy: [(K, V)] = entries
        
        if chance <= mutateWeight
        {
            /// Mutate the value only. Key mutation is collision-prone.
            let index           : Int       = context.random(in: 0..<copy.count)
            let (key, value)    : (K, V)    = copy[index]
            
            copy[index] = (key, valueGenerator.mutate(value, context))
        }
        else if chance <= mutateWeight + insertWeight
        {
            let existingKeys: Set<K> = Set(entries.map { $0.0 })
            
            for _ in 0..<1000
            {
                let newKey: K = keyGenerator.generate(context)
                
                if !existingKeys.contains(newKey)
                {
                    copy.append((
                        newKey,
                        valueGenerator.generate(context)
                    ))
                    
                    return copy
                }
            }
        }
        else
        {
            let index: Int = context.random(in: 0..<copy.count)
            
            copy.remove(at: index)
        }
        
        return copy
    }
}
