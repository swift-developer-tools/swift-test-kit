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



internal final class ArbitraryGeneratorTests: TestKitCase
{
    func testDeterminism()
    {
        Generator<Int>.arbitrary().assertDeterministic()
        Generator<UInt8>.arbitrary().assertDeterministic()
        Generator<Double>.arbitrary().assertDeterministic()
        Generator<Bool>.arbitrary().assertDeterministic()
        Generator<[Int]>.arbitrary().assertDeterministic()
        Generator<String>.arbitrary().assertDeterministic()
        Generator<Substring>.arbitrary().assertDeterministic()
        Generator<Character>.arbitrary().assertDeterministic()
    }
    
    
    
    func testGenerationEquivalence()
    {
        validateGenerationEquivalence(of: Int.self)
        validateGenerationEquivalence(of: UInt8.self)
        validateGenerationEquivalence(of: Double.self)
        validateGenerationEquivalence(of: Bool.self)
        validateGenerationEquivalence(of: [Int].self)
        validateGenerationEquivalence(of: String.self)
        validateGenerationEquivalence(of: Substring.self)
        validateGenerationEquivalence(of: Character.self)
    }
    
    
    
    func testShrinkingEquivalence()
    {
        validateShrinkingEquivalence(of: Int.self)
        validateShrinkingEquivalence(of: UInt8.self)
        validateShrinkingEquivalence(of: Double.self)
        validateShrinkingEquivalence(of: Bool.self)
        validateShrinkingEquivalence(of: [Int].self)
        validateShrinkingEquivalence(of: String.self)
        validateShrinkingEquivalence(of: Substring.self)
        validateShrinkingEquivalence(of: Character.self)
    }
    
    
    
    func testShrinkAtTargetProducesEmpty()
    {
        let intGen          = Generator<Int>.arbitrary()
        let uint8Gen        = Generator<UInt8>.arbitrary()
        let doubleGen       = Generator<Double>.arbitrary()
        let boolGen         = Generator<Bool>.arbitrary()
        let intArrayGen     = Generator<[Int]>.arbitrary()
        let stringGen       = Generator<String>.arbitrary()
        let substringGen    = Generator<Substring>.arbitrary()
        let characterGen    = Generator<Character>.arbitrary()
        
        XCTAssertTrue(intGen.shrink(0).isEmpty)
        XCTAssertTrue(uint8Gen.shrink(0).isEmpty)
        XCTAssertTrue(doubleGen.shrink(0.0).isEmpty)
        XCTAssertTrue(boolGen.shrink(false).isEmpty)
        XCTAssertTrue(intArrayGen.shrink([]).isEmpty)
        XCTAssertTrue(stringGen.shrink("").isEmpty)
        XCTAssertTrue(substringGen.shrink("").isEmpty)
        XCTAssertTrue(characterGen.shrink("a").isEmpty)
    }
    
    
    
    func testComposesWithMap()
    {
        let generator: Generator<String> = Generator<Int>
            .arbitrary()
            .map { String($0) }
        
        for _ in 0..<1000
        {
            let value: String = generator.generate(.random)
            
            XCTAssertNotNil(Int(value))
        }
    }
    
    
    
    func testComposesWithFilter()
    {
        let generator: Generator<Int> =
            .arbitrary()
            .filter { $0 % 2 == 0 }
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertEqual(value % 2, 0)
        }
        
        let candidates: [Int] = generator.shrink(50)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate % 2, 0)
        }
    }
}



// MARK: - Support

extension ArbitraryGeneratorTests
{
    /// Validates that ``Generator/arbitrary()`` produces the same values as
    /// ``Generator/generate(using:)`` for the given type.
    /// - Parameter type: The type to evaluate.
    private func validateGenerationEquivalence<T>(
        of type: T.Type
    ) where T : Arbitrary & Equatable
    {
        let generator: Generator<T> = .arbitrary()
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let fromGenerator   : T     = generator.generate(context1)
            let fromProtocol    : T     = T.arbitrary(using: context2)
            
            if
                fromGenerator.isNaN,
                fromProtocol.isNaN
            {
                continue
            }
            
            XCTAssertEqual(fromGenerator, fromProtocol)
        }
    }
    
    
    
    /// Validates that ``Generator/arbitrary()`` produces the same shrink
    /// candidates as ``Arbitrary/shrink()`` for the given type.
    /// - Parameter type: The type to evaluate.
    private func validateShrinkingEquivalence<T>(
        of type: T.Type
    ) where T : Arbitrary & Equatable
    {
        let generator: Generator<T> = .arbitrary()
        
        for _ in 0..<1000
        {
            let value           : T     = T.arbitrary(using: .random)
            let fromGenerator   : [T]   = generator.shrink(value)
            let fromProtocol    : [T]   = value.shrink()
            
            XCTAssertEqual(fromGenerator, fromProtocol)
        }
    }
}
