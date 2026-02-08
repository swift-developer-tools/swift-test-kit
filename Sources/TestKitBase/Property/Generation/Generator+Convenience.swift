//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Array

extension Generator
{
    /// Creates a generator that produces arrays with exactly the given count
    /// of elements.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements.
    ///
    /// - Precondition: `count` must be non-negative.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces arrays with exactly the given
    /// count of elements.
    public static func array<E>(
        of type : E.Type    = E.self,
        count   : Int
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            count >= 0,
            "count must be non-negative"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                return (0..<count).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkElements()
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given closed range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not contain negative values.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The closed range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given closed range.
    public static func array<E>(
        of type : E.Type            = E.self,
        count   : ClosedRange<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                let length: Int = context.random(in: count)
                
                return (0..<length).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkToward(minCount: count.lowerBound)
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given half-open range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not be empty or contain negative values.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The closed range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given half-open range.
    public static func array<E>(
        of type : E.Type        = E.self,
        count   : Range<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return array(
            of:     type,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    /// Creates a generator that produces non-empty arrays.
    ///
    /// The produced arrays have a count of elements within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter type: The element type. The default value is inferred.
    /// - Returns: A generator that produces non-empty arrays.
    public static func nonEmptyArray<E>(
        of type: E.Type = E.self
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        return Generator<[E]>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let length  : Int               = context.random(in: range)
                
                return (0..<length).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkToward(minCount: 1)
            }
        )
    }
}



// MARK: - Character

extension Generator where V == Character
{
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
            }
        )
    }
    
    
    
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
            }
        )
    }
    
    
    
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
            }
        )
    }
    
    
    
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
            }
        )
    }
    
    
    
    /// Creates a generator that produces alphanumeric characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces alphanumeric characters.
    public static func alphanumeric() -> Generator<Character>
    {
        let characters: String
            = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
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
            }
        )
    }
    
    
    
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
            }
        )
    }
}



// MARK: - String

extension Generator where V == String
{
    /// Creates a generator that produces strings with exactly the given count
    /// of characters.
    ///
    /// Since the count of characters is fixed, shrinking only applies to
    /// individual characters.
    ///
    /// - Precondition: `count` must be non-negative.
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
            "count must be non-negative"
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
            }
        )
    }
    
    
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given closed range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count` must not contain negative values.
    ///
    /// - Parameters:
    ///   - count: The exact count of characters.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given closed range.
    public static func string(
        count       : ClosedRange<Int>,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
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
            }
        )
    }
    
    
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given half-open range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count` must not be empty or contain negative values.
    ///
    /// - Parameters:
    ///   - count: The exact count of characters.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given half-open range.
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
            "count must not contain negative values"
        )
        
        return string(
            count:          count.lowerBound...(count.upperBound - 1),
            characters:     characters
        )
    }
    
    
    
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
            }
        )
    }
}



// MARK: - Integer

extension Generator where V : FixedWidthInteger
{
    /// Creates a generator that produces integers in the given closed range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The closed range in which to generate integers.
    /// - Returns: A generator that produces integers in the given closed range.
    public static func integer(
        in range: ClosedRange<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                return value.shrinkTowardZero(in: range)
            }
        )
    }
    
    
    
    /// Creates a generator that produces integers in the given half-open range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The half-open range in which to generate integers.
    /// - Returns: A generator that produces integers in the given half-open
    /// range.
    public static func integer(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return integer(in: range.lowerBound...(range.upperBound - 1))
    }
}



// MARK: - Floating

extension Generator
    where V : BinaryFloatingPoint,
          V.RawSignificand : FixedWidthInteger
{
    /// Creates a generator that produces floating-point numbers in the given
    /// closed range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The closed range in which to generate
    /// floating-point numbers.
    /// - Returns: A generator that produces floating-point numbers in the
    /// given closed range.
    public static func floatingPoint(
        in range: ClosedRange<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                return value.shrinkTowardZero(in: range)
            }
        )
    }
    
    
    
    /// Creates a generator that produces integers in the given half-open range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The half-open range in which to generate integers.
    /// - Returns: A generator that produces integers in the given half-open
    /// range.
    public static func floatingPoint(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                /// Shrink with a closed range and filter out the upper bound.
                let closed: ClosedRange<V>
                    = range.lowerBound...range.upperBound
                
                return value.shrinkTowardZero(in: closed)
                    .filter { range.contains($0) }
            }
        )
    }
}
