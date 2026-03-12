//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator where G == Character
{
    // MARK: - ASCII
    
    /// Creates a generator that produces printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces printable ASCII characters.
    public static func ascii() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiPrintableRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiPrintableRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    // MARK: - Lowercase
    
    /// Creates a generator that produces lowercase printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces lowercase printable ASCII
    /// characters.
    public static func lowercase() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiLowercaseRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiLowercaseRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    // MARK: - Uppercase
    
    /// Creates a generator that produces uppercase printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces uppercase printable ASCII
    /// characters.
    public static func uppercase() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiUppercaseRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiUppercaseRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    // MARK: - Digit
    
    /// Creates a generator that produces printable ASCII digit characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces printable ASCII digit characters.
    public static func digit() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiDigitRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiDigitRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    // MARK: - Alphanumeric
    
    /// Creates a generator that produces alphanumeric characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces alphanumeric characters.
    public static func alphanumeric() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let range: ClosedRange<Int> = context.randomElement(
                    of:             Unicode.Scalar.alphanumericRanges,
                    weightedBy:     { $0.count }
                )!
                
                let value = UInt32(context.random(in: range))
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                let scalar: Int
                    = character.unicodeScalars.first.map { Int($0.value) }
                    ?? Unicode.Scalar.asciiLowercaseRange.lowerBound
                
                let range: ClosedRange<Int> = Unicode.Scalar.alphanumericRanges
                    .first { $0.contains(scalar) }
                    ?? Unicode.Scalar.asciiLowercaseRange
                
                return mutateCharacter(
                    character,
                    in:     range,
                    using:  context
                )
            }
        )
    }
    
    
    
    // MARK: - From
    
    /// Creates a generator that selects characters from the given string.
    ///
    /// - Precondition: `characters` must not be empty.
    ///
    /// - Parameter characters: The characters from which to select.
    /// - Returns: A generator that selects characters from the given string.
    public static func from(
        _ characters: String
    ) -> Generator<Character>
    {
        precondition(
            !characters.isEmpty,
            "characters must not be empty"
        )
        
        return Generator<Character>(
            generate:
            {
                context in
                
                return context.randomElement(of: characters)!
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                _, context in
                
                return context.randomElement(of: characters)!
            }
        )
    }
    
    
    
    // MARK: - Support
    
    /// Mutates the given character.
    /// - Parameters:
    ///   - character: The character to mutate.
    ///   - range: The ASCII range in which the character exists.
    ///   - context: The generation context.
    /// - Returns: The mutated character.
    private static func mutateCharacter(
        _       character   : Character,
        in      range       : ClosedRange<Int>,
        using   context     : GenerationContext
    ) -> Character
    {
        let scalar: UInt32 = character.unicodeScalars.first.map { UInt32($0) }
            ?? UInt32(range.lowerBound)
        
        let delta: Int = context.random(in: -context.size...context.size)
        
        let mutated = UInt32(min(
            range.upperBound,
            max(range.lowerBound, Int(scalar) + delta)
        ))
        
        return Character(Unicode.Scalar(mutated)!)
    }
}
