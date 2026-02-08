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



internal final class StringArbitraryTests: XCTestCase
{
    // MARK: - Character generation
    
    func testCharGenerationDeterminism() throws
    {
        validateDeterminism(of: Character.self)
    }
    
    
    
    func testCharacterGenerationSizeZeroProducesASCII() throws
    {
        for _ in 0..<1000
        {
            let character = Character.arbitrary(using: .randomZeroSize)
            
            let lower   = UInt32(Unicode.Scalar.asciiPrintableRange.lowerBound)
            let upper   = UInt32(Unicode.Scalar.asciiPrintableRange.upperBound)
            
            let scalars: Character.UnicodeScalarView = character.unicodeScalars
            
            XCTAssertEqual(scalars.count, 1)
            XCTAssertGreaterThanOrEqual(scalars.first!.value, lower)
            XCTAssertLessThanOrEqual(scalars.first!.value, upper)
        }
    }
    
    
    
    func testCharacterGenerationProducesVariety() throws
    {
        var unique: Set<Character> = []
        
        for _ in 0..<1000
        {
            let character = Character.arbitrary(using: .random)
            
            unique.insert(character)
        }
        
        let expected = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.95
        
        XCTAssertGreaterThan(unique.count, Int(expected))
    }
    
    
    
    // MARK: - Scalar generation
    
    func testScalarGenerationDeterminism() throws
    {
        validateDeterminism(of: Unicode.Scalar.self)
    }
    
    
    
    func testScalarGenerationSizeZeroProducesASCII() throws
    {
        for _ in 0..<1000
        {
            let scalar  = Unicode.Scalar.arbitrary(using: .randomZeroSize)
            let lower   = UInt32(Unicode.Scalar.asciiPrintableRange.lowerBound)
            let upper   = UInt32(Unicode.Scalar.asciiPrintableRange.upperBound)
            
            XCTAssertGreaterThanOrEqual(scalar.value, lower)
            XCTAssertLessThanOrEqual(scalar.value, upper)
        }
    }
    
    
    
    func testScalarGenerationValuesInExpectedRange() throws
    {
        for _ in 0..<1000
        {
            let scalar = Unicode.Scalar.arbitrary(using: .random)
            
            XCTAssertTrue(isInExpectedRange(scalar))
        }
    }
    
    
    
    func testScalarGenerationProducesUnicode() throws
    {
        var hasUnicode: Bool = false
        
        for _ in 0..<1000
        {
            let scalar = Unicode.Scalar.arbitrary(using: .random)
            
            if scalar.value > Unicode.Scalar.asciiPrintableRange.upperBound
            {
                hasUnicode = true
                break
            }
        }
        
        XCTAssertTrue(hasUnicode)
    }
    
    
    
    func testScalarGenerationProducesVariety() throws
    {
        var unique: Set<UInt32> = []
        
        for _ in 0..<1000
        {
            let scalar = Unicode.Scalar.arbitrary(using: .random)
            
            unique.insert(scalar.value)
        }
        
        let expected = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.95
        
        XCTAssertGreaterThan(unique.count, Int(expected))
    }
    
    
    
    // MARK: - String generation
    
    func testStringGenerationDeterminism() throws
    {
        validateDeterminism(of: String.self)
    }
    
    
    
    func testStringGenerationSizeZeroProducesEmpty() throws
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(String.arbitrary(using: .randomZeroSize), "")
        }
    }
    
    
    
    func testStringGenerationLengthRespectsSizeBounds() throws
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let string = String.arbitrary(using: context)
            
            XCTAssertLessThanOrEqual(string.count, size)
        }
    }
    
    
    
    func testStringGenerationProducesEmptyAndNonEmpty() throws
    {
        var hasEmpty    : Bool  = false
        var hasNonEmpty : Bool  = false
        
        for _ in 0..<1000
        {
            let string = String.arbitrary(using: .random)
            
            if string.isEmpty
            {
                hasEmpty = true
            }
            else
            {
                hasNonEmpty = true
            }
            
            if
                hasEmpty,
                hasNonEmpty
            {
                break
            }
        }
        
        XCTAssertTrue(hasEmpty)
        XCTAssertTrue(hasNonEmpty)
    }
    
    
    
    func testStringGenerationProducesVariousCounts() throws
    {
        let size    : Int       = 20
        var counts  : Set<Int>  = []
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let string = String.arbitrary(using: context)
            
            counts.insert(string.count)
        }
        
        XCTAssertGreaterThan(counts.count, size / 2)
    }
    
    
    
    // MARK: - Substring generation
    
    func testSubstringGenerationDeterminism() throws
    {
        validateDeterminism(of: Substring.self)
    }
    
    
    
    func testSubstringGenerationSizeZeroProducesEmpty() throws
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(Substring.arbitrary(using: .randomZeroSize), "")
        }
    }
    
    
    
    func testSubstringGenerationMatchesStringContent() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let string      = String.arbitrary(using: context1)
            let substring   = Substring.arbitrary(using: context2)
            
            XCTAssertEqual(String(substring), string)
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testCharacterShrinking() throws
    {
        let characters: [Character] =
        [
            /// Target.
            .init("a"),
            
            /// Single-scalars: ASCII.
            .init("z"),
            .init("A"),
            .init("Z"),
            .init("0"),
            .init("~"),
            .init(" "),
            
            /// Single-scalars: emoji.
            .init("\u{1F600}"),
            
            /// Multi-scalar: combining accent (é = e + combining acute).
            .init("\u{0065}\u{0301}"),
            
            /// Multi-scalar: base is target (à = a + combining grave).
            .init("\u{0061}\u{0300}"),
            
            /// Multi-scalars: emoji.
            .init("\u{1F636}\u{200D}\u{1F32B}\u{FE0F}"),
            .init("\u{1F642}\u{200D}\u{2194}\u{FE0F}")
        ]
        
        for character in characters
        {
            validateShrinkCandidates(of: character)
        }
    }
    
    
    
    func testScalarShrinking() throws
    {
        let scalars: [Unicode.Scalar] =
        [
            .init("a"),         /// Target.
            .init("z"),         /// Above target.
            .init("A"),         /// Below target.
            .init("b"),         /// Adjacent above.
            .init("`"),         /// Adjacent below.
            .init(" "),         /// Far below target.
            .init(0x03B1)!,     /// Unicode.
            .init(0x1F600)!     /// Emoji.
        ]
        
        for scalar in scalars
        {
            validateShrinkCandidates(of: scalar)
        }
    }
    
    
    
    func testStringShrinking() throws
    {
        let strings: [String] =
        [
            "",         /// Empty.
            "a",        /// Single character, target, does not shrink.
            "z",        /// Single character, non-target, shrinks.
            "ab",       /// 2 characters, even halves.
            "abc",      /// 3 characters, odd halves, middle dropped.
            "aaa",      /// All targets.
            "hello",    /// Longer string.
            "café"      /// Unicode.
        ]
        
        for string in strings
        {
            validateShrinkCandidates(of: string)
        }
    }
    
    
    
    func testSubstringEmptyShrinking() throws
    {
        let empty: Substring = ""[...]
        
        XCTAssertEqual(empty.shrink(), [])
    }
    
    
    
    func testSubstringShrinkingMatchesStringShrinking() throws
    {
        let strings: [String] =
        [
            "",         /// Empty.
            "a",        /// Single character, target, does not shrink.
            "z",        /// Single character, non-target, shrinks.
            "ab",       /// 2 characters, even halves.
            "abc",      /// 3 characters, odd halves, middle dropped.
            "aaa",      /// All targets.
            "hello",    /// Longer string.
            "café"      /// Unicode.
        ]
        
        for string in strings
        {
            let stringCandidates    : [String]  = string.shrink()
            let substring           : Substring     = string[...]
            let substringCandidates : [Substring]   = substring.shrink()
            
            XCTAssertEqual(
                substringCandidates.map { String($0) },
                stringCandidates
            )
        }
    }
}



// MARK: - Extensions

private extension StringArbitraryTests
{
    /// Validates that arbitrary value generation of the given type is
    /// deterministic.
    /// - Parameter type: The type to evaluate.
    func validateDeterminism<T>(
        of type: T.Type
    ) where T : Arbitrary & Equatable
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                T.arbitrary(using: context1),
                T.arbitrary(using: context2)
            )
        }
    }
    
    
    
    /// Checks whether the given scalar is in the ASCII printable range, or
    /// in one of the known Unicode generation ranges.
    /// - Parameter scalar: The scalar to evaluate.
    /// - Returns: Whether the given scalar is in the ASCII printable range,
    /// or in one of the known Unicode generation ranges
    func isInExpectedRange(
        _ scalar: Unicode.Scalar
    ) -> Bool
    {
        let lower   = UInt32(Unicode.Scalar.asciiPrintableRange.lowerBound)
        let upper   = UInt32(Unicode.Scalar.asciiPrintableRange.upperBound)
        
        if (lower...upper).contains(scalar.value)
        {
            return true
        }
        
        for (lower, upper) in Unicode.Scalar.arbitraryRanges
        {
            if (lower...upper).contains(scalar.value)
            {
                return true
            }
        }
        
        return false
    }
    
    
    
    /// Validates the shrink candidates for the given character.
    /// - Parameter char: The character to evaluate.
    func validateShrinkCandidates(
        of char: Character
    )
    {
        let target      : Character     = "a"
        let candidates  : [Character]   = char.shrink()
        
        if char == target
        {
            XCTAssertEqual(candidates, [])
            return
        }
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, target)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, char)
        }
        
        let scalars: Character.UnicodeScalarView = char.unicodeScalars
        
        if scalars.count == 1
        {
            /// Single-scalars: all candidates must be between `value` and
            /// `targetValue`.
            let value       : UInt32    = scalars.first!.value
            let targetValue : UInt32    = target.unicodeScalars.first!.value
            let lower       : UInt32    = min(value, targetValue)
            let upper       : UInt32    = max(value, targetValue)
            
            for candidate in candidates
            {
                let candidateScalars: Character.UnicodeScalarView
                    = candidate.unicodeScalars
                
                XCTAssertEqual(candidateScalars.count, 1)
                
                XCTAssertGreaterThanOrEqual(
                    candidateScalars.first!.value,
                    lower
                )
                
                XCTAssertLessThanOrEqual(
                    candidateScalars.first!.value,
                    upper
                )
            }
        }
        else
        {
            /// Multi-scalars: each candidate must be either the target, or
            /// have fewer than the original (the base scalar).
            for candidate in candidates
            {
                XCTAssertTrue(
                    candidate == target
                    || candidate.unicodeScalars.count < scalars.count
                )
            }
        }
    }
    
    
    
    /// Validates the shrink candidates for the given Unicode scalar.
    /// - Parameter scalar: The scalar to evaluate.
    func validateShrinkCandidates(
        of scalar: Unicode.Scalar
    )
    {
        let target      : Unicode.Scalar    = "a"
        let candidates  : [Unicode.Scalar]  = scalar.shrink()
        
        if scalar == target
        {
            XCTAssertEqual(candidates, [])
            return
        }
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, target)
        
        let lower: UInt32 = min(scalar.value, target.value)
        let upper: UInt32 = max(scalar.value, target.value)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, scalar)
            XCTAssertGreaterThanOrEqual(candidate.value, lower)
            XCTAssertLessThanOrEqual(candidate.value, upper)
        }
    }
    
    
    
    /// Validates the shrink candidates for the given string.
    /// - Parameter string: The string to evaluate.
    func validateShrinkCandidates(
        of string: String
    )
    {
        let candidates: [String] = string.shrink()
        
        if string.isEmpty
        {
            XCTAssertEqual(candidates, [])
            return
        }
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, "")
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, string)
            XCTAssertLessThanOrEqual(candidate.count, string.count)
        }
    }
}
