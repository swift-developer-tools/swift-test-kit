//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator where G == String
{
    // MARK: - Exact
    
    /// Creates a generator that produces strings with exactly the given count
    /// of characters.
    ///
    /// Since the count of characters is fixed, shrinking only applies to
    /// individual characters.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameters:
    ///   - count: The exact count of characters.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with exactly the given
    /// count of characters.
    public static func string(
        count       : Int,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<String>(
            generate:
            {
                context in
                
                let chars: [Character] = (0..<count).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkCharacters()
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       count,
                    maxCount:       count,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    // MARK: - Range
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - count: The range of character counts.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given range.
    public static func string(
        count       : ClosedRange<Int>,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return Generator<String>(
            generate:
            {
                context in
                
                let length: Int = context.random(in: count)
                
                let chars: [Character] = (0..<length).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkToward(minCount: count.lowerBound)
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       count.lowerBound,
                    maxCount:       count.upperBound,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - count: The range of character counts.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given range.
    public static func string(
        count       : Range<Int>,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return string(
            count:          count.lowerBound...(count.upperBound - 1),
            characters:     characters
        )
    }
    
    
    
    // MARK: - Non-empty
    
    /// Creates a generator that produces non-empty strings.
    ///
    /// The produced strings have a count of characters within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter characters: The character generator to use. The default
    /// value is ``Generator/ascii()``.
    /// - Returns: A generator that produces non-empty strings.
    public static func nonEmptyString(
        characters: Generator<Character> = .ascii()
    ) -> Generator<String>
    {
        return Generator<String>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let length  : Int               = context.random(in: range)
                
                let chars: [Character] = (0..<length).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkToward(minCount: 1)
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       1,
                    maxCount:       nil,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    // MARK: - Support
    
    /// Mutates the given string.
    /// - Parameters:
    ///   - string: The string to mutate.
    ///   - minCount: The minimum character count.
    ///   - maxCount: The maximum character count.
    ///   - characters: The character generator.
    ///   - context: The generation context.
    /// - Returns: The mutated string.
    private static func mutateString(
        _ string        : String,
        minCount        : Int,
        maxCount        : Int?,
        characters      : Generator<Character>,
        using context   : GenerationContext
    ) -> String
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { string.count < $0 } ?? true
        
        guard !string.isEmpty
        else
        {
            guard canInsert
            else
            {
                return string
            }
            
            return String(characters.generate(context))
        }
        
        let canRemove       : Bool  = string.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var charArray: [Character] = Array(string)
        
        if chance <= mutateWeight
        {
            let index: Int = context.random(in: 0..<charArray.count)
            
            charArray[index] = characters.mutate(charArray[index], context)
        }
        else if chance <= mutateWeight + insertWeight
        {
            let index: Int = context.random(in: 0...charArray.count)
            
            charArray.insert(
                characters.generate(context),
                at: index
            )
        }
        else
        {
            let index: Int = context.random(in: 0..<charArray.count)
            
            charArray.remove(at: index)
        }
        
        return String(charArray)
    }
}
