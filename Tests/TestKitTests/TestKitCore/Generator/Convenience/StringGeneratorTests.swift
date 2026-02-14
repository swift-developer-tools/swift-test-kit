//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class StringGeneratorTests: XCTestCaseStopOnFail
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism()
    {
        let generator: Generator<String> = .string(count: 5)
        
        generator.assertDeterministic()
    }
    
    
    
    func testExactCountProducesCorrectCount()
    {
        let generator: Generator<String> = .string(count: 7)
        
        validateCount(
            of:         generator,
            expected:   7...7
        )
    }
    
    
    
    func testExactCountZeroProducesEmpty()
    {
        let generator: Generator<String> = .string(
            count:          10,
            characters:     .digit()
        )
        
        let digits: String = "0123456789"
        
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            XCTAssertEqual(string.count, digits.count)
            
            for character in string
            {
                XCTAssertTrue(digits.contains(character))
            }
        }
    }
    
    
    
    func testExactCountUsesCustomCharacterGenerator()
    {
        let generator: Generator<String> = .string(count: 0)
        
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            XCTAssertTrue(string.isEmpty)
        }
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount()
    {
        let generator   : Generator<String>     = .string(count: 3)
        let string      : String                = "zxyw"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, string.count)
        }
    }
    
    
    
    func testExactCountShrinkElementsConvergeTowardZero()
    {
        let generator   : Generator<String>     = .string(count: 2)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, string)
        }
        
        let characters: [Character] = Array(string)
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            let chars: [Character] = Array($0)
            
            return chars[0] != characters[0]
                && chars[1] == characters[1]
                && chars[2] == characters[2]
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            let chars: [Character] = Array($0)
            
            return chars[0] == characters[0]
                && chars[1] != characters[1]
                && chars[2] == characters[2]
        }
        
        XCTAssertTrue(onlySecondShrunk)
        
        let onlyThirdShrunk: Bool = candidates.contains
        {
            let chars: [Character] = Array($0)
            
            return chars[0] == characters[0]
                && chars[1] == characters[1]
                && chars[2] != characters[2]
        }
        
        XCTAssertTrue(onlyThirdShrunk)
    }
    
    
    
    func testExactCountShrinkAllAsProducesEmpty()
    {
        let generator   : Generator<String>     = .string(count: 3)
        let string      : String                = "aaa"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let generator: Generator<String> = .string(count: 2...8)
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeCountRespectsBounds()
    {
        let generator: Generator<String> = .string(count: 3...7)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testClosedRangeProducesVariousCounts()
    {
        let generator   : Generator<String>     = .string(count: 0...10)
        var counts      : Set<Int>              = []
        
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            counts.insert(string.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkReducesCount()
    {
        let generator   : Generator<String>     = .string(count: 2...8)
        let string      : String                = "abcde"
        let candidates  : [String]              = generator.shrink(string)
        
        let isShorter: Bool = candidates.contains { $0.count < string.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<String>     = .string(count: 3...8)
        let string      : String                = "abcde"
        let candidates  : [String]              = generator.shrink(string)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinkCharacters()
    {
        let generator   : Generator<String>     = .string(count: 3...8)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<String>     = .string(count: 0...5)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let generator: Generator<String> = .string(count: 2..<9)
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeCountRespectsBounds()
    {
        let generator: Generator<String> = .string(count: 3..<8)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testRangeProducesVariousCounts()
    {
        let generator   : Generator<String>     = .string(count: 0..<11)
        var counts      : Set<Int>              = []
        
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            counts.insert(string.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkReducesCount()
    {
        let generator   : Generator<String>     = .string(count: 2..<9)
        let string      : String                = "abcde"
        let candidates  : [String]              = generator.shrink(string)
        
        let isShorter: Bool = candidates.contains { $0.count < string.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<String>     = .string(count: 3..<9)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinkCharacters()
    {
        let generator   : Generator<String>     = .string(count: 3..<9)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<String>     = .string(count: 0..<6)
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Non-empty string generation
    
    func testNonEmptyStringDeterminism()
    {
        let generator: Generator<String> = .nonEmptyString()
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptyStringNeverProducesEmpty()
    {
        let generator: Generator<String> = .nonEmptyString()
        
        validateCount(
            of:         generator,
            expected:   1...Int.max
        )
    }
    
    
    
    func testNonEmptyStringUsesCustomCharacterGenerator()
    {
        let generator: Generator<String>
            = .nonEmptyString(characters: .digit())
        
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            XCTAssertFalse(string.isEmpty)
            
            for character in string
            {
                XCTAssertTrue("0123456789".contains(character))
            }
        }
    }
    
    
    
    // MARK: - Non-empty string shrinking
    
    func testNonEmptyStringShrinkNeverProducesEmpty()
    {
        let generator   : Generator<String>     = .nonEmptyString()
        let string      : String                = "xyz"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isEmpty)
        }
    }
    
    
    
    func testNonEmptyStringShrinkSingleElementOnlyShrinkCharacter()
    {
        let generator   : Generator<String>     = .nonEmptyString()
        let string      : String                = "z"
        let candidates  : [String]              = generator.shrink(string)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
        }
    }
}



// MARK: - Support

extension StringGeneratorTests
{
    /// Validates that the given generator produces strings with counts within
    /// the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluate.
    ///   - expected: The expected range of counts.
    private func validateCount(
        of generator    : Generator<String>,
        expected        : ClosedRange<Int>
    )
    {
        for _ in 0..<1000
        {
            let string: String = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(string.count, expected.lowerBound)
            XCTAssertLessThanOrEqual(string.count, expected.upperBound)
        }
    }
}
