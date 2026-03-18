//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class CharacterGeneratorTests: TestKitCase
{
    // MARK: - ASCII
    
    func testASCIIDeterminism()
    {
        Generator.ascii().assertDeterministic()
    }
    
    
    
    func testASCIIProduction()
    {
        validateCharacterRange(
            of:     .ascii(),
            range:  Unicode.Scalar.asciiPrintableRange
        )
    }
    
    
    
    func testASCIIGenerationVariety()
    {
        let min = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.85
        
        validateGenerationVariety(
            of:         .ascii(),
            minUnique:  Int(min)
        )
    }
    
    
    
    func testASCIIMutationVariety()
    {
        validateMutationVariety(of: .ascii())
    }
    
    
    
    func testASCIIMutationStaysInRange()
    {
        validateMutationRange(
            of:     .ascii(),
            range:  Unicode.Scalar.asciiPrintableRange
        )
    }
    
    
    
    // MARK: - Lowercase
    
    func testLowercaseDeterminism()
    {
        Generator.lowercase().assertDeterministic()
    }
    
    
    
    func testLowercaseProduction()
    {
        validateCharacterRange(
            of:     .lowercase(),
            range:  Unicode.Scalar.asciiLowercaseRange
        )
    }
    
    
    
    func testLowercaseGenerationVariety()
    {
        let min = Double(Unicode.Scalar.asciiLowercaseRange.count) * 0.85
        
        validateGenerationVariety(
            of:         .lowercase(),
            minUnique:  Int(min)
        )
    }
    
    
    
    func testLowercaseMutationVariety()
    {
        validateMutationVariety(of: .lowercase())
    }
    
    
    
    func testLowercaseMutationStaysInRange()
    {
        validateMutationRange(
            of:     .lowercase(),
            range:  Unicode.Scalar.asciiLowercaseRange
        )
    }
    
    
    
    // MARK: - Uppercase
    
    func testUppercaseDeterminism()
    {
        Generator.uppercase().assertDeterministic()
    }
    
    
    
    func testUppercaseProduction()
    {
        validateCharacterRange(
            of:     .uppercase(),
            range:  Unicode.Scalar.asciiUppercaseRange
        )
    }
    
    
    
    func testUppercaseGenerationVariety()
    {
        let min = Double(Unicode.Scalar.asciiUppercaseRange.count) * 0.85
        
        validateGenerationVariety(
            of:         .uppercase(),
            minUnique:  Int(min)
        )
    }
    
    
    
    func testUppercaseMutationVariety()
    {
        validateMutationVariety(of: .uppercase())
    }
    
    
    
    func testUppercaseMutationStaysInRange()
    {
        validateMutationRange(
            of:     .uppercase(),
            range:  Unicode.Scalar.asciiUppercaseRange
        )
    }
    
    
    
    // MARK: - Digit
    
    func testDigitDeterminism()
    {
        Generator.digit().assertDeterministic()
    }
    
    
    
    func testDigitProduction()
    {
        validateCharacterRange(
            of:     .digit(),
            range:  Unicode.Scalar.asciiDigitRange
        )
    }
    
    
    
    func testDigitGenerationVariety()
    {
        let min = Double(Unicode.Scalar.asciiDigitRange.count) * 0.85
        
        validateGenerationVariety(
            of:         .digit(),
            minUnique:  Int(min)
        )
    }
    
    
    
    func testDigitMutationVariety()
    {
        validateMutationVariety(of: .digit())
    }
    
    
    
    func testDigitsMutationStaysInRange()
    {
        validateMutationRange(
            of:     .digit(),
            range:  Unicode.Scalar.asciiDigitRange
        )
    }
    
    
    
    // MARK: - Alphanumeric
    
    func testAlphanumericDeterminism()
    {
        Generator.alphanumeric().assertDeterministic()
    }
    
    
    
    func testAlphanumericProduction()
    {
        let ranges: [ClosedRange<Int>] = Unicode.Scalar.alphanumericRanges
        
        for _ in 0..<1000
        {
            let character: Character
                = Generator.alphanumeric().generate(.random)
            
            let scalars: Character.UnicodeScalarView = character.unicodeScalars
            
            XCTAssertEqual(scalars.count, 1)
            
            let value = Int(scalars.first!.value)
            
            XCTAssertTrue(ranges.contains { $0.contains(value) })
        }
    }
    
    
    
    func testAlphanumericGenerationVariety()
    {
        let min = Double(Unicode.Scalar.asciiDigitRange.count) * 0.85
        
        validateGenerationVariety(
            of:         .alphanumeric(),
            minUnique:  Int(min)
        )
    }
    
    
    
    func testAlphanumericMutationVariety()
    {
        validateMutationVariety(of: .alphanumeric())
    }
    
    
    
    func testAlphanumericMutationStaysInRange()
    {
        let ranges: [ClosedRange<Int>] = Unicode.Scalar.alphanumericRanges
        
        for _ in 0..<1000
        {
            let context: GenerationContext = .random
            
            let original: Character = Generator.alphanumeric()
                .generate(context)
            
            let mutated: Character = Generator.alphanumeric()
                .mutate(original, context)
            
            let value = Int(mutated.unicodeScalars.first!.value)
            
            XCTAssertTrue(ranges.contains { $0.contains(value) })
        }
    }
    
    
    
    func testAlphanumericMutationStaysInSubrange()
    {
        let ranges: [ClosedRange<Int>] = Unicode.Scalar.alphanumericRanges
        
        for _ in 0..<1000
        {
            let context: GenerationContext = .random
            
            let original: Character = Generator.alphanumeric()
                .generate(context)
            
            let mutated: Character = Generator.alphanumeric()
                .mutate(original, context)
            
            let originalValue   = Int(original.unicodeScalars.first!.value)
            let mutatedValue    = Int(mutated.unicodeScalars.first!.value)
            
            let originalRange: ClosedRange<Int>
                = ranges.first { $0.contains(originalValue) }!
            
            XCTAssertTrue(originalRange.contains(mutatedValue))
        }
    }
    
    
    
    func testAlphanumericMutationWithNonAlphanumericCharacterFallback()
    {
        for _ in 0..<1000
        {
            let mutated: Character = Generator.alphanumeric()
                .mutate("!", .random)
            
            let value = Int(mutated.unicodeScalars.first!.value)
            
            XCTAssertTrue(Unicode.Scalar.asciiLowercaseRange.contains(value))
        }
    }
    
    
    
    // MARK: - From
    
    func testFromDeterminism()
    {
        Generator.from("abc").assertDeterministic()
    }
    
    
    
    func testFromProduction()
    {
        let characters: String = "abc"
        
        for _ in 0..<1000
        {
            let character: Character
                = Generator.from(characters).generate(.random)
            
            XCTAssertTrue(characters.contains(character))
        }
    }
    
    
    
    func testFromProducesVariety()
    {
        let characters  : String            = "abc"
        var unique      : Set<Character>    = []
        
        for _ in 0..<1000
        {
            unique.insert(Generator.from(characters).generate(.random))
        }
        
        XCTAssertEqual(unique, Set(characters))
    }
    
    
    
    func testFromSingleCharacterAlwaysProducesSameCharacter()
    {
        for _ in 0..<1000
        {
            let character: Character = Generator.from("z").generate(.random)
            
            XCTAssertEqual(character, "z")
        }
    }
    
    
    
    func testFromMutationStaysWithinRange()
    {
        let characters: String = "abcdef"
        
        for _ in 0..<1000
        {
            let context: GenerationContext = .random
            
            let original: Character = Generator.from(characters)
                .generate(context)
            
            let mutated: Character = Generator.from(characters)
                .mutate(original, context)
            
            XCTAssertTrue(characters.contains(mutated))
        }
    }
    
    
    
    func testFromSingleCharacterMutationAlwaysReturnsSameCharacter()
    {
        for _ in 0..<1000
        {
            let mutated: Character = Generator.from("x")
                .mutate("x", .random)
            
            XCTAssertEqual(mutated, "x")
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testAllCharacterGeneratorsShrinkTowardA()
    {
        let generators: [Generator<Character>] =
        [
            .ascii(),
            .lowercase(),
            .uppercase(),
            .digit(),
            .alphanumeric(),
            .from("xyz")
        ]
        
        for generator in generators
        {
            let candidates: [Character] = generator.shrink("z")
            
            XCTAssertFalse(candidates.isEmpty)
            XCTAssertEqual(candidates.first, "a")
        }
    }
    
    
    
    func testAllCharacterGeneratorsTargetDoesNotShrink()
    {
        let generators: [Generator<Character>] =
        [
            .ascii(),
            .lowercase(),
            .uppercase(),
            .digit(),
            .alphanumeric(),
            .from("xyz")
        ]
        
        for generator in generators
        {
            XCTAssertTrue(generator.shrink("a").isEmpty)
        }
    }
    
    
    
    // MARK: - Mutation
    
    func testMutationAtSizeZeroReturnsSameCharacter()
    {
        let generators: [Generator<Character>] =
        [
            .ascii(),
            .lowercase(),
            .uppercase(),
            .digit(),
            .alphanumeric()
        ]
        
        for generator in generators
        {
            for _ in 0..<1000
            {
                let original: Character = generator
                    .generate(.randomZeroSize)
                
                let mutated: Character = generator
                    .mutate(original, .randomZeroSize)
                
                XCTAssertEqual(original, mutated)
            }
        }
    }
}



// MARK: - Support

extension CharacterGeneratorTests
{
    /// Validates that the given generator only produces characters with
    /// scalar values within the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluatea.
    ///   - range: The expected range of scalar values.
    private func validateCharacterRange(
        of generator    : Generator<Character>,
        range           : ClosedRange<Int>
    )
    {
        for _ in 0..<1000
        {
            let character: Character = generator.generate(.random)
            
            let scalars: Character.UnicodeScalarView = character.unicodeScalars
            
            XCTAssertEqual(scalars.count, 1)
            
            let value: UInt32 = scalars.first!.value
            
            XCTAssertGreaterThanOrEqual(value, UInt32(range.lowerBound))
            XCTAssertLessThanOrEqual(value, UInt32(range.upperBound))
        }
    }
    
    
    
    /// Validates that the given generator produces at least the given number
    /// of unique characters.
    /// - Parameters:
    ///   - generator: The generator to evaluate.
    ///   - minUnique: The expected minimum number of unique characters.
    private func validateGenerationVariety(
        of generator    : Generator<Character>,
        minUnique       : Int
    )
    {
        var unique: Set<Character> = []
        
        for _ in 0..<10_000
        {
            unique.insert(generator.generate(.random))
        }
        
        XCTAssertGreaterThanOrEqual(unique.count, minUnique)
    }
    
    
    
    /// Validates that mutation of the given generator produces more than one
    /// distinct character.
    /// - Parameter generator: The generator to evaluate.
    private func validateMutationVariety(
        of generator: Generator<Character>
    )
    {
        let base: Character = generator
            .generate(.random)
        
        var unique: Set<Character> = []
        
        for _ in 0..<1000
        {
            unique.insert(generator.mutate(base, .random))
        }
        
        XCTAssertGreaterThan(unique.count, 1)
    }
    
    
    
    /// Validates that mutation of the given generator only produces characters
    /// with scalar values within the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluate.
    ///   - minUnique: The expected range of scalar values.
    private func validateMutationRange(
        of generator    : Generator<Character>,
        range           : ClosedRange<Int>
    )
    {
        for _ in 0..<1000
        {
            let context: GenerationContext = .random
            
            let original    : Character = generator.generate(context)
            let mutated     : Character = generator.mutate(original, context)
            
            let scalars: Character.UnicodeScalarView = mutated.unicodeScalars
            
            XCTAssertEqual(scalars.count, 1)
            
            let value: UInt32 = scalars.first!.value
            
            XCTAssertGreaterThanOrEqual(value, UInt32(range.lowerBound))
            XCTAssertLessThanOrEqual(value, UInt32(range.upperBound))
        }
    }
}
