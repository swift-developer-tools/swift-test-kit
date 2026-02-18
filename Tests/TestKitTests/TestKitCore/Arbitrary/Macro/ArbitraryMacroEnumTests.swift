//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKit
import XCTest
@testable import TestKitCore



/// Distribution tests in this class use an 85% threshold rather than the
/// standard 95%. At size zero, enums with base cases generate only base cases
/// as part of infinite recursion prevention. This skews the distribution for
/// enums with few base cases relative to total cases, making a 95% threshold
/// unreliable even over 10,000 iterations.
internal final class ArbitraryMacroEnumTests: XCTestCaseStopOnFail
{
    // MARK: - SingleNoValues
    
    func testSingleNoValuesDeterminism()
    {
        assertArbitraryDeterminism(of: SingleNoValues.self)
    }
    
    
    
    func testSingleNoValuesAlwaysProducesSameCase()
    {
        for _ in 0..<1000
        {
            let value = SingleNoValues.arbitrary(using: .random)
            
            XCTAssertEqual(value, .only)
        }
    }
    
    
    
    func testSingleNoValuesShrinkEmpty()
    {
        XCTAssertEqual(SingleNoValues.only.shrink(), [])
    }
    
    
    
    // MARK: - MultipleNoValues
    
    func testMultipleNoValuesDeterminism()
    {
        assertArbitraryDeterminism(of: MultipleNoValues.self)
    }
    
    
    
    func testMultipleNoValuesDistribution()
    {
        let iterations  : Int                       = 10_000
        var counts      : [MultipleNoValues : Int]  = [:]
        
        for _ in 0..<iterations
        {
            let value = MultipleNoValues
                .arbitrary(using: .randomSeed(size: 500))
            
            counts[value, default: 0] += 1
        }
        
        XCTAssertEqual(counts.count, 3)
        
        for (_, count) in counts
        {
            XCTAssertGreaterThan(count, Int(Double(iterations / 3) * 0.85))
        }
    }
    
    
    
    func testMultipleNoValuesShrinkEmpty()
    {
        XCTAssertEqual(MultipleNoValues.a.shrink(), [])
        XCTAssertEqual(MultipleNoValues.b.shrink(), [])
        XCTAssertEqual(MultipleNoValues.c.shrink(), [])
    }
    
    
    
    // MARK: - SingleLabeled
    
    func testSingleLabeledDeterminism()
    {
        assertArbitraryDeterminism(of: SingleLabeled.self)
    }
    
    
    
    func testSingleLabeledSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = SingleLabeled.arbitrary(using: .randomZeroSize)
            
            guard case let .value(id) = value
            else
            {
                XCTFail("Expected .value, got \(value)")
                return
            }
            
            XCTAssertEqual(id, 0)
        }
    }
    
    
    
    func testSingleLabeledShrinkMinimal()
    {
        XCTAssertEqual(SingleLabeled.value(id: 0).shrink(), [])
    }
    
    
    
    func testSingleLabeledShrinkMatchesPropertyShrink()
    {
        let value       : SingleLabeled     = .value(id: 50)
        let candidates  : [SingleLabeled]   = value.shrink()
        
        let expected: [SingleLabeled]
            = (50 as Int).shrink().map { .value(id: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testSingleLabeledShrinkPreservesCase()
    {
        let candidates: [SingleLabeled] = SingleLabeled.value(id: 10).shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            guard case .value = candidate
            else
            {
                XCTFail("Shrink changed the case")
                return
            }
        }
    }
    
    
    
    // MARK: - SingleUnlabeled
    
    func testSingleUnlabeledDeterminism()
    {
        assertArbitraryDeterminism(of: SingleUnlabeled.self)
    }
    
    
    func testSingleUnlabeledSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = SingleUnlabeled.arbitrary(using: .randomZeroSize)
            
            guard case let .value(id) = value
            else
            {
                XCTFail("Expected .value, got \(value)")
                return
            }
            
            XCTAssertEqual(id, 0)
        }
    }
    
    
    
    func testSingleUnlabeledShrinkMinimal()
    {
        XCTAssertEqual(SingleUnlabeled.value(0).shrink(), [])
    }
    
    
    
    func testSingleUnlabeledShrinkMatchesPropertyShrink()
    {
        let value       : SingleUnlabeled       = .value(50)
        let candidates  : [SingleUnlabeled]     = value.shrink()
        
        let expected: [SingleUnlabeled]
            = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testSingleUnlabeledShrinkPreservesCase()
    {
        let candidates: [SingleUnlabeled] = SingleUnlabeled.value(10).shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            guard case .value = candidate
            else
            {
                XCTFail("Shrink changed the case")
                return
            }
        }
    }
    
    
    
    // MARK: - MultipleLabeled
    
    func testMultipleLabeledDeterminism()
    {
        assertArbitraryDeterminism(of: MultipleLabeled.self)
    }
    
    
    
    func testMultipleLabeledDistribution()
    {
        let iterations  : Int   = 10_000
        var circles     : Int   = 0
        var rects       : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = MultipleLabeled
                .arbitrary(using: .randomSeed(size: 500))
            
            switch value
            {
                case .circle    : circles += 1
                case .rect      : rects += 1
            }
        }
        
        let expected = Int(Double(iterations / 2) * 0.85)
        
        XCTAssertGreaterThan(circles, expected)
        XCTAssertGreaterThan(rects, expected)
    }
    
    
    
    func testMMultipleLabeledShrinkMinimal()
    {
        XCTAssertEqual(MultipleLabeled.circle(r: 0).shrink(), [])
        XCTAssertEqual(MultipleLabeled.rect(w: 0, h: 0).shrink(), [])
    }
    
    
    
    func testMultipleLabeledShrinkMatchesPropertyShrink()
    {
        let value       : MultipleLabeled       = .rect(w: 10, h: 5)
        let candidates  : [MultipleLabeled]     = value.shrink()
        var expected    : [MultipleLabeled]     = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for w in (10 as Int).shrink()
        {
            expected.append(.rect(w: w, h: 5))
        }
        
        for h in (5 as Int).shrink()
        {
            expected.append(.rect(w: 10, h: h))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testMultipleLabeledShrinkPreservesCase()
    {
        let circleCandidates: [MultipleLabeled]
            = MultipleLabeled.circle(r: 10).shrink()
        
        XCTAssertFalse(circleCandidates.isEmpty)
        
        for candidate in circleCandidates
        {
            guard case .circle = candidate
            else
            {
                XCTFail("Shrink changed the case from .circle")
                return
            }
        }
        
        let rectCandidates: [MultipleLabeled]
            = MultipleLabeled.rect(w: 10, h: 5).shrink()
        
        XCTAssertFalse(rectCandidates.isEmpty)
        
        for candidate in rectCandidates
        {
            guard case .rect = candidate
            else
            {
                XCTFail("Shrink changed the case from .rect")
                return
            }
        }
    }
    
    
    
    // MARK: - MixedCases
    
    func testMixedCasesDeterminism()
    {
        assertArbitraryDeterminism(of: MixedCases.self)
    }
    
    
    
    func testMixedCasesDistribution()
    {
        let iterations  : Int   = 10_000
        var noneCount   : Int   = 0
        var valueCount  : Int   = 0
        var pairCount   : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = MixedCases.arbitrary(using: .randomSeed(size: 500))
            
            switch value
            {
                case .none  : noneCount += 1
                case .value : valueCount += 1
                case .pair  : pairCount += 1
            }
        }
        
        let expected = Int(Double(iterations / 3) * 0.85)
        
        XCTAssertGreaterThan(noneCount, expected)
        XCTAssertGreaterThan(valueCount, expected)
        XCTAssertGreaterThan(pairCount, expected)
    }
    
    
    
    func testMixedCasesShrinkEmpty()
    {
        XCTAssertEqual(MixedCases.none.shrink(), [])
    }
    
    
    
    func testMixedCasesShrinkMinimal()
    {
        XCTAssertEqual(MixedCases.value(id: 0).shrink(), [])
        XCTAssertEqual(MixedCases.pair(x: 0, y: "").shrink(), [])
    }
    
    
    
    func testMixedCasesShrinkMatchesPropertyShrink()
    {
        let value       : MixedCases    = .pair(x: 10, y: "abc")
        let candidates  : [MixedCases]  = value.shrink()
        var expected    : [MixedCases]  = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(.pair(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(.pair(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testMixedCasesShrinkPreservesCase()
    {
        let valueCandidates: [MixedCases] = MixedCases.value(id: 10).shrink()
        
        XCTAssertFalse(valueCandidates.isEmpty)
        
        for candidate in valueCandidates
        {
            guard case .value = candidate
            else
            {
                XCTFail("Shrink changed the case from .value")
                return
            }
        }
        
        let pairCandidates: [MixedCases]
            = MixedCases.pair(x: 10, y: "abc").shrink()
        
        XCTAssertFalse(pairCandidates.isEmpty)
        
        for candidate in pairCandidates
        {
            guard case .pair = candidate
            else
            {
                XCTFail("Shrink changed the case from .pair")
                return
            }
        }
    }
    
    
    
    // MARK: - UnlabeledMultiple
    
    func testUnlabeledMultipleDeterminism()
    {
        assertArbitraryDeterminism(of: UnlabeledMultiple.self)
    }
    
    
    
    func testUnlabeledMultipleSizeZeroProduct()
    {
        for _ in 0..<1000
        {
            let value = UnlabeledMultiple.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .pair(a, b):
                    
                    XCTAssertEqual(a, 0)
                    XCTAssertEqual(b, "")
            }
        }
    }
    
    
    
    func testUnlabeledMultipleShrinkMinimal()
    {
        XCTAssertEqual(UnlabeledMultiple.pair(0, "").shrink(), [])
    }
    
    
    
    func testUnlabeledMultipleShrinkMatchesPropertyShrink()
    {
        let value       : UnlabeledMultiple     = .pair(10, "abc")
        let candidates  : [UnlabeledMultiple]   = value.shrink()
        var expected    : [UnlabeledMultiple]   = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for a in (10 as Int).shrink()
        {
            expected.append(.pair(a, "abc"))
        }
        
        for b in "abc".shrink()
        {
            expected.append(.pair(10, b))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - MixedLabels
    
    func testMixedLabelsDeterminism()
    {
        assertArbitraryDeterminism(of: MixedLabels.self)
    }
    
    
    
    func testMixedLabelsSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MixedLabels.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(name, _):
                    
                    XCTAssertEqual(name, "")
            }
        }
    }
    
    
    
    func testMixedLabelsShrinkMinimal()
    {
        XCTAssertEqual(MixedLabels.value(name: "", 0).shrink(), [])
    }
    
    
    
    func testMixedLabelsShrinkMatchesPropertyShrink()
    {
        let value       : MixedLabels       = .value(name: "abc", 10)
        let candidates  : [MixedLabels]     = value.shrink()
        var expected    : [MixedLabels]     = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for name in "abc".shrink()
        {
            expected.append(.value(name: name, 10))
        }
        
        for v in (10 as Int).shrink()
        {
            expected.append(.value(name: "abc", v))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Generics
    
    func testGenericsDeterminism()
    {
        assertArbitraryDeterminism(of: Generics<Int, String>.self)
    }
    
    
    
    func testGenericsSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Generics<Int, String>.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .a(a)  : XCTAssertEqual(a, 0)
                case let .b(b)  : XCTAssertEqual(b, "")
                case .none      : break
            }
        }
    }
    
    
    
    func testGenericsShrinkMinimal()
    {
        XCTAssertEqual(Generics<Int, String>.a(0).shrink(), [])
        XCTAssertEqual(Generics<Int, String>.b("").shrink(), [])
        XCTAssertEqual(Generics<Int, String>.none.shrink(), [])
    }
    
    
    
    func testGenericsShrinkMatchesPropertyShrink()
    {
        let value       : Generics<Int, String>     = .a(50)
        let candidates  : [Generics<Int, String>]   = value.shrink()
        
        let expected: [Generics<Int, String>]
            = (50 as Int).shrink().map { .a($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testGenericsPreservesCase()
    {
        let aCandidates: [Generics] = Generics<Int, String>.a(10).shrink()
        
        XCTAssertFalse(aCandidates.isEmpty)
        
        for candidate in aCandidates
        {
            guard case .a = candidate
            else
            {
                XCTFail("Shrink changed the case from .a")
                return
            }
        }
        
        let bCandidates: [Generics] = Generics<Int, String>.b("abc").shrink()
        
        XCTAssertFalse(bCandidates.isEmpty)
        
        for candidate in bCandidates
        {
            guard case .b = candidate
            else
            {
                XCTFail("Shrink changed the case from .b")
                return
            }
        }
    }
    
    
    
    // MARK: - PhantomGeneric
    
    func testPhantomGenericDeterminism()
    {
        assertArbitraryDeterminism(of: PhantomGeneric<Phantom>.self)
    }
    
    
    
    func testPhantomGenericSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = PhantomGeneric<Phantom>
                .arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(v)  : XCTAssertEqual(v, 0)
                case .empty         : break
            }
        }
    }
    
    
    
    func testPhantomGenericShrinkMatchesPropertyShrink()
    {
        let value       : PhantomGeneric<Phantom>       = .value(50)
        let candidates  : [PhantomGeneric<Phantom>]     = value.shrink()
        
        let expected: [PhantomGeneric<Phantom>]
            = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Outer
    
    func testOuterDeterminism()
    {
        assertArbitraryDeterminism(of: Outer.Inner.self)
    }
    
    
    
    func testOuterSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Outer.Inner.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(v)  : XCTAssertEqual(v, 0)
                case .empty         : break
            }
        }
    }
    
    
    
    func testOuterShrinkMatchesPropertyShrink()
    {
        let value       : Outer.Inner       = .value(50)
        let candidates  : [Outer.Inner]     = value.shrink()
        
        let expected: [Outer.Inner] = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - DeepOuter
    
    func testDeepOuterDeterminism()
    {
        assertArbitraryDeterminism(of: DeepOuter.Middle.Deep.self)
    }
    
    
    
    func testDeepOuterSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = DeepOuter.Middle.Deep.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(v)  : XCTAssertEqual(v, 0)
                case .empty         : break
            }
        }
    }
    
    
    
    func testDeepOuterShrinkMatchesPropertyShrink()
    {
        let value       : DeepOuter.Middle.Deep     = .value(50)
        let candidates  : [DeepOuter.Middle.Deep]   = value.shrink()
        
        let expected: [DeepOuter.Middle.Deep]
            = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Wildcard
    
    func testWildcardDeterminism()
    {
        assertArbitraryDeterminism(of: Wildcard.self)
    }
    
    
    
    func testWildcardSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Wildcard.arbitrary(using: .randomZeroSize)
            
            guard case let .value(v) = value
            else
            {
                XCTFail("Expected .value, got \(value)")
                return
            }
            
            XCTAssertEqual(v, 0)
        }
    }
    
    
    
    func testWildcardShrinkMatchesPropertyShrink()
    {
        let value       : Wildcard      = .value(50)
        let candidates  : [Wildcard]    = value.shrink()
        
        let expected: [Wildcard] = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Many
    
    func testManyDeterminism()
    {
        assertArbitraryDeterminism(of: Many.self)
    }
    
    
    
    func testManyDistribution()
    {
        let iterations  : Int               = 10_000
        var counts      : [String : Int]    = [:]
        
        for _ in 0..<iterations
        {
            let value = Many.arbitrary(using: .randomSeed(size: 500))
            
            counts[value.description, default: 0] += 1
        }
        
        XCTAssertEqual(counts.count, 5)
        
        let expected = Int(Double(iterations / 5) * 0.85)
        
        for (_, count) in counts
        {
            XCTAssertGreaterThan(count, expected)
        }
    }
    
    
    
    func testManyPreservesCase()
    {
        let candidates: [Many] = Many.c(x: 10, y: "abc").shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            guard case .c = candidate
            else
            {
                XCTFail("Shrink changed the case from .c")
                return
            }
        }
    }
    
    
    
    // MARK: - MultipleCaseDecl
    
    func testMultipleCaseDeclDeterminism()
    {
        assertArbitraryDeterminism(of: MultipleCaseDecl.self)
    }
    
    
    
    func testMultipleCaseDeclDistribution()
    {
        let iterations  : Int               = 10_000
        var counts      : [String : Int]    = [:]
        
        for _ in 0..<iterations
        {
            let value = MultipleCaseDecl
                .arbitrary(using: .randomSeed(size: 500))
            
            switch value
            {
                case .a : counts["a", default: 0] += 1
                case .b : counts["b", default: 0] += 1
                case .c : counts["c", default: 0] += 1
            }
        }
        
        XCTAssertEqual(counts.count, 3)
        
        let expected = Int(Double(iterations / 3) * 0.85)
        
        for (_, count) in counts
        {
            XCTAssertGreaterThan(count, expected)
        }
    }
    
    
    
    func testMultipleCaseDeclShrinkEmpty()
    {
        XCTAssertEqual(MultipleCaseDecl.a.shrink(), [])
        XCTAssertEqual(MultipleCaseDecl.b.shrink(), [])
    }
    
    
    
    func testMultipleCaseDeclShrinkMinimal()
    {
        XCTAssertEqual(MultipleCaseDecl.c(0).shrink(), [])
    }
    
    
    
    func testMultipleCaseDeclShrinkMatchesPropertyShrink()
    {
        let value       : MultipleCaseDecl      = .c(50)
        let candidates  : [MultipleCaseDecl]    = value.shrink()
        
        let expected: [MultipleCaseDecl] = (50 as Int).shrink().map { .c($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - NestedComposition
    
    func testNestedCompositionDeterminism()
    {
        assertArbitraryDeterminism(of: NestedComposition.self)
    }
    
    
    
    func testNestedCompositionDistribution()
    {
        let iterations      : Int   = 10_000
        var labeledCount    : Int   = 0
        var pairCount       : Int   = 0
        var emptyCount      : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = NestedComposition
                .arbitrary(using: .randomSeed(size: 500))
            
            switch value
            {
                case .labeled   : labeledCount += 1
                case .pair      : pairCount += 1
                case .empty     : emptyCount += 1
            }
        }
        
        let expected = Int(Double(iterations / 3) * 0.85)
        
        XCTAssertGreaterThan(labeledCount, expected)
        XCTAssertGreaterThan(pairCount, expected)
        XCTAssertGreaterThan(emptyCount, expected)
    }
    
    
    
    func testNestedCompositionShrinkEmpty()
    {
        XCTAssertEqual(NestedComposition.empty.shrink(), [])
    }
    
    
    
    func testNestedCompositionShrinkMinimal()
    {
        XCTAssertEqual(
            NestedComposition.labeled(shape: .circle(r: 0)).shrink(),
            []
        )
    }
    
    
    
    func testNestedCompositionShrinkMatchesPropertyShrink()
    {
        let shape       : MultipleLabeled       = .rect(w: 10, h: 5)
        let value       : NestedComposition     = .labeled(shape: shape)
        let candidates  : [NestedComposition]   = value.shrink()
        
        let expected: [NestedComposition]
            = shape.shrink().map { .labeled(shape: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testNestedCompositionShrinkPreservesCase()
    {
        let candidates: [NestedComposition]
            = NestedComposition.labeled(shape: .rect(w: 10, h: 5)).shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            guard case .labeled = candidate
            else
            {
                XCTFail("Shrink changed the case from .labeled")
                return
            }
        }
    }
    
    
    
    // MARK: - OptionalAssociated
    
    func testOptionalAssociatedDeterminism()
    {
        assertArbitraryDeterminism(of: OptionalAssociated.self)
    }
    
    
    
    func testOptionalAssociatedShrinkMinimal()
    {
        XCTAssertEqual(OptionalAssociated.value(nil).shrink(), [])
        XCTAssertEqual(OptionalAssociated.empty.shrink(), [])
    }
    
    
    
    func testOptionalAssociatedShrinkMatchesPropertyShrink()
    {
        let value       : OptionalAssociated    = .value(50)
        let candidates  : [OptionalAssociated]  = value.shrink()
        
        let expected: [OptionalAssociated]
            = (50 as Optional<Int>).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - CollectionAssociated
    
    func testCollectionAssociatedDeterminism()
    {
        assertArbitraryDeterminism(of: CollectionAssociated.self)
    }
    
    
    
    func testCollectionAssociatedSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = CollectionAssociated.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .items(items)  : XCTAssertEqual(items, [])
                case let  .map(map)     : XCTAssertEqual(map, [:])
                case .empty             : break
            }
        }
    }
    
    
    
    func testCollectionAssociatedShrinkMinimal()
    {
        XCTAssertEqual(CollectionAssociated.items([]).shrink(), [])
        XCTAssertEqual(CollectionAssociated.map([:]).shrink(), [])
        XCTAssertEqual(CollectionAssociated.empty.shrink(), [])
    }
    
    
    
    func testCollectionAssociatedShrinkMatchesPropertyShrink()
    {
        let value       : CollectionAssociated      = .items([10, 20])
        let candidates  : [CollectionAssociated]    = value.shrink()
        
        let expected: [CollectionAssociated]
            = [10, 20].shrink().map { .items($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - ExplicitAccessOuter
    
    func testExplicitAccessOuterDeterminism()
    {
        assertArbitraryDeterminism(of: ExplicitAccessOuter.Inner.self)
    }
    
    
    
    func testExplicitAccessOuterSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = ExplicitAccessOuter.Inner
                .arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(v)  : XCTAssertEqual(v, 0)
                case .empty         : break
            }
        }
    }
    
    
    
    func testExplicitAccessOuterShrinkMatchesPropertyShrink()
    {
        let value       : ExplicitAccessOuter.Inner     = .value(50)
        let candidates  : [ExplicitAccessOuter.Inner]   = value.shrink()
        
        let expected: [ExplicitAccessOuter.Inner]
            = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Nested
    
    func testNestedDeterminism()
    {
        assertArbitraryDeterminism(of: Nested.Inner.self)
    }
    
    
    
    func testNestedSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Nested.Inner.arbitrary(using: .randomZeroSize)
            
            switch value
            {
                case let .value(v)  : XCTAssertEqual(v, 0)
                case .empty         : break
            }
        }
    }
    
    
    
    func testNestedShrinkMatchesPropertyShrink()
    {
        let value       : Nested.Inner      = .value(50)
        let candidates  : [Nested.Inner]    = value.shrink()
        
        let expected: [Nested.Inner]
            = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - WithRawValue
    
    func testWithRawValueDeterminism()
    {
        assertArbitraryDeterminism(of: WithRawValue.self)
    }
    
    
    
    func testWithRawValueDistribution()
    {
        let iterations  : Int                   = 10_000
        var counts      : [WithRawValue : Int]  = [:]
        
        for _ in 0..<iterations
        {
            let value = WithRawValue.arbitrary(using: .randomSeed(size: 500))
            
            counts[value, default: 0] += 1
        }
        
        XCTAssertEqual(counts.count, 3)
        
        let expected = Int(Double(iterations / 3) * 0.85)
        
        for (_, count) in counts
        {
            XCTAssertGreaterThan(count, expected)
        }
    }
    
    
    
    func testWithRawValueShrinkEmpty()
    {
        XCTAssertEqual(WithRawValue.a.shrink(), [])
        XCTAssertEqual(WithRawValue.b.shrink(), [])
        XCTAssertEqual(WithRawValue.c.shrink(), [])
    }
    
    
    
    // MARK: - WithIndirectCase
    
    func testWithIndirectCaseDeterminism()
    {
        assertArbitraryDeterminism(of: WithIndirectCase.self)
    }
    
    
    
    func testWithIndirectDistribution()
    {
        let iterations  : Int   = 10_000
        var smallCount  : Int   = 0
        var largeCount  : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = WithIndirectCase
                .arbitrary(using: .randomSeed(size: 500))
            
            switch value
            {
                case .small: smallCount += 1
                case .large: largeCount += 1
            }
        }
        
        let expected = Int(Double(iterations / 2) * 0.85)
        
        XCTAssertGreaterThan(smallCount, expected)
        XCTAssertGreaterThan(largeCount, expected)
    }
    
    
    
    func testWithIndirectCaseShrinkMinimal()
    {
        XCTAssertEqual(WithIndirectCase.small(0).shrink(), [])
        XCTAssertEqual(WithIndirectCase.large("", 0).shrink(), [])
    }
    
    
    
    func testWithIndirectCaseShrinkMatchesPropertyShrink()
    {
        let value       : WithIndirectCase      = .large("abc", 10)
        let candidates  : [WithIndirectCase]    = value.shrink()
        var expected    : [WithIndirectCase]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for s in "abc".shrink()
        {
            expected.append(.large(s, 10))
        }
        
        for n in (10 as Int).shrink()
        {
            expected.append(.large("abc", n))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testWithIndirectCaseShrinkPreservesCase()
    {
        let smallCandidates: [WithIndirectCase]
            = WithIndirectCase.small(10).shrink()
        
        XCTAssertFalse(smallCandidates.isEmpty)
        
        for candidate in smallCandidates
        {
            guard case .small = candidate
            else
            {
                XCTFail("Shrink changed the case from .small")
                return
            }
        }
        
        let largeCandidates: [WithIndirectCase]
            = WithIndirectCase.large("abc", 10).shrink()
        
        XCTAssertFalse(largeCandidates.isEmpty)
        
        for candidate in largeCandidates
        {
            guard case .large = candidate
            else
            {
                XCTFail("Shrink changed the case from .large")
                return
            }
        }
    }
    
    
    
    // MARK: - FullIndirect
    
    func testFullIndirectDeterminism()
    {
        assertArbitraryDeterminism(of: FullIndirect.self)
    }
    
    
    
    func testFullIndirectShrinkMatchesPropertyShrink()
    {
        let value       : FullIndirect      = .value(50)
        let candidates  : [FullIndirect]    = value.shrink()
        
        let expected: [FullIndirect] = (50 as Int).shrink().map { .value($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Tree
    
    func testTreeDeterminism()
    {
        assertArbitraryDeterminism(of: Tree.self)
    }
    
    
    
    func testTreeSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Tree.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testTreeTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = Tree.arbitrary(using: .random)
        }
    }
    
    
    
    func testTreeShrinkEmpty()
    {
        XCTAssertEqual(Tree.leaf.shrink(), [])
    }
    
    
    
    func testTreeShrinkStructuralCandidates()
    {
        let left        : Tree      = .node(.leaf, .leaf)
        let right       : Tree      = .leaf
        let value       : Tree      = .node(left, right)
        let candidates  : [Tree]    = value.shrink()
        
        XCTAssertGreaterThanOrEqual(candidates.count, 2)
        XCTAssertEqual(candidates[0], left)
        XCTAssertEqual(candidates[1], right)
    }
    
    
    
    func testTreeShrinkMatchesPropertyShrink()
    {
        let left        : Tree      = .node(.leaf, .leaf)
        let right       : Tree      = .leaf
        let value       : Tree      = .node(left, right)
        let candidates  : [Tree]    = value.shrink()
        var expected    : [Tree]    = []
        
        expected.append(contentsOf: [left, right])
        
        for l in left.shrink()
        {
            expected.append(.node(l, right))
        }
        
        for r in right.shrink()
        {
            expected.append(.node(left, r))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - MutualA
    
    func testMutualADeterminism()
    {
        assertArbitraryDeterminism(of: MutualA.self)
    }
    
    
    
    func testMutualASizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MutualA.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testMutualATerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = MutualA.arbitrary(using: .random)
        }
    }
    
    
    
    func testMutualAShrinkEmpty()
    {
        XCTAssertEqual(MutualA.leaf.shrink(), [])
    }
    
    
    
    func testMutualAShrinkNoCandidates()
    {
        let value = MutualA.mutual(.mutual(.leaf))
        
        XCTAssertTrue(value.shrink().isEmpty)
    }
    
    
    
    func testMutualAShrinkMatchesPropertyShrink()
    {
        let inner       : MutualB       = .mutual(.mutual(.leaf))
        let value       : MutualA       = .mutual(inner)
        let candidates  : [MutualA]     = value.shrink()
        
        let expected: [MutualA] = inner.shrink().map { .mutual($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - MutualB
    
    func testMutualBDeterminism()
    {
        assertArbitraryDeterminism(of: MutualB.self)
    }
    
    
    
    func testMutualBSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MutualB.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testMutualBTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = MutualB.arbitrary(using: .random)
        }
    }
    
    
    
    func testMutualBShrinkEmpty()
    {
        XCTAssertEqual(MutualB.leaf.shrink(), [])
    }
    
    
    
    func testMutualBShrinkPreservesCase()
    {
        let value = MutualB.mutual(.mutual(.leaf))
        
        XCTAssertTrue(value.shrink().isEmpty)
    }
    
    
    
    func testMutualBShrinkMatchesPropertyShrink()
    {
        let inner       : MutualA       = .mutual(.mutual(.leaf))
        let value       : MutualB       = .mutual(inner)
        let candidates  : [MutualB]     = value.shrink()
        
        let expected: [MutualB] = inner.shrink().map { .mutual($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - LinkedList
    
    func testLinkedListDeterminism()
    {
        assertArbitraryDeterminism(of: LinkedList.self)
    }
    
    
    
    func testLinkedListSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = LinkedList.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .end)
        }
    }
    
    
    
    func testLinkedListTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = LinkedList.arbitrary(using: .random)
        }
    }
    
    
    
    func testLinkedListShrinkEmpty()
    {
        XCTAssertEqual(LinkedList.end.shrink(), [])
    }
    
    
    
    func testLinkedListShrinkStructuralCandidates()
    {
        let tail        : LinkedList    = .node(1, .end)
        let value       : LinkedList    = .node(5, tail)
        let candidates  : [LinkedList]  = value.shrink()
        
        /// Only the tail is a structural candidate, not the integer.
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates[0], tail)
    }
    
    
    
    func testLinkedListShrinkMatchesPropertyShrink()
    {
        let tail        : LinkedList    = .node(1, .end)
        let value       : LinkedList    = .node(5, tail)
        let candidates  : [LinkedList]  = value.shrink()
        var expected    : [LinkedList]  = []
        
        /// Structural candidate.
        expected.append(tail)
        
        /// One-at-a-time: shrink the integer head.
        for head in (5 as Int).shrink()
        {
            expected.append(.node(head, tail))
        }
        
        /// One-at-a-time: shrink the tail.
        for t in tail.shrink()
        {
            expected.append(.node(5, t))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testLinkedListShrinkConverges()
    {
        var current : LinkedList    = .node(10, .node(20, .node(30, .end)))
        var steps   : Int           = 0
        
        while let first: LinkedList = current.shrink().first
        {
            current     = first
            steps       += 1
        }
        
        XCTAssertEqual(current, .end)
        XCTAssertGreaterThan(steps, 0)
    }
    
    
    
    // MARK: - RecursiveGeneric
    
    func testRecursiveGenericDeterminism()
    {
        assertArbitraryDeterminism(of: RecursiveGeneric<Int>.self)
    }
    
    
    
    func testRecursiveGenericSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = RecursiveGeneric<Int>.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testRecursiveGenericTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = RecursiveGeneric<Int>.arbitrary(using: .random)
        }
    }
    
    
    
    func testRecursiveGenericShrinkEmpty()
    {
        XCTAssertEqual(RecursiveGeneric<Int>.leaf.shrink(), [])
    }
    
    
    
    func testRecursiveGenericShrinkStructuralCandidates()
    {
        let child       : RecursiveGeneric<Int>     = .node(1, .leaf)
        let value       : RecursiveGeneric<Int>     = .node(5, child)
        let candidates  : [RecursiveGeneric<Int>]   = value.shrink()
        
        /// Only the recursive child is a structural candidate, not the integer.
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates[0], child)
    }
    
    
    
    func testRecursiveGenericShrinkMatchesProperty()
    {
        let child       : RecursiveGeneric<Int>     = .node(1, .leaf)
        let value       : RecursiveGeneric<Int>     = .node(5, child)
        let candidates  : [RecursiveGeneric<Int>]   = value.shrink()
        var expected    : [RecursiveGeneric<Int>]   = []
        
        /// Structural candidate.
        expected.append(child)
        
        /// One-at-a-time: shrink the integer payload.
        for v in (5 as Int).shrink()
        {
            expected.append(.node(v, child))
        }
        
        /// One-at-a-time: shrink the recursive child.
        for c in child.shrink()
        {
            expected.append(.node(5, c))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testRecursiveGenericShrinkConverges()
    {
        var current: RecursiveGeneric<Int>
            = .node(10, .node(20, .node(30, .leaf)))
        
        var steps: Int = 0
        
        while let first: RecursiveGeneric<Int> = current.shrink().first
        {
            current     = first
            steps       += 1
        }
        
        XCTAssertEqual(current, .leaf)
        XCTAssertGreaterThan(steps, 0)
    }
    
    
    
    // MARK: - RecursiveOptional
    
    func testRecursiveOptionalDeterminism()
    {
        assertArbitraryDeterminism(of: RecursiveOptional.self)
    }
    
    
    
    func testRecursiveOptionalSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = RecursiveOptional.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testRecursiveOptionalTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = RecursiveOptional.arbitrary(using: .random)
        }
    }
    
    
    
    func testRecursiveOptionalShrinkEmpty()
    {
        XCTAssertEqual(RecursiveOptional.leaf.shrink(), [])
    }
    
    
    
    func testRecursiveOptionalMinimal()
    {
        /// `.node(nil)` has no structural candidate, since `RecursiveOptional?`
        /// is not the same as `RecursiveOptional`. ``Optional/shrink()``
        /// returns an empty array for `nil`.
        XCTAssertEqual(RecursiveOptional.node(nil).shrink(), [])
    }
    
    
    
    func testRecursiveOptionalNoStructuralCandidates()
    {
        /// The associated value type is `RecursiveOptional?`
        /// (`OptionalTypeSyntax`), not `RecursiveOptional`
        /// (`IdentifierTypeSyntax`). The self-reference check does not match,
        /// so no structural candidates are prepended. Shrinking proceeds
        /// through ``Optional/shrink()``.
        
        let inner       : RecursiveOptional     = .node(.leaf)
        let value       : RecursiveOptional     = .node(inner)
        let candidates  : [RecursiveOptional]   = value.shrink()
        
        let expected: [RecursiveOptional]
            = (inner as Optional<RecursiveOptional>).shrink().map { .node($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - LabeledRecursive
    
    func testLabeledRecursiveDeterminism()
    {
        assertArbitraryDeterminism(of: LabeledRecursive.self)
    }
    
    
    
    func testLabeledRecursiveSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = LabeledRecursive.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value, .leaf)
        }
    }
    
    
    
    func testLabeledRecursiveTerminatesAtVariousSizes()
    {
        for _ in 0..<1000
        {
            _ = LabeledRecursive.arbitrary(using: .random)
        }
    }
    
    
    
    func testLabeledRecursiveShrinkStructuralCandidates()
    {
        let left: LabeledRecursive = .leaf
        
        let right: LabeledRecursive = .node(
            left:   .leaf,
            value:  1,
            right:  .leaf
        )
        
        let value: LabeledRecursive = .node(
            left:   left,
            value:  5,
            right:  right
        )
        
        let candidates: [LabeledRecursive] = value.shrink()
        
        /// Only `left` and `right` are structural candidates, not the integer.
        XCTAssertGreaterThanOrEqual(candidates.count, 2)
        XCTAssertEqual(candidates[0], left)
        XCTAssertEqual(candidates[1], right)
    }
    
    
    
    func testLabeledRecursiveShrinkMatchesPropertyShrink()
    {
        let left: LabeledRecursive = .leaf
        
        let right: LabeledRecursive = .node(
            left:   .leaf,
            value:  1,
            right:  .leaf
        )
        
        let value: LabeledRecursive = .node(
            left:   left,
            value:  5,
            right:  right
        )
        
        let candidates  : [LabeledRecursive]    = value.shrink()
        var expected    : [LabeledRecursive]    = []
        
        /// Structural candidates.
        expected.append(contentsOf: [left, right])
        
        /// One-at-a-time: shrink `left`.
        for l in left.shrink()
        {
            expected.append(.node(left: l, value: 5, right: right))
        }
        
        /// One-at-a-time: shrink `value`.
        for v in (5 as Int).shrink()
        {
            expected.append(.node(left: left, value: v, right: right))
        }
        
        /// One-at-a-time: shrink `right`.
        for r in right.shrink()
        {
            expected.append(.node(left: left, value: 5, right: r))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Integration
    
    func testPropertyRunnerShrinkingIntegration()
    {
        let target: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        let result: PropertyCheckResult<MixedCases> = PropertyRunner.run(
            property:
            {
                (value: MixedCases) in
                
                if
                    case let .value(id) = value,
                    id > target
                {
                    throw TestError()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        guard case let .value(id) = counterexample.value
        else
        {
            XCTFail("Expected .value, got \(counterexample.value)")
            return
        }
        
        XCTAssertEqual(id, target + 1)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testPropertyRunnerRecursiveShrinkingIntegration()
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        let result: PropertyCheckResult<LinkedList> = PropertyRunner.run(
            property:
            {
                (value: LinkedList) in
                
                /// Fails for any list with more than one element.
                switch value
                {
                    case .end               : break
                    case .node(_, .end)     : break
                    case .node(_, .node)    : throw TestError()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        /// Shrinking must converge to the smallest two-element list through
        /// structural shrinking.
        switch counterexample.value
        {
            case let .node(head, .node(tail, .end)):
                
                XCTAssertEqual(head, 0)
                XCTAssertEqual(tail, 0)
                
            default:
                
                XCTFail(
                    "Expected .node(head, .node(tail, .end)),"
                    + " got \(counterexample.value)"
                )
                
                return
        }
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testXCTKForAllIntegration()
    {
        XCTKForAll(options: .propertyOptions(iterations: 50))
        {
            (value: MixedCases) in
            
            let candidates: [MixedCases] = value.shrink()
            
            for candidate in candidates
            {
                switch (value, candidate)
                {
                    case (.none, _):
                        
                        XCTFail("Expected .none to not shrink")
                        return
                        
                    case
                        (.value, .value),
                        (.pair, .pair):
                        
                        break
                        
                    default:
                        
                        XCTFail("Shrink changed the case")
                        return
                }
            }
        }
    }
}



// MARK: - Support

@Arbitrary
private enum SingleNoValues: Equatable
{
    case only
}



@Arbitrary
private enum MultipleNoValues: Equatable, Hashable
{
    case a
    case b
    case c
}



@Arbitrary
private enum SingleLabeled: Equatable
{
    case value(id: Int)
}



@Arbitrary
private enum SingleUnlabeled: Equatable
{
    case value(Int)
}



@Arbitrary
private enum MultipleLabeled: Equatable
{
    case circle(r: Int)
    case rect(w: Int, h: Int)
}



@Arbitrary
private enum MixedCases: Equatable
{
    case none
    case value(id: Int)
    case pair(x: Int, y: String)
}



@Arbitrary
private enum UnlabeledMultiple: Equatable
{
    case pair(Int, String)
}



@Arbitrary
private enum MixedLabels: Equatable
{
    case value(name: String, Int)
}



@Arbitrary
private enum Generics<A, B>: Equatable where A : Equatable, B : Equatable
{
    case a(A)
    case b(B)
    case none
}



private enum Phantom
{
    
}



@Arbitrary
private enum PhantomGeneric<T>: Equatable
{
    case value(Int)
    case empty
}



private struct Outer
{
    @Arbitrary
    enum Inner: Equatable
    {
        case value(Int)
        case empty
    }
}



private struct DeepOuter
{
    struct Middle
    {
        @Arbitrary
        enum Deep: Equatable
        {
            case value(Int)
            case empty
        }
    }
}



@Arbitrary
private enum Wildcard: Equatable
{
    case value(_ x: Int)
}



@Arbitrary
private enum Many: Equatable, CustomStringConvertible
{
    case a
    case b(Int)
    case c(x: Int, y: String)
    case d(String, Int)
    case e(name: String, Int, Character)
    
    var description: String
    {
        switch self
        {
            case .a: return "a"
            case .b: return "b"
            case .c: return "c"
            case .d: return "d"
            case .e: return "e"
        }
    }
}



@Arbitrary
private enum MultipleCaseDecl: Equatable
{
    case a, b, c(Int)
}



@Arbitrary
private enum NestedComposition: Equatable
{
    case labeled(shape: MultipleLabeled)
    case pair(MixedCases, SingleLabeled)
    case empty
}



@Arbitrary
private enum OptionalAssociated: Equatable
{
    case value(Int?)
    case empty
}



@Arbitrary
private enum CollectionAssociated: Equatable
{
    case items([Int])
    case map([String : Int])
    case empty
}



private struct ExplicitAccessOuter
{
    @Arbitrary
    internal enum Inner: Equatable
    {
        case value(Int)
        case empty
    }
}



private enum Nested
{
    @Arbitrary
    enum Inner: Equatable
    {
        case value(Int)
        case empty
    }
}



@Arbitrary
private enum WithRawValue: Int, Equatable, Hashable
{
    case a  = 1
    case b  = 2
    case c  = 3
}



@Arbitrary
private enum WithIndirectCase: Equatable
{
    case small(Int)
    indirect case large(String, Int)
}



@Arbitrary
private indirect enum FullIndirect: Equatable
{
    case value(Int)
    case empty
}



@Arbitrary
private indirect enum Tree: Equatable
{
    case leaf
    case node(Tree, Tree)
}



@Arbitrary
private indirect enum MutualA: Equatable
{
    case leaf
    case mutual(MutualB)
}



@Arbitrary
private indirect enum MutualB: Equatable
{
    case leaf
    case mutual(MutualA)
}



@Arbitrary
private indirect enum LinkedList: Equatable
{
    case end
    case node(Int, LinkedList)
}



@Arbitrary
private indirect enum RecursiveGeneric<T>: Equatable where T : Equatable
{
    case leaf
    case node(T, RecursiveGeneric<T>)
}



@Arbitrary
private indirect enum RecursiveOptional: Equatable
{
    case leaf
    case node(RecursiveOptional?)
}



@Arbitrary
private indirect enum LabeledRecursive: Equatable
{
    case leaf
    
    case node(
        left    : LabeledRecursive,
        value   : Int,
        right   : LabeledRecursive
    )
}
