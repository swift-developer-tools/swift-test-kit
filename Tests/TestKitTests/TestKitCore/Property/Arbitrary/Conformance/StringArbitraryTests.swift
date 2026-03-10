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



internal final class StringArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testCharGenerationDeterminism()
    {
        assertArbitraryDeterminism(of: Character.self)
    }
    
    
    
    func testScalarGenerationDeterminism()
    {
        assertArbitraryDeterminism(of: Unicode.Scalar.self)
    }
    
    
    
    func testStringGenerationDeterminism()
    {
        assertArbitraryDeterminism(of: String.self)
    }
    
    
    
    func testSubstringGenerationDeterminism()
    {
        assertArbitraryDeterminism(of: Substring.self)
    }
    
    
    
    // MARK: - Character generation
    
    func testCharacterGenerationSizeZeroProducesASCII()
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
    
    
    
    func testCharacterGenerationProducesVariety()
    {
        var unique: Set<Character> = []
        
        for _ in 0..<10_000
        {
            let character = Character.arbitrary(using: .random)
            
            unique.insert(character)
        }
        
        let expected = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.95
        
        XCTAssertGreaterThan(unique.count, Int(expected))
    }
    
    
    
    // MARK: - Scalar generation
    
    func testScalarGenerationSizeZeroProducesASCII()
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
    
    
    
    func testScalarGenerationValuesInExpectedRange()
    {
        for _ in 0..<1000
        {
            let scalar = Unicode.Scalar.arbitrary(using: .random)
            
            XCTAssertTrue(isInExpectedRange(scalar))
        }
    }
    
    
    
    func testScalarGenerationProducesUnicode()
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
    
    
    
    func testScalarGenerationProducesVariety()
    {
        var unique: Set<UInt32> = []
        
        for _ in 0..<10_000
        {
            let scalar = Unicode.Scalar.arbitrary(using: .random)
            
            unique.insert(scalar.value)
        }
        
        let expected = Double(Unicode.Scalar.asciiPrintableRange.count) * 0.95
        
        XCTAssertGreaterThan(unique.count, Int(expected))
    }
    
    
    
    // MARK: - String generation
    
    func testStringGenerationSizeZeroProducesEmpty()
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(String.arbitrary(using: .randomZeroSize), "")
        }
    }
    
    
    
    func testStringGenerationLengthRespectsSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let string = String.arbitrary(using: .randomSeed(size: size))
            
            XCTAssertLessThanOrEqual(string.count, size)
        }
    }
    
    
    
    func testStringGenerationProducesEmptyAndNonEmpty()
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
    
    
    
    func testStringGenerationProducesVariousCounts()
    {
        let size    : Int       = 20
        var counts  : Set<Int>  = []
        
        for _ in 0..<1000
        {
            let string = String.arbitrary(using: .randomSeed(size: size))
            
            counts.insert(string.count)
        }
        
        XCTAssertGreaterThan(counts.count, size / 2)
    }
    
    
    
    // MARK: - Substring generation
    
    func testSubstringGenerationSizeZeroProducesEmpty()
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(Substring.arbitrary(using: .randomZeroSize), "")
        }
    }
    
    
    
    func testSubstringGenerationMatchesStringContent()
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
    
    func testCharacterShrinking()
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
    
    
    
    func testScalarShrinking()
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
    
    
    
    func testStringShrinking()
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
    
    
    
    func testSubstringEmptyShrinking()
    {
        let empty: Substring = ""[...]
        
        XCTAssertEqual(empty.shrink(), [])
    }
    
    
    
    func testSubstringShrinkingMatchesStringShrinking()
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
    
    
    
    // MARK: - Character mutation
    
    func testCharacterMutateMultiScalarCollapsesToSingleScalar()
    {
        /// Multi-scalar: combining accent (é = e + combining acute).
        let multiScalar = Character("\u{0065}\u{0301}")
        
        XCTAssertGreaterThan(multiScalar.unicodeScalars.count, 1)
        
        for _ in 0..<1000
        {
            let mutated: Character = multiScalar.mutate(using: .random)
            
            XCTAssertEqual(mutated.unicodeScalars.count, 1)
        }
    }
    
    
    
    func testCharacterMutateMultiScalarMutatesBaseScalar()
    {
        /// Multi-scalar: combining accent (é = e + combining acute).
        /// Mutation must produce values near the base of `e`.
        let multiScalar     : Character     = .init("\u{0065}\u{0301}")
        let baseValue       : UInt32        = 0x0065
        var totalDistance   : Int           = 0
        let iterations      : Int           = 1000
        
        for _ in 0..<iterations
        {
            let mutated: Character = multiScalar.mutate(using: .random)
            
            let mutatedValue: UInt32 = mutated.unicodeScalars.first!.value
            
            totalDistance += abs(Int(mutatedValue) - Int(baseValue))
        }
        
        /// The average distance should be less than the full ASCII range,
        /// since mutation applies a small delta to the base.
        let averageDistance = Double(totalDistance) / Double(iterations)
        
        XCTAssertLessThan(averageDistance, 50)
    }
    
    
    
    func testCharacterMutationSingleScalarProducesVariety()
    {
        let base    : Character         = .init("k")
        var unique  : Set<Character>    = []
        
        for _ in 0..<10_000
        {
            unique.insert(base.mutate(using: .random))
        }
        
        XCTAssertGreaterThan(unique.count, 5)
    }
    
    
    
    func testCharacterMutateProducesValidCharacters()
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
            for _ in 0..<1000
            {
                let mutated: Character = character.mutate(using: .random)
                
                /// A valid character must have at least one scalar.
                XCTAssertFalse(mutated.unicodeScalars.isEmpty)
            }
        }
    }
    
    
    
    // MARK: - Scalar mutation
    
    func testScalarMutateSizeZeroProducesSmallDelta()
    {
        let base: Unicode.Scalar = "m"
        
        for _ in 0..<1000
        {
            let mutated: Unicode.Scalar = base.mutate(using: .randomZeroSize)
            
            let distance: Int = abs(Int(mutated.value) - Int(base.value))
            
            /// At size `0`, `maxDelta` is `1`, so the distance must be within
            /// 1 scalar value of the original (or fall back for edge cases).
            XCTAssertLessThanOrEqual(distance, 1)
        }
    }
    
    
    
    func testScalarMutateDeltaScalesWithSizes()
    {
        let base                : Unicode.Scalar    = "a"
        var maxDistanceSmall    : Int               = 0
        var maxDistanceLarge    : Int               = 0
        
        for _ in 0..<10_000
        {
            let smallContext    = GenerationContext.randomSeed(size: 10)
            let largeConext     = GenerationContext.randomSeed(size: 100)
            
            let mutatedSmall: Unicode.Scalar = base.mutate(using: smallContext)
            let mutatedLarge: Unicode.Scalar = base.mutate(using: largeConext)
            
            maxDistanceSmall = max(
                maxDistanceSmall,
                abs(Int(mutatedSmall.value) - Int(base.value))
            )
            
            maxDistanceLarge = max(
                maxDistanceLarge,
                abs(Int(mutatedLarge.value) - Int(base.value))
            )
        }
        
        XCTAssertLessThanOrEqual(maxDistanceSmall, 1)
        XCTAssertGreaterThan(maxDistanceLarge, 1)
    }
    
    
    
    func testScalarMutateCanReturnSelf()
    {
        let base            : Unicode.Scalar    = "m"
        var returnedSelf    : Bool              = false
        
        for _ in 0..<10_000
        {
            let mutated: Unicode.Scalar = base.mutate(using: .random)
            
            if mutated == base
            {
                returnedSelf = true
                break
            }
        }
        
        XCTAssertTrue(returnedSelf)
    }
    
    
    
    func testScalarMutateProducesVariety()
    {
        let base    : Unicode.Scalar    = "m"
        var unique  : Set<UInt32>       = []
        
        for _ in 0..<10_000
        {
            let mutated: Unicode.Scalar = base.mutate(using: .random)
            
            unique.insert(mutated.value)
        }
        
        XCTAssertGreaterThan(unique.count, 5)
    }
    
    
    
    func testScalarMutateNearZeroFallback()
    {
        /// `U+0001` with a negative delta would produce `0` or negative.
        /// It must be handled gracefully without crashing.
        let base = Unicode.Scalar(1)!
        
        for _ in 0..<10_000
        {
            let mutated: Unicode.Scalar = base.mutate(using: .random)
            
            XCTAssertTrue(mutated.value > 0 || mutated.value == 0)
        }
    }
    
    
    
    func testScalarMutatProducesValidScalars()
    {
        let scalars: [Unicode.Scalar] =
        [
            .init(0x0001),      /// Near minimum.
            .init("a"),         /// Target.
            .init(0xD7FF)!,     /// Just below surrogate range.
            .init(0xE000)!,     /// Just above surrogate range.
            .init(0x1F600)!     /// Emoji.
        ]
        
        for scalar in scalars
        {
            for _ in 0..<1000
            {
                /// Any return value means the scalar is valid.
                _ = scalar.mutate(using: .random)
            }
        }
    }
    
    
    
    // MARK: - String mutation
    
    func testStringMutateEmptyProducesSingleCharacter()
    {
        for _ in 0..<1000
        {
            let mutated: String = "".mutate(using: .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testStringMutateProducesVariety()
    {
        let base    : String        = "hello world"
        var unique  : Set<String>   = []
        
        for _ in 0..<1000
        {
            unique.insert(base.mutate(using: .random))
        }
        
        XCTAssertGreaterThan(unique.count, 100)
    }
    
    
    
    func testStringMutateCountDistribution()
    {
        let iterations  : Int       = 10_000
        let base        : String    = "abcde"
        var same        : Int       = 0
        var more        : Int       = 0
        var fewer       : Int       = 0
        
        for _ in 0..<iterations
        {
            let mutated: String = base.mutate(using: .random)
            
            if mutated.count == base.count
            {
                same += 1
            }
            else if mutated.count == base.count + 1
            {
                more += 1
            }
            else if mutated.count == base.count - 1
            {
                fewer += 1
            }
            else
            {
                XCTFail(
                    "Unexpected count change:"
                    + " \(base.count) to \(mutated.count)"
                )
            }
        }
        
        XCTAssertGreaterThan(same, Int(Double(iterations) * 0.7 * 0.95))
        XCTAssertGreaterThan(more, Int(Double(iterations) * 0.15 * 0.95))
        XCTAssertGreaterThan(fewer, Int(Double(iterations) * 0.15 * 0.95))
    }
    
    
    
    func testStringMutateSingleCharacterAllPathsReachable()
    {
        let base    : String    = "x"
        var same    : Bool      = false
        var more    : Bool      = false
        var empty   : Bool      = false
        
        for _ in 0..<10_000
        {
            let mutated: String = base.mutate(using: .random)
            
            switch mutated.count
            {
                case 0  : empty     = true
                case 1  : same      = true
                case 2  : more      = true
                    
                default:
                    
                    XCTFail("Unexpected count: \(mutated.count)")
            }
            
            if
                same,
                more,
                empty
            {
                break
            }
        }
        
        XCTAssertTrue(same)
        XCTAssertTrue(more)
        XCTAssertTrue(empty)
    }
    
    
    
    func testStringMutateInPlaceChangesAtMostOneCharacter()
    {
        let base        : String    = "abcde"
        var verified    : Int       = 0
        
        for _ in 0..<10_000
        {
            let mutated: String = base.mutate(using: .random)
            
            guard mutated.count == base.count
            else
            {
                continue
            }
            
            let differences: Int = zip(base, mutated)
                .filter { $0.0 != $0.1 }
                .count
            
            XCTAssertLessThanOrEqual(differences, 1)
            
            verified += 1
        }
        
        XCTAssertGreaterThan(verified, 1000)
    }
    
    
    
    func testStringMutateInsertionAddsOneCharacter()
    {
        let base        : String    = "abc"
        var verified    : Int       = 0
        
        for _ in 0..<10_000
        {
            let mutated: String = base.mutate(using: .random)
            
            guard mutated.count == base.count + 1
            else
            {
                continue
            }
            
            var found: Bool = false
            
            for index in mutated.indices
            {
                var candidate: String = mutated
                
                candidate.remove(at: index)
                
                if candidate == base
                {
                    found = true
                    break
                }
            }
            
            XCTAssertTrue(found)
            
            verified += 1
        }
        
        XCTAssertGreaterThan(verified, 1000)
    }
    
    
    
    func testStringMutateRemovalRemovesOneCharacter()
    {
        let base        : String    = "abcde"
        var verified    : Int       = 0
        
        for _ in 0..<10_000
        {
            let mutated: String = base.mutate(using: .random)
            
            guard mutated.count == base.count - 1
            else
            {
                continue
            }
            
            /// The mutated string must be a subsequence of the original,
            /// less one character.
            var baseIndex       : String.Index  = base.startIndex
            var mutatedIndex    : String.Index  = mutated.startIndex
            var skipped         : Int           = 0
            
            while
                baseIndex < base.endIndex,
                mutatedIndex < mutated.endIndex
            {
                if base[baseIndex] == mutated[mutatedIndex]
                {
                    mutatedIndex = mutated.index(after: mutatedIndex)
                }
                else
                {
                    skipped += 1
                }
                
                baseIndex = base.index(after: baseIndex)
            }
            
            /// Acount for removal at the end.
            skipped += base.distance(from: baseIndex, to: base.endIndex)
            
            XCTAssertEqual(skipped, 1)
            
            verified += 1
        }
        
        XCTAssertGreaterThan(verified, 1000)
    }
    
    
    
    // MARK: - Substring mutation
    
    func testSubstringMutateMatchesStringMutate()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let string  = String.arbitrary(using: context1)
            let sub     = Substring.arbitrary(using: context2)
            
            let (context3, context4) = GenerationContext.sameRandomContexts
            
            let stringMutated   : String    = string.mutate(using: context3)
            let subMutated      : Substring = sub.mutate(using: context4)
            
            XCTAssertEqual(String(subMutated), stringMutated)
        }
    }
    
    
    
    func testSubstringMutateEmptyProducesSingleCharacter()
    {
        for _ in 0..<1000
        {
            let empty   : Substring     = ""[...]
            let mutated : Substring     = empty.mutate(using: .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
}



// MARK: - Support

extension StringArbitraryTests
{
    /// Checks whether the given scalar is in the ASCII printable range, or
    /// in one of the known Unicode generation ranges.
    /// - Parameter scalar: The scalar to evaluate.
    /// - Returns: Whether the given scalar is in the ASCII printable range,
    /// or in one of the known Unicode generation ranges
    private func isInExpectedRange(
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
    private func validateShrinkCandidates(
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
    private func validateShrinkCandidates(
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
    private func validateShrinkCandidates(
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
