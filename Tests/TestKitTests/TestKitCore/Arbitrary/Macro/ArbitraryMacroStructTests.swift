//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class ArbitraryMacroStructTests: XCTestCaseStopOnFail
{
    // MARK: - Empty
    
    func testEmptyDeterminism()
    {
        assertArbitraryDeterminism(of: Empty.self)
    }
    
    
    
    func testEmptyShrinking()
    {
        XCTAssertEqual(Empty().shrink(), [])
    }
    
    
    
    func testEmptyGeneratesDefaultStruct()
    {
        let value = Empty.arbitrary(using: .random)
        
        XCTAssertEqual(value, Empty())
    }
    
    
    
    // MARK: - SingleLet
    
    func testSingleLetDeterminism()
    {
        assertArbitraryDeterminism(of: SingleLet.self)
    }
    
    
    
    func testSingleLetSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = SingleLet.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.id, 0)
        }
    }
    
    
    
    func testSingleLetSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = SingleLet.arbitrary(using: .randomSeed(size: size))
            
            XCTAssertGreaterThanOrEqual(value.id, -size)
            XCTAssertLessThanOrEqual(value.id, size)
        }
    }
    
    
    
    func testSingleLetShrinkMinimal()
    {
        XCTAssertEqual(SingleLet(id: 0).shrink(), [])
    }
    
    
    
    func testSingleLetShrinkMatchesPropertyShrink()
    {
        let value       : SingleLet     = .init(id: 50)
        let candidates  : [SingleLet]   = value.shrink()
        
        let expected: [SingleLet]
            = (50 as Int).shrink().map { SingleLet(id: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testSingleLetShrink()
    {
        let value       : SingleLet     = .init(id: 10)
        let candidates  : [SingleLet]   = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.id, 0)
            XCTAssertLessThan(candidate.id, 10)
        }
    }
    
    
    
    // MARK: - SingleVar
    
    func testSingleVarDeterminism()
    {
        assertArbitraryDeterminism(of: SingleVar.self)
    }
    
    
    
    func testSingleVarSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = SingleVar.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.id, 0)
        }
    }
    
    
    
    func testSingleVarSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = SingleVar.arbitrary(using: .randomSeed(size: size))
            
            XCTAssertGreaterThanOrEqual(value.id, -size)
            XCTAssertLessThanOrEqual(value.id, size)
        }
    }
    
    
    
    func testSingleVarShrinkMinimal()
    {
        XCTAssertEqual(SingleVar(id: 0).shrink(), [])
    }
    
    
    
    func testSingleVarShrinkMatchesPropertyShrink()
    {
        let value       : SingleVar     = .init(id: 50)
        let candidates  : [SingleVar]   = value.shrink()
        
        let expected: [SingleVar]
            = (50 as Int).shrink().map { SingleVar(id: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testSingleVarShrink()
    {
        let value       : SingleVar     = .init(id: 10)
        let candidates  : [SingleVar]   = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.id, 0)
            XCTAssertLessThan(candidate.id, 10)
        }
    }
    
    
    
    // MARK: - Multiple
    
    func testMultipleDeterminism()
    {
        assertArbitraryDeterminism(of: Multiple.self)
    }
    
    
    
    func testMultipleSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Multiple.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.name, "")
            XCTAssertEqual(value.id, 0)
        }
    }
    
    
    
    func testMultipleShrinkMinimal()
    {
        XCTAssertEqual(Multiple(name: "", id: 0, char: "a").shrink(), [])
    }
    
    
    
    func testMultipleShrinkMatchesPropertyShrink()
    {
        let value       : Multiple      = .init(name: "abc", id: 7, char: "z")
        let candidates  : [Multiple]    = value.shrink()
        var expected    : [Multiple]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for name in "abc".shrink()
        {
            expected.append(Multiple(name: name, id: 7, char: "z"))
        }
        
        for id in (7 as Int).shrink()
        {
            expected.append(Multiple(name: "abc", id: id, char: "z"))
        }
        
        for char in ("z" as Character).shrink()
        {
            expected.append(Multiple(name: "abc", id: 7, char: char))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testMultipleShrinkPreservesOtherProperties()
    {
        let value       : Multiple      = .init(name: "abc", id: 7, char: "x")
        let candidates  : [Multiple]    = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            var changed: Int = 0
            
            if candidate.name != value.name
            {
                changed += 1
            }
            
            if candidate.id != value.id
            {
                changed += 1
            }
            
            if candidate.char != value.char
            {
                changed += 1
            }
            
            XCTAssertEqual(changed, 1)
        }
    }
    
    
    
    // MARK: - LetDefault
    
    func testLetDefaultDeterminism()
    {
        assertArbitraryDeterminism(of: LetDefault.self)
    }
    
    
    
    func testLetDefaultValueNotChanged()
    {
        for _ in 0..<1000
        {
            let value = LetDefault.arbitrary(using: .random)
            
            guard value.y == "abc"
            else
            {
                XCTFail("Immutable default value changed")
                return
            }
        }
    }
    
    
    
    func testLetDefaultSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = LetDefault.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "abc")
        }
    }
    
    
    
    func testLetDefaultSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = LetDefault.arbitrary(using: .randomSeed(size: size))
            
            XCTAssertGreaterThanOrEqual(value.x, -size)
            XCTAssertLessThanOrEqual(value.x, size)
            XCTAssertEqual(value.y, "abc")
        }
    }
    
    
    
    func testLetDefaultShrinkOnlyShrinksX()
    {
        let value       : LetDefault    = .init(x: 10)
        let candidates  : [LetDefault]  = value.shrink()
        
        let expected: [LetDefault]
            = (10 as Int).shrink().map { LetDefault(x: $0) }
        
        XCTAssertEqual(candidates, expected)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.y, "abc")
        }
    }
    
    
    
    func testLetDefaultShrinkMinimal()
    {
        XCTAssertEqual(LetDefault(x: 0).shrink(), [])
    }
    
    
    
    // MARK: - VarDefault
    
    func testVarDefaultDeterminism()
    {
        assertArbitraryDeterminism(of: VarDefault.self)
    }
    
    
    
    func testVarDefaultValueChanged()
    {
        var yValues     : Set<String>   = []
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            let value = VarDefault.arbitrary(using: .randomSeed(size: 200))
            
            yValues.insert(value.y)
        }
        
        XCTAssertGreaterThan(yValues.count, Int(Double(iterations) * 0.95))
    }
    
    
    
    func testVarDefaultSizeZeroProducesMinimal()
    {
        for _ in 0..<1000
        {
            let value = VarDefault.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testVarDefaultShrinkMatchesPropertyShrink()
    {
        let value       : VarDefault    = .init(x: 10, y: "abc")
        let candidates  : [VarDefault]  = value.shrink()
        var expected    : [VarDefault]  = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(VarDefault(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(VarDefault(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testVarDefaultShrinkMinimal()
    {
        XCTAssertEqual(VarDefault(x: 0, y: "").shrink(), [])
    }
    
    
    
    // MARK: - AllLetDefaults
    
    func testAllLetDefaultsDeterminism()
    {
        assertArbitraryDeterminism(of: AllLetDefaults.self)
    }
    
    
    
    func testAllLetDefaultsGeneratesFixedValues()
    {
        for _ in 0..<1000
        {
            let value = AllLetDefaults.arbitrary(using: .random)
            
            XCTAssertEqual(value.x, 100)
            XCTAssertEqual(value.y, "abc")
        }
    }
    
    
    
    func testAllLetDefaultsShrinkMinimal()
    {
        XCTAssertEqual(AllLetDefaults().shrink(), [])
    }
    
    
    
    // MARK: - AllVarDefaults
    
    func testAllVarDefaultsDeterminism()
    {
        assertArbitraryDeterminism(of: AllVarDefaults.self)
    }
    
    
    
    func testAllVarDefaultsGeneratesFixedValues()
    {
        for _ in 0..<1000
        {
            let value = AllVarDefaults.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testAllVarDefaultsShrinkMinimal()
    {
        XCTAssertEqual(AllVarDefaults(x: 0, y: "").shrink(), [])
    }
    
    
    
    func testAllVarDefaultsShrinkMatchesPropertyShrink()
    {
        let value       : AllVarDefaults    = .init(x: 10, y: "abc")
        let candidates  : [AllVarDefaults]  = value.shrink()
        var expected    : [AllVarDefaults]  = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(AllVarDefaults(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(AllVarDefaults(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - GenericPair
    
    func testGenericPairDeterminism()
    {
        assertArbitraryDeterminism(of: GenericPair<Int, String>.self)
    }
    
    
    
    func testGenericPairSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = GenericPair<Int, String>
                .arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.a, 0)
            XCTAssertEqual(value.b, "")
        }
    }
    
    
    
    func testGenericPairShrinkMinimal()
    {
        XCTAssertEqual(GenericPair(a: 0, b: "").shrink(), [])
    }
    
    
    
    func testGenericPairShrinkMatchesPropertyShrink()
    {
        let value       : GenericPair       = .init(a: 10, b: "abc")
        let candidates  : [GenericPair]     = value.shrink()
        
        var expected: [GenericPair<Int, String>] = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for a in (10 as Int).shrink()
        {
            expected.append(GenericPair(a: a, b: "abc"))
        }
        
        for b in "abc".shrink()
        {
            expected.append(GenericPair(a: 10, b: b))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Computed
    
    func testComputedDeterminism()
    {
        assertArbitraryDeterminism(of: Computed.self)
    }
    
    
    
    func testComputedSkipsComputedProperty()
    {
        for _ in 0..<1000
        {
            let value = Computed.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, 0)
        }
    }
    
    
    
    func testComputedShrinkMatchesPropertyShrink()
    {
        let value       : Computed      = .init(x: 10)
        let candidates  : [Computed]    = value.shrink()
        
        let expected: [Computed] = (10 as Int).shrink().map { Computed(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - ComputedGetSet
    
    func testComputedGetSetDeterminism()
    {
        assertArbitraryDeterminism(of: ComputedGetSet.self)
    }
    
    
    
    func testComputedGetSetSkipsComputedProperty()
    {
        for _ in 0..<1000
        {
            let value = ComputedGetSet.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, 0)
        }
    }
    
    
    
    func testComputedGetSetShrinkMatchesPropertyShrink()
    {
        let value       : ComputedGetSet    = .init(x: 10)
        let candidates  : [ComputedGetSet]  = value.shrink()
        
        let expected: [ComputedGetSet]
            = (10 as Int).shrink().map { ComputedGetSet(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Static
    
    func testStaticDeterminism()
    {
        assertArbitraryDeterminism(of: Static.self)
    }
    
    
    
    func testStaticSkipsStaticProperty()
    {
        for _ in 0..<1000
        {
            let value = Static.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
        }
    }
    
    
    
    func testStaticShrinkMatchesPropertyShrink()
    {
        let value       : Static    = .init(x: 10)
        let candidates  : [Static]  = value.shrink()
        
        let expected: [Static] = (10 as Int).shrink().map { Static(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Lazy
    
    func testLazyDeterminism()
    {
        assertArbitraryDeterminism(of: Lazy.self)
    }
    
    
    
    func testLazySkipsLazyProperty()
    {
        for _ in 0..<1000
        {
            let value = Lazy.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
        }
    }
    
    
    
    func testLazyShrinkMatchesPropertyShrink()
    {
        let value       : Lazy      = .init(x: 10)
        let candidates  : [Lazy]    = value.shrink()
        
        let expected: [Lazy] = (10 as Int).shrink().map { Lazy(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Observer
    
    func testObserverDeterminism()
    {
        assertArbitraryDeterminism(of: Observer.self)
    }
    
    
    
    func testObserverSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Observer.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, 0)
        }
    }
    
    
    
    func testObserverShrinkMinimal()
    {
        XCTAssertEqual(Observer(x: 0, y: 0).shrink(), [])
    }
    
    
    
    func testObserverShrinkMatchesPropertyShrink()
    {
        let value       : Observer      = .init(x: 10, y: 5)
        let candidates  : [Observer]    = value.shrink()
        var expected    : [Observer]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(Observer(x: x, y: 5))
        }
        
        for y in (5 as Int).shrink()
        {
            expected.append(Observer(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Nested
    
    func testNestedDeterminism()
    {
        assertArbitraryDeterminism(of: Nested.self)
    }
    
    
    
    func testNestedSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Nested.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.pair.a, 0)
            XCTAssertEqual(value.pair.b, "")
            XCTAssertEqual(value.single.id, 0)
            XCTAssertEqual(value.inner.id, 0)
        }
    }
    
    
    
    func testNestedShrinkMinimal()
    {
        let value = Nested(
            pair:       GenericPair(a: 0, b: ""),
            single:     SingleLet(id: 0),
            inner:      Nested.Inner(id: 0)
        )
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testNestedShrinkMatchesPropertyShrink()
    {
        let value = Nested(
            pair:       GenericPair(a: 10, b: "abc"),
            single:     SingleLet(id: 5),
            inner:      Nested.Inner(id: 7)
        )
        
        let candidates  : [Nested]    = value.shrink()
        var expected    : [Nested]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for pair in value.pair.shrink()
        {
            expected.append(Nested(
                pair:       pair,
                single:     SingleLet(id: 5),
                inner:      Nested.Inner(id: 7)
            ))
        }
        
        for single in value.single.shrink()
        {
            expected.append(Nested(
                pair:       GenericPair(a: 10, b: "abc"),
                single:     single,
                inner:      Nested.Inner(id: 7)
            ))
        }
        
        for inner in value.inner.shrink()
        {
            expected.append(Nested(
                pair:       GenericPair(a: 10, b: "abc"),
                single:     SingleLet(id: 5),
                inner:      inner
            ))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - GenericCollection
    
    func testGenericCollectionDeterminism()
    {
        assertArbitraryDeterminism(of: GenericCollection<Int>.self)
    }
    
    
    
    func testGenericCollectionSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = GenericCollection<Int>
                .arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.items, [])
        }
    }
    
    
    
    func testGenericCollectionShrinkMinimal()
    {
        XCTAssertEqual(GenericCollection(items: [Int]()).shrink(), [])
    }
    
    
    
    func testGenericCollectionShrinkMatchesPropertyShrink()
    {
        let value       : GenericCollection<Int>    = .init(items: [10, 20])
        let candidates  : [GenericCollection<Int>]  = value.shrink()
        
        let expected: [GenericCollection<Int>]
            = [10, 20].shrink().map { GenericCollection(items: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - GenericOptional
    
    func testGenericOptionalDeterminism()
    {
        assertArbitraryDeterminism(of: GenericOptional<Int>.self)
    }
    
    
    
    func testGenericOptionalShrinkMinimal()
    {
        XCTAssertEqual(GenericOptional<Int>(id: nil).shrink(), [])
    }
    
    
    
    // MARK: - GenericDictionary
    
    func testGenericDictionaryDeterminism()
    {
        assertArbitraryDeterminism(of: GenericDictionary<String, Int>.self)
    }
    
    
    
    func testGenericDictionarySizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = GenericDictionary<String, Int>
                .arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.map, [:])
        }
    }
    
    
    
    func testGenericDictionaryShrinkMinimal()
    {
        XCTAssertEqual(GenericDictionary<String, Int>(map: [:]).shrink(), [])
    }
    
    
    
    // MARK: - Tagged
    
    func testTaggedDeterminism()
    {
        assertArbitraryDeterminism(of: Tagged<PhantomTag, Int>.self)
    }
    
    
    
    func testTaggedSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = Tagged<PhantomTag, Int>
                .arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.id, 0)
        }
    }
    
    
    
    func testTaggedShrinkMinimal()
    {
        XCTAssertEqual(Tagged<PhantomTag, Int>(id: 0).shrink(), [])
    }
    
    
    
    func testTaggedMatchesPropertyShrink()
    {
        let value       : Tagged<PhantomTag, Int>       = .init(id: 50)
        let candidates  : [Tagged<PhantomTag, Int>]     = value.shrink()
        
        let expected: [Tagged<PhantomTag, Int>]
            = (50 as Int).shrink().map { Tagged(id: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - OptionalProperty
    
    func testOptionalPropertyDeterminism()
    {
        assertArbitraryDeterminism(of: OptionalProperty.self)
    }
    
    
    
    func testOptionalPropertySizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = OptionalProperty.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testOptionalPropertyShrinkMinimal()
    {
        XCTAssertEqual(OptionalProperty(x: nil, y: "").shrink(), [])
    }
    
    
    
    func testOptionalPropertyMatchesPropertyShrink()
    {
        let value       : OptionalProperty      = .init(x: 10, y: "abc")
        let candidates  : [OptionalProperty]    = value.shrink()
        var expected    : [OptionalProperty]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Optional<Int>).shrink()
        {
            expected.append(OptionalProperty(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(OptionalProperty(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - CollectionProperty
    
    func testCollectionPropertyDeterminism()
    {
        assertArbitraryDeterminism(of: CollectionProperty.self)
    }
    
    
    
    func testCollectionPropetySizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = CollectionProperty.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.items, [])
            XCTAssertEqual(value.map, [:])
        }
    }
    
    
    
    func testCollectionPropertyShrinkMinimal()
    {
        XCTAssertEqual(CollectionProperty(items: [], map: [:]).shrink(), [])
    }
    
    
    
    // MARK: - AccessModified
    
    func testAccessModifiedDeterminism()
    {
        assertArbitraryDeterminism(of: AccessModified.self)
    }
    
    
    
    func testAccessModifiedSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = AccessModified.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testAccessModifiedShrinkMinimal()
    {
        XCTAssertEqual(AccessModified(x: 0, y: "").shrink(), [])
    }
    
    
    
    func testAccessModifiedMatchesPropertyShrink()
    {
        let value       : AccessModified    = .init(x: 10, y: "abc")
        let candidates  : [AccessModified]  = value.shrink()
        var expected    : [AccessModified]  = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(AccessModified(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(AccessModified(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - PrivateSet
    
    func testPrivateSetDeterminism()
    {
        assertArbitraryDeterminism(of: PrivateSet.self)
    }
    
    
    
    func testPrivateSetSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = PrivateSet.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testPrivateSetShrinkMinimal()
    {
        XCTAssertEqual(PrivateSet(x: 0, y: "").shrink(), [])
    }
    
    
    
    func testPrivateSetMatchesPropertyShrink()
    {
        let value       : PrivateSet    = .init(x: 10, y: "abc")
        let candidates  : [PrivateSet]  = value.shrink()
        var expected    : [PrivateSet]  = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(PrivateSet(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(PrivateSet(x: 10, y: y))
        }
        
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
            
            XCTAssertEqual(value.x, 0)
        }
    }
    
    
    
    func testExplicitAccessOuterMatchesPropertyShrink()
    {
        let value       : ExplicitAccessOuter.Inner     = .init(x: 10)
        let candidates  : [ExplicitAccessOuter.Inner]   = value.shrink()
        
        let expected: [ExplicitAccessOuter.Inner]
            = (10 as Int).shrink().map { ExplicitAccessOuter.Inner(x: $0) }
        
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
            
            XCTAssertEqual(value.x, 0)
        }
    }
    
    
    
    func testDeepOuterMatchesPropertyShrink()
    {
        let value       : DeepOuter.Middle.Deep     = .init(x: 10)
        let candidates  : [DeepOuter.Middle.Deep]   = value.shrink()
        
        let expected: [DeepOuter.Middle.Deep]
            = (10 as Int).shrink().map { DeepOuter.Middle.Deep(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - MultiBinding
    
    func testMultiBindingDeterminism()
    {
        assertArbitraryDeterminism(of: MultiBinding.self)
    }
    
    
    
    func testMultiBindingSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MultiBinding.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.y, "")
        }
    }
    
    
    
    func testMultiBindingShrinkMinimal()
    {
        XCTAssertEqual(MultiBinding(x: 0, y: "").shrink(), [])
    }
    
    
    
    func testMultiBindingMatchesPropertyShrink()
    {
        let value       : MultiBinding      = .init(x: 10, y: "abc")
        let candidates  : [MultiBinding]    = value.shrink()
        var expected    : [MultiBinding]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(MultiBinding(x: x, y: "abc"))
        }
        
        for y in "abc".shrink()
        {
            expected.append(MultiBinding(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - MixedDefaults
    
    func testMixedDefaultsDeterminism()
    {
        assertArbitraryDeterminism(of: MixedDefaults.self)
    }
    
    
    
    func testMixedDefaultsLetDefaultsPreserved()
    {
        for _ in 0..<1000
        {
            let value = MixedDefaults.arbitrary(using: .random)
            
            XCTAssertEqual(value.a, 100)
            XCTAssertEqual(value.b, "abc")
        }
    }
    
    
    
    func testMixedDefaultsSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MixedDefaults.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.a, 100)
            XCTAssertEqual(value.b, "abc")
            XCTAssertEqual(value.c, 0)
        }
    }
    
    
    
    func testMixedDefaultsShrinkMinimal()
    {
        XCTAssertEqual(MixedDefaults(c: 0).shrink(), [])
    }
    
    
    
    func testMixedDefaultsShrinkOnlyShrinksC()
    {
        let value       : MixedDefaults     = .init(c: 10)
        let candidates  : [MixedDefaults]   = value.shrink()
        
        let expected: [MixedDefaults]
            = (10 as Int).shrink().map { MixedDefaults(c: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - TupleDefault
    
    func testTupleDefaultDeterminism()
    {
        assertArbitraryDeterminism(of: TupleDefault.self)
    }
    
    
    
    func testTupleDefaultSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = TupleDefault.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.pair.0, 0)
            XCTAssertEqual(value.pair.1, "")
        }
    }
    
    
    
    func testTupleDefaultShrinkMinimal()
    {
        XCTAssertEqual(TupleDefault(x: 0).shrink(), [])
    }
    
    
    
    func testTupleDefaultShrinkOnlyShrinksC()
    {
        let value       : TupleDefault      = .init(x: 10)
        let candidates  : [TupleDefault]    = value.shrink()
        
        let expected: [TupleDefault]
            = (10 as Int).shrink().map { TupleDefault(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - ClosureDefault
    
    func testClosureDefaultDeterminism()
    {
        assertArbitraryDeterminism(of: ClosureDefault.self)
    }
    
    
    
    func testClosureDefaultSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = ClosureDefault.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(value.x, 0)
            XCTAssertEqual(value.action(10), "10")
        }
    }
    
    
    
    func testClosureDefaultShrinkMinimal()
    {
        XCTAssertEqual(ClosureDefault(x: 0).shrink(), [])
    }
    
    
    
    func testClosureDefaultShrinkOnlyShrinksC()
    {
        let value       : ClosureDefault    = .init(x: 10)
        let candidates  : [ClosureDefault]  = value.shrink()
        
        let expected: [ClosureDefault]
            = (10 as Int).shrink().map { ClosureDefault(x: $0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - Integration
    
    func testPropertyRunnerShrinkingIntegration()
    {
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        let result: PropertyCheckResult<Multiple> = PropertyRunner.run(
            property:
            {
                (value: Multiple) in
                
                if value.name.count >= target
                {
                    throw TestError()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.name.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testXCTKForAllIntegration()
    {
        XCTKForAll(options: .propertyOptions(iterations: 50))
        {
            (value: Multiple) in
            
            let candidates: [Multiple] = value.shrink()
            
            for candidate in candidates
            {
                var changed: Int = 0
                
                if candidate.name != value.name
                {
                    changed += 1
                }
                
                if candidate.id != value.id
                {
                    changed += 1
                }
                
                if candidate.char != value.char
                {
                    changed += 1
                }
                
                XCTAssertEqual(changed, 1)
            }
        }
    }
}



// MARK: - Support

@Arbitrary
private struct Empty: Equatable
{
    
}



@Arbitrary
private struct SingleLet: Equatable
{
    let id: Int
}



@Arbitrary
private struct SingleVar: Equatable
{
    var id: Int
}



@Arbitrary
private struct Multiple: Equatable
{
    let name    : String
    var id      : Int
    let char    : Character
}



@Arbitrary
private struct LetDefault: Equatable
{
    let x   : Int
    let y   : String    = "abc"
}



@Arbitrary
private struct VarDefault: Equatable
{
    let x   : Int
    var y   : String    = "abc"
}



@Arbitrary
private struct AllLetDefaults: Equatable
{
    let x   : Int       = 100
    let y   : String    = "abc"
}



@Arbitrary
private struct AllVarDefaults: Equatable
{
    var x   : Int       = 100
    var y   : String    = "abc"
}



@Arbitrary
private struct GenericPair<A, B>: Equatable where A : Equatable, B : Equatable
{
    let a   : A
    let b   : B
}



@Arbitrary
private struct Computed: Equatable
{
    let x: Int
    
    var y: Int
    {
        return x * 2
    }
}



@Arbitrary
private struct ComputedGetSet: Equatable
{
    let x: Int
    
    var y: Int
    {
        get { return x * 2 }
        set { }
    }
}



@Arbitrary
private struct Static: Equatable
{
    let x           : Int
    static let y    : Int   = 10
}



@Arbitrary
private struct Lazy: Equatable
{
    let x       : Int
    lazy var y  : String    = "abc"
}



@Arbitrary
private struct Observer: Equatable
{
    var x: Int
    
    var y: Int = 0
    {
        didSet      { }
        willSet     { }
    }
}



@Arbitrary
private struct Nested: Equatable
{
    let pair    : GenericPair<Int, String>
    let single  : SingleLet
    let inner   : Inner
    
    @Arbitrary
    struct Inner: Equatable
    {
        let id: Int
    }
}



@Arbitrary
private struct GenericCollection<T>: Equatable where T : Equatable
{
    let items: [T]
}



@Arbitrary
private struct GenericOptional<T>: Equatable where T : Equatable
{
    let id: T?
}



@Arbitrary
private struct GenericDictionary<K, V>: Equatable
    where K : Hashable & Equatable, V : Equatable
{
    let map: [K : V]
}



private enum PhantomTag
{
    
}



@Arbitrary
private struct Tagged<T, V>: Equatable where V : Equatable
{
    let id: V
}



@Arbitrary
private struct OptionalProperty: Equatable
{
    let x   : Int?
    let y   : String
}



@Arbitrary
private struct CollectionProperty: Equatable
{
    let items   : [Int]
    let map     : [String : Int]
}



@Arbitrary
private struct AccessModified: Equatable
{
    fileprivate let x   : Int
    fileprivate var y   : String
}



@Arbitrary
private struct PrivateSet: Equatable
{
    private(set) var x  : Int
    let y               : String
}



private struct ExplicitAccessOuter
{
    @Arbitrary
    internal struct Inner: Equatable
    {
        let x: Int
    }
}



private struct DeepOuter
{
    struct Middle
    {
        @Arbitrary
        struct Deep: Equatable
        {
            let x: Int
        }
    }
}



@Arbitrary
private struct MultiBinding: Equatable
{
    var x: Int = 0, y: String = "abc"
}



@Arbitrary
private struct MixedDefaults: Equatable
{
    let a   : Int       = 100
    let b   : String    = "abc"
    var c   : Int
}



@Arbitrary
private struct TupleDefault: Equatable
{
    let x       : Int
    let pair    : (Int, String)     = (0, "")
    
    static func == (
        lhs : TupleDefault,
        rhs : TupleDefault
    ) -> Bool
    {
        return lhs.x == rhs.x
            && lhs.pair.0 == lhs.pair.0
            && lhs.pair.1 == lhs.pair.1
    }
}



@Arbitrary
private struct ClosureDefault: Equatable
{
    let x       : Int
    let action  : (Int) -> String   = { String($0) }
    
    static func == (
        lhs : ClosureDefault,
        rhs : ClosureDefault
    ) -> Bool
    {
        return lhs.x == rhs.x
            && lhs.action(lhs.x) == rhs.action(rhs.x)
    }
}
