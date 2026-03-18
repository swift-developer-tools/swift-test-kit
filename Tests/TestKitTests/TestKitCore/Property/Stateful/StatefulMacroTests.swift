//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTestKit
import XCTest



/// The ``Stateful()`` macro shares generation and shrinking logic with the
/// ``Arbitrary()`` macro. Most of that logic is already tested in the latter's
/// test suite.
internal final class StatefulMacroTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - SimpleCommand
    
    func testSimpleCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     SimpleCommand.self,
            model:  0
        )
    }
    
    
    
    func testSimpleCommandDistribution()
    {
        let iterations  : Int                       = 10_000
        var counts      : [SimpleCommand : Int]     = [:]
        
        for _ in 0..<iterations
        {
            let value = SimpleCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            counts[value, default: 0] += 1
        }
        
        XCTAssertEqual(counts.count, SimpleCommand.allCases.count)
        
        for (_, count) in counts
        {
            XCTAssertGreaterThan(count, Int(Double(iterations / 3) * 0.85))
        }
    }
    
    
    
    func testSimpleCommandShrinkEmpty()
    {
        XCTAssertEqual(SimpleCommand.increment.shrink(), [])
        XCTAssertEqual(SimpleCommand.decrement.shrink(), [])
        XCTAssertEqual(SimpleCommand.reset.shrink(), [])
    }
    
    
    
    // MARK: - ValueCommand
    
    func testValueCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     ValueCommand.self,
            model:  0
        )
    }
    
    
    
    func testValueCommandDistribution()
    {
        let iterations  : Int   = 10_000
        var resetCount  : Int   = 0
        var addCount    : Int   = 0
        var setCount    : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = ValueCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            switch value
            {
                case .reset : resetCount    += 1
                case .add   : addCount      += 1
                case .set   : setCount      += 1
            }
        }
        
        let expected = Int(Double(iterations / 3) * 0.85)
        
        XCTAssertGreaterThan(resetCount, expected)
        XCTAssertGreaterThan(addCount, expected)
        XCTAssertGreaterThan(setCount, expected)
    }
    
    
    
    func testValueCommandSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = ValueCommand.arbitrary(
                using:  .randomZeroSize,
                model:  0
            )
            
            guard case .reset = value
            else
            {
                XCTFail("Expected .reset, got \(value)")
                return
            }
        }
    }
    
    
    
    func testValueCommandShrinkEmpty()
    {
        XCTAssertEqual(ValueCommand.reset.shrink(), [])
    }
    
    
    
    func testValueCommandShrinkMinimal()
    {
        XCTAssertEqual(ValueCommand.add(amount: 0).shrink(), [])
        XCTAssertEqual(ValueCommand.set(x: 0, y: 0).shrink(), [])
    }
    
    
    
    func testValueCommandShrinkMatchesPropertyShrink()
    {
        let value       : ValueCommand      = .set(x: 10, y: 5)
        let candidates  : [ValueCommand]    = value.shrink()
        var expected    : [ValueCommand]    = []
        
        XCTAssertFalse(candidates.isEmpty)
        
        for x in (10 as Int).shrink()
        {
            expected.append(.set(x: x, y: 5))
        }
        
        for y in (5 as Int).shrink()
        {
            expected.append(.set(x: 10, y: y))
        }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testValueCommandShrinkPreservesCase()
    {
        let addCandidates: [ValueCommand]
            = ValueCommand.add(amount: 10).shrink()
        
        XCTAssertFalse(addCandidates.isEmpty)
        
        for candidate in addCandidates
        {
            guard case .add = candidate
            else
            {
                XCTFail("Expected .add, got \(candidate)")
                return
            }
        }
        
        let setCandidates: [ValueCommand]
            = ValueCommand.set(x: 10, y: 5).shrink()
        
        XCTAssertFalse(setCandidates.isEmpty)
        
        for candidate in setCandidates
        {
            guard case .set = candidate
            else
            {
                XCTFail("Expected .set, got \(candidate)")
                return
            }
        }
    }
    
    
    
    func testModelParameterDeterminism()
    {
        /// The macro generates ``Stateful/arbitrary(using:model:)``, but does
        /// not use the model in the method body, so the same model must have
        /// deterministic results.
        
        var countsA : [String : Int]    = [:]
        var countsB : [String : Int]    = [:]
        
        for _ in 0..<5000
        {
            let seed: UInt64 = .random(in: UInt64.min...UInt64.max)
            
            let a = ValueCommand.arbitrary(
                using:  GenerationContext(seed: seed, size: 500),
                model:  0
            )
            
            let b = ValueCommand.arbitrary(
                using:  GenerationContext(seed: seed, size: 500),
                model:  9999
            )
            
            let nameA   = String(describing: a)
            let nameB   = String(describing: b)
            
            countsA[nameA, default: 0] += 1
            countsB[nameB, default: 0] += 1
        }
        
        XCTAssertEqual(countsA, countsB)
    }
    
    
    
    // MARK: - GenericCommand
    
    func testGenericCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     GenericCommand<Int>.self,
            model:  0
        )
    }
    
    
    
    func testGenericCommandSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = GenericCommand<Int>.arbitrary(
                using:  .randomZeroSize,
                model:  0
            )
            
            guard case .reset = value
            else
            {
                XCTFail("Expected .reset, got \(value)")
                return
            }
        }
    }
    
    
    
    func testGenericCommandShrinkEmpty()
    {
        XCTAssertEqual(GenericCommand<Int>.reset.shrink(), [])
    }
    
    
    
    func testGenericCommandShrinkMinimal()
    {
        XCTAssertEqual(GenericCommand<Int>.store(0).shrink(), [])
    }
    
    
    
    func testGenericCommandShrinkMatchesPropertyShrink()
    {
        let value       : GenericCommand<Int>       = .store(50)
        let candidates  : [GenericCommand<Int>]     = value.shrink()
        
        let expected: [GenericCommand<Int>]
            = (50 as Int).shrink().map { .store($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - NestedCommand
    
    func testNestedCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     Outer.InnerCommand.self,
            model:  0
        )
    }
    
    
    
    func testNestedCommandShrinkMatchesPropertyShrink()
    {
        let value       : Outer.InnerCommand    = .add(50)
        let candidates  : [Outer.InnerCommand]  = value.shrink()
        
        let expected: [Outer.InnerCommand]
            = (50 as Int).shrink().map { .add($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    // MARK: - PayloadOnlyCommand
    
    func testPayloadOnlyCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     PayloadOnlyCommand.self,
            model:  0
        )
    }
    
    
    
    func testPayloadOnlyCommandDistribution()
    {
        let iterations      : Int   = 10_000
        var addCount        : Int   = 0
        var multiplyCount   : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = PayloadOnlyCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            switch value
            {
                case .add       : addCount          += 1
                case .multiply  : multiplyCount     += 1
            }
        }
        
        let expected = Int(Double(iterations / 2) * 0.85)
        
        XCTAssertGreaterThan(addCount, expected)
        XCTAssertGreaterThan(multiplyCount, expected)
    }
    
    
    
    func testPayloadOnlyCommandShrinkMinimal()
    {
        XCTAssertEqual(PayloadOnlyCommand.add(0).shrink(), [])
        XCTAssertEqual(PayloadOnlyCommand.multiply(0).shrink(), [])
    }
    
    
    
    func testPayloadOnlyCommandShrinkMatchesPropertyShrink()
    {
        let value       : PayloadOnlyCommand    = .add(50)
        let candidates  : [PayloadOnlyCommand]  = value.shrink()
        
        let expected: [PayloadOnlyCommand]
            = (50 as Int).shrink().map { .add($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testPayloadOnlyCommandShrinkPreservesCase()
    {
        let addCandidates: [PayloadOnlyCommand]
            = PayloadOnlyCommand.add(10).shrink()
        
        XCTAssertFalse(addCandidates.isEmpty)
        
        for candidate in addCandidates
        {
            guard case .add = candidate
            else
            {
                XCTFail("Expected .add, got \(candidate)")
                return
            }
        }
        
        let multiplyCandidates: [PayloadOnlyCommand]
            = PayloadOnlyCommand.multiply(10).shrink()
        
        XCTAssertFalse(multiplyCandidates.isEmpty)
        
        for candidate in multiplyCandidates
        {
            guard case .multiply = candidate
            else
            {
                XCTFail("Expected .multiply, got \(candidate)")
                return
            }
        }
    }
    
    
    
    // MARK: - PreconditionCommand
    
    func testPreconditionCommandRespectsModelState()
    {
        for _ in 0..<1000
        {
            let value = PreconditionCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  10
            )
            
            if value.precondition(model: PreconditionCommand.threshold)
            {
                /// When the model is at the threshold, the precondition
                /// rejects the `.add` case. Generation must only produce
                /// `.reset` at that point.
                guard case .reset = value
                else
                {
                    XCTFail("Expected .reset, got \(value)")
                    return
                }
            }
        }
    }
    
    
    
    // MARK: - WeightedCommand
    
    func testWeightedCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     WeightedCommand.self,
            model:  0
        )
    }
    
    
    
    func testWeightedCommandDistribution()
    {
        let iterations      : Int   = 10_000
        var resetCount      : Int   = 0
        var subtractCount   : Int   = 0
        var addCount        : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = WeightedCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            switch value
            {
                case .reset     : resetCount        += 1
                case .subtract  : subtractCount     += 1
                case .add       : addCount          += 1
            }
        }
        
        /// Weights: reset (1) + subtract (3) + add (5)
        let total: Double = 9.0
        
        XCTAssertGreaterThan(
            resetCount,
            Int(Double(iterations) * 1.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            subtractCount,
            Int(Double(iterations) * 3.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            addCount,
            Int(Double(iterations) * 5.0 / total * 0.85)
        )
    }
    
    
    
    func testWeightedCommandSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = WeightedCommand.arbitrary(
                using:  .randomZeroSize,
                model:  0
            )
            
            guard case .reset = value
            else
            {
                /// At size zero, only base cases are generated, regardless
                /// of weights.
                XCTFail("Expected .reset, got \(value)")
                return
            }
        }
    }
    
    
    
    func testWeightedCommandShrinkEmpty()
    {
        XCTAssertEqual(WeightedCommand.reset.shrink(), [])
    }
    
    
    
    func testWeightedCommandShrinkMinimal()
    {
        XCTAssertEqual(WeightedCommand.add(0).shrink(), [])
        XCTAssertEqual(WeightedCommand.subtract(0).shrink(), [])
    }
    
    
    
    func testWeightedCommandShrinkMatchesPropertyShrink()
    {
        let value       : WeightedCommand       = .add(50)
        let candidates  : [WeightedCommand]     = value.shrink()
        
        let expected: [WeightedCommand] = (50 as Int).shrink().map { .add($0) }
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testWeightedCommandShrinkPreservesCase()
    {
        let addCandidates: [WeightedCommand]
            = WeightedCommand.add(10).shrink()
        
        XCTAssertFalse(addCandidates.isEmpty)
        
        for candidate in addCandidates
        {
            guard case .add = candidate
            else
            {
                XCTFail("Expected .add, got \(candidate)")
                return
            }
        }
        
        let subtractCandidates: [WeightedCommand]
            = WeightedCommand.subtract(10).shrink()
        
        XCTAssertFalse(subtractCandidates.isEmpty)
        
        for candidate in subtractCandidates
        {
            guard case .subtract = candidate
            else
            {
                XCTFail("Expected .subtract, got \(candidate)")
                return
            }
        }
    }
    
    
    
    // MARK: - MixedWeightCommand
    
    func testMixedWeightCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     MixedWeightCommand.self,
            model:  0
        )
    }
    
    
    
    func testMixedWeightCommandDistribution()
    {
        let iterations      : Int   = 10_000
        var resetCount      : Int   = 0
        var subtractCount   : Int   = 0
        var addCount        : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = MixedWeightCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            switch value
            {
                case .reset     : resetCount        += 1
                case .subtract  : subtractCount     += 1
                case .add       : addCount          += 1
            }
        }
        
        /// Weights: reset (1) + subtract (1) + add (5)
        let total: Double = 7.0
        
        XCTAssertGreaterThan(
            resetCount,
            Int(Double(iterations) * 1.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            subtractCount,
            Int(Double(iterations) * 1.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            addCount,
            Int(Double(iterations) * 5.0 / total * 0.85)
        )
    }
    
    
    
    func testMixedWeightCommandSizeZeroProduction()
    {
        for _ in 0..<1000
        {
            let value = MixedWeightCommand.arbitrary(
                using:  .randomZeroSize,
                model:  0
            )
            
            guard case .reset = value
            else
            {
                /// At size zero, only base cases are generated, regardless
                /// of weights.
                XCTFail("Expected .reset, got \(value)")
                return
            }
        }
    }
    
    
    
    // MARK: - WeightedBaseCaseCommand
    
    func testWeightedBaseCaseCommandDeterminism()
    {
        assertStatefulDeterminism(
            of:     WeightedBaseCaseCommand.self,
            model:  0
        )
    }
    
    
    
    func testWeightedBaseCaseCommandDistribution()
    {
        let iterations      : Int   = 10_000
        var resetCount      : Int   = 0
        var decrementCount  : Int   = 0
        var incrementCount  : Int   = 0
        
        for _ in 0..<iterations
        {
            let value = WeightedBaseCaseCommand.arbitrary(
                using:  .randomSeed(size: 500),
                model:  0
            )
            
            switch value
            {
                case .reset     : resetCount        += 1
                case .decrement : decrementCount    += 1
                case .increment : incrementCount    += 1
            }
        }
        
        /// Weights: reset (1) + decrement (2) + increment (5)
        let total: Double = 8.0
        
        XCTAssertGreaterThan(
            resetCount,
            Int(Double(iterations) * 1.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            decrementCount,
            Int(Double(iterations) * 2.0 / total * 0.85)
        )
        
        XCTAssertGreaterThan(
            incrementCount,
            Int(Double(iterations) * 5.0 / total * 0.85)
        )
    }
    
    
    
    func testWeightedBaseCaseCommandShrinkEmpty()
    {
        XCTAssertEqual(WeightedBaseCaseCommand.reset.shrink(), [])
        XCTAssertEqual(WeightedBaseCaseCommand.decrement.shrink(), [])
        XCTAssertEqual(WeightedBaseCaseCommand.increment.shrink(), [])
    }
    
    
    
    // MARK: - Integration
    
    func testSimpleCommandStatefulIntegration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        await XCTKStateful(
            model:      { 0 },
            system:     { SimpleSystem() },
            command:    SimpleCommand.self,
            options:    options
        )
    }
    
    
    
    func testPreconditionCommandStatefulIntegration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        await XCTKStateful(
            model:      { 0 },
            system:     { SimpleSystem() },
            command:    PreconditionCommand.self,
            options:    options
        )
    }
    
    
    
    func testBuggyCommandStatefulIntegration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { BuggySystem() },
                command:    BuggyCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 26 iterations (shrunk to 4 commands)

        Counterexample:
            1. add(11)
            2. add(5)
            3. add(22)
            4. add(13) ←
        
        XCTKAssertEqual failed

        Expected:   51
        Actual:     50
        
        Seed: 12345 (XCTKStateful)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testWeightedCommandStatefulIntegration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        await XCTKStateful(
            model:      { 0 },
            system:     { SimpleSystem() },
            command:    WeightedCommand.self,
            options:    options
        )
    }
    
    
    
    func testBuggyCommandStatefulRunnerIntegration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            seed:               12345
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    BuggyCommand.self,
            model:      { 0 },
            system:     { BuggySystem() },
            invariant:  nil,
            options:    options
        )
        
        guard case let .failed(counterexample, _, _) = result.property
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.failingStep)
    }
}



// MARK: - Support

/// Validates that the given type's ``Stateful`` conformance is deterministic.
/// - Parameters:
///   - type: The type to evaluate.
///   - model: The model to evaluate.
private func assertStatefulDeterminism<C>(
    of type : C.Type,
    model   : C.Model
) where C : Stateful & Equatable
{
    for _ in 0..<1000
    {
        let (context1, context2) = GenerationContext.sameRandomContexts
        
        let value1  = C.arbitrary(using: context1, model: model)
        let value2  = C.arbitrary(using: context2, model: model)
        
        if value1.isNaN
        {
            XCTAssertTrue(value2.isNaN)
        }
        else
        {
            XCTAssertEqual(value1, value2)
        }
    }
}



private struct SimpleSystem
{
    var value: Int = 0
}



@Stateful
private enum SimpleCommand: Equatable, Hashable, CaseIterable
{
    case increment
    case decrement
    case reset
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    ) async
    {
        switch self
        {
            case .increment:
                
                
                model           += 1
                system.value    += 1
                
            case .decrement:
                
                model           -= 1
                system.value    -= 1
                
            case .reset:
                
                model           = 0
                system.value    = 0
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .increment : model += 1
            case .decrement : model -= 1
            case .reset     : model = 0
        }
    }
}



@Stateful
private enum ValueCommand: Equatable
{
    case reset
    case add(amount: Int)
    case set(x: Int, y: Int)
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    ) async
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case let .add(amount):
                
                model           += amount
                system.value    += amount
                
            case let .set(x, y):
                
                model           = x + y
                system.value    = x + y
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset             : model = 0
            case let .add(amount)   : model += amount
            case let .set(x, y)     : model = x + y
        }
    }
}



@Stateful
private enum GenericCommand<T>: Equatable & Sendable
    where T : Equatable & Sendable
{
    case reset
    case store(T)
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case .store:
                
                break
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset : model = 0
            case .store : break
        }
    }
}



private struct Outer
{
    @Stateful
    enum InnerCommand: Equatable
    {
        case reset
        case add(Int)
        
        func run(
            model   : inout Int,
            system  : inout SimpleSystem
        )
        {
            switch self
            {
                case .reset:
                    
                    model           = 0
                    system.value    = 0
                    
                case let .add(n):
                    
                    model           += n
                    system.value    += n
            }
        }
        
        func advance(
            model: inout Int
        )
        {
            switch self
            {
                case .reset         : model = 0
                case let .add(n)    : model += n
            }
        }
    }
}




private struct BuggySystem
{
    var value: Int = 0
}



@Stateful
private enum BuggyCommand: Equatable
{
    case reset
    case add(Int)
    
    func run(
        model   : inout Int,
        system  : inout BuggySystem
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case let .add(n):
                
                model           += n
                system.value    += n
                
                if system.value > 50
                {
                    /// Divergence from model.
                    system.value -= 1
                }
        }
        
        TKAssertEqual(model, system.value)
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset         : model = 0
            case let .add(n)    : model += n
        }
    }
}



@Stateful
private enum PayloadOnlyCommand: Equatable
{
    case add(Int)
    case multiply(Int)
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    )
    {
        switch self
        {
            case let .add(n):
                
                model           += n
                system.value    += n
                
            case let .multiply(n):
                
                model           *= n
                system.value    *= n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case let .add(n)        : model += n
            case let .multiply(n)   : model *= n
        }
    }
}



@Stateful
private enum PreconditionCommand: Equatable
{
    case reset
    case add(Int)
    
    static let threshold: Int = 10
    
    func precondition(
        model: Int
    ) -> Bool
    {
        switch self
        {
            case .reset : return true
            case .add   : return model < Self.threshold
        }
    }
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case let .add(n):
                
                model           += n
                system.value    += n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset         : model = 0
            case let .add(n)    : model += n
        }
    }
}



@Stateful
private enum WeightedCommand: Equatable
{
    @Weight(1) case reset
    @Weight(3) case subtract(Int)
    @Weight(5) case add(Int)
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case let .subtract(n):
                
                model           -= n
                system.value    -= n
                
            case let .add(n):
                
                model           += n
                system.value    += n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset             : model = 0
            case let .subtract(n)   : model -= n
            case let .add(n)        : model += n
        }
    }
}



@Stateful
private enum MixedWeightCommand: Equatable
{
    case reset
    case subtract(Int)
    @Weight(5) case add(Int)
    
    func run(
        model   : inout Int,
        system  : inout SimpleSystem
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case let .subtract(n):
                
                model           -= n
                system.value    -= n
                
            case let .add(n):
                
                model           += n
                system.value    += n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .reset             : model = 0
            case let .subtract(n)   : model -= n
            case let .add(n)        : model += n
        }
    }
}



@Stateful
private enum WeightedBaseCaseCommand: Equatable
{
    typealias Model     = Int
    typealias System    = SimpleSystem
    
    @Weight(1) case reset
    @Weight(2) case decrement
    @Weight(5) case increment
    
    func run(
        model   : inout Model,
        system  : inout System
    )
    {
        switch self
        {
            case .reset:
                
                model           = 0
                system.value    = 0
                
            case .decrement:
                
                model           -= 1
                system.value    -= 1
                
            case .increment:
                
                model           += 1
                system.value    += 1
        }
    }
    
    func advance(
        model: inout Model
    )
    {
        switch self
        {
            case .reset     : model = 0
            case .decrement : model -= 0
            case .increment : model += 0
        }
    }
}
