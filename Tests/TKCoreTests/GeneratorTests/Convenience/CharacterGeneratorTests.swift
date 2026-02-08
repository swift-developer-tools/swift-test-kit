//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitBase



internal final class CharacterGeneratorTests: XCTestCase
{
    // MARK: - ASCII
    
    func testASCIIDeterminism() throws
    {
        Generator.ascii().validateDeterminism()
    }
    
    
    
    func testASCIIProduction() throws
    {
        validateCharacterRange(
            of:     .ascii(),
            range:  Unicode.Scalar.asciiPrintableRange
        )
    }
    
    
    
    func testASCIIProducesVariety() throws
    {
        let min = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.95
        
        validateVariety(
            of:         .ascii(),
            minUnique:  Int(min)
        )
    }
    
    
    
    // MARK: - Lowercase
    
    func testLowercaseDeterminism() throws
    {
        Generator.lowercase().validateDeterminism()
    }
    
    
    
    func testLowercaseProduction() throws
    {
        validateCharacterRange(
            of:     .lowercase(),
            range:  Unicode.Scalar.asciiLowercaseRange
        )
    }
    
    
    
    func testLowercaseProducesVariety() throws
    {
        let min = Double(Unicode.Scalar.asciiLowercaseRange.count) * 0.95
        
        validateVariety(
            of:         .lowercase(),
            minUnique:  Int(min)
        )
    }
    
    
    
    // MARK: - Uppercase
    
    func testUppercaseDeterminism() throws
    {
        Generator.uppercase().validateDeterminism()
    }
    
    
    
    func testUppercaseProduction() throws
    {
        validateCharacterRange(
            of:     .uppercase(),
            range:  Unicode.Scalar.asciiUppercaseRange
        )
    }
    
    
    
    func testUppercaseProducesVariety() throws
    {
        let min = Double(Unicode.Scalar.asciiUppercaseRange.count) * 0.95
        
        validateVariety(
            of:         .uppercase(),
            minUnique:  Int(min)
        )
    }
    
    
    
    // MARK: - Digit
    
    func testDigitDeterminism() throws
    {
        Generator.digit().validateDeterminism()
    }
    
    
    
    func testDigitProduction() throws
    {
        validateCharacterRange(
            of:     .digit(),
            range:  Unicode.Scalar.asciiDigitRange
        )
    }
    
    
    
    func testDigitProducesVariety() throws
    {
        let min = Double(Unicode.Scalar.asciiDigitRange.count) * 0.95
        
        validateVariety(
            of:         .digit(),
            minUnique:  Int(min)
        )
    }
    
    
    
    // MARK: - Alphanumeric
    
    func testAlphanumericDeterminism() throws
    {
        Generator.alphanumeric().validateDeterminism()
    }
    
    
    
    func testAlphanumericProduction() throws
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
    
    
    
    func testAlphanumericProducesVariety() throws
    {
        let min = Double(Unicode.Scalar.asciiDigitRange.count) * 0.95
        
        validateVariety(
            of:         .alphanumeric(),
            minUnique:  Int(min)
        )
    }
    
    
    
    // MARK: - From
    
    func testFromDeterminism() throws
    {
        Generator.from("abc").validateDeterminism()
    }
    
    
    
    func testFromProduction() throws
    {
        let characters: String = "abc"
        
        for _ in 0..<1000
        {
            let character: Character
                = Generator.from(characters).generate(.random)
            
            XCTAssertTrue(characters.contains(character))
        }
    }
    
    
    
    func testFromProducesVariety() throws
    {
        let characters  : String            = "abc"
        var unique      : Set<Character>    = []
        
        for _ in 0..<1000
        {
            unique.insert(Generator.from(characters).generate(.random))
        }
        
        XCTAssertEqual(unique, Set(characters))
    }
    
    
    
    func testFromSingleCharacterAlwaysProducesSameCharacter() throws
    {
        for _ in 0..<1000
        {
            let character: Character = Generator.from("z").generate(.random)
            
            XCTAssertEqual(character, "z")
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testAllCharacterGeneratorsShrinkTowardA() throws
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
    
    
    
    func testAllCharacterGeneratorsTargetDoesNotShrink() throws
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
}



// MARK: - Extensions

private extension CharacterGeneratorTests
{
    /// Validates that the given generator only produces characters with
    /// scalar values within the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluatea.
    ///   - range: The expected range of scalar values.
    func validateCharacterRange(
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
    func validateVariety(
        of generator    : Generator<Character>,
        minUnique       : Int
    )
    {
        var unique: Set<Character> = []
        
        for _ in 0..<1000
        {
            unique.insert(generator.generate(.random))
        }
        
        XCTAssertGreaterThanOrEqual(unique.count, minUnique)
    }
}
