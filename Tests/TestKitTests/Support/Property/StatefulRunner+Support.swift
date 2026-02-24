//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
@testable import protocol TestKitCore.Arbitrary



// MARK: - Increment

internal enum IncrementCommand: Stateful, Equatable, Sendable
{
    case increment
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .increment
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - ShrinkableIncrement

internal enum ShrinkableIncrementCommand: Stateful, Equatable, Sendable
{
    case increment
    case noOp
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .increment
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case .increment:
                
                model   += 1
                system  += 1
                
            case .noOp:
                
                break
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .increment : model += 1
            case .noOp      : break
        }
    }
    
    func shrink() -> [Self]
    {
        switch self
        {
            case .increment : return [.noOp]
            case .noOp      : return []
        }
    }
}



// MARK: - Amount

internal enum AmountCommand: Stateful, Equatable, Sendable
{
    case add(Int)
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .add(context.random(in: 1...max(1, context.size)))
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case let .add(n):
                
                model   += n
                system  += n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case let .add(n): model += n
        }
    }
    
    func shrink() -> [Self]
    {
        switch self
        {
            case let .add(n):
                
                return n.shrinkTowardZero()
                    .filter { $0 > 0 }
                    .map { .add($0) }
        }
    }
}



// MARK: - ScaledStep

internal enum ScaledStepCommand: Stateful, Equatable, Sendable
{
    case add(Int)
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .add(max(1, context.size))
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case let .add(n):
                
                model   += n
                system  += n
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case let .add(n): model += n
        }
    }
}



// MARK: - Bound

internal enum BoundCommand: Stateful, Equatable, Sendable
{
    case increment
    case noOp
    
    static let bound: Int = 5
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        if model < bound
        {
            return context.randomBool() ? .increment : .noOp
        }
        
        return .noOp
    }
    
    func precondition(
        model: Int
    ) -> Bool
    {
        switch self
        {
            case .increment : return model < Self.bound
            case .noOp      : return true
        }
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case .increment:
                
                model   += 1
                system  += 1
                
            case .noOp:
                
                break
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .increment : model += 1
            case .noOp      : break
        }
    }
}



// MARK: - Stack

internal enum StackCommand: Stateful, Equatable, Sendable
{
    case push
    case pop
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        if model == 0
        {
            return .push
        }
        
        return context.randomBool() ? .push : .pop
    }
    
    func precondition(
        model: Int
    ) -> Bool
    {
        switch self
        {
            case .push  : return true
            case .pop   : return model > 0
        }
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case .push:
                
                model   += 1
                system  += 1
                
            case .pop:
                
                model   -= 1
                system  -= 1
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case .push  : model += 1
            case .pop   : model -= 1
        }
    }
}



// MARK: - Label

internal enum LabelCommand: Stateful, Equatable, Sendable
{
    case label
    
    static let text: String = "labeled"
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .label
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
        
        PropertyInterceptor.current?.recordLabel(Self.text)
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - Classify

internal enum ClassifyCommand: Stateful, Equatable, Sendable
{
    case increment
    
    static let text     : String    = "classify-run"
    static let table    : String    = "classify-table"
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .increment
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
        
        TKClassify(Self.text, when: true)
        TKTabulate(Self.table, Self.text)
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - SizeCapture

internal enum SizeCaptureCommand: Stateful, Equatable, Sendable
{
    case size(Int)
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .size(context.size)
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        switch self
        {
            case let .size(size):
                
                model   = size
                system  = size
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        switch self
        {
            case let .size(size): model = size
        }
    }
}



// MARK: - Divergent

internal enum DivergentCommand: Stateful, Equatable, Sendable
{
    case step
    
    static let threshold: Int = 5
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func precondition(
        model: Int
    ) -> Bool
    {
        return model < Self.threshold
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 2
        system  += 2
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - CoverNever

internal enum CoverNeverCommand: Stateful, Equatable, Sendable
{
    case step
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
        
        TKCover(100, "never", when: false)
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - Assume

internal enum AssumeCommand: Stateful, Equatable, Sendable
{
    case step
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        try TKAssume(false)
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - Collect

internal enum CollectCommand: Stateful, Equatable, Sendable
{
    case step
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
        
        TKCollect(model)
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - RunFail

internal enum RunFailCommand: Stateful, Equatable, Sendable
{
    case step
    
    static let threshold: Int = 3
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async
    {
        model   += 1
        system  += 1
        
        if model >= Self.threshold
        {
            PropertyInterceptor.current?.recordFailure()
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - RunDiscard

internal enum RunDiscardCommand: Stateful, Equatable, Sendable
{
    case step
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        throw DiscardError()
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - RunThrow

internal enum RunThrowCommand: Stateful, Equatable, Sendable
{
    case step
    
    static let threshold: Int = 1
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        if model >= Self.threshold
        {
            throw TestError()
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - RunFailThrow

internal enum RunFailThrowCommand: Stateful, Equatable, Sendable
{
    case step
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        PropertyInterceptor.current?.recordFailure()
        
        throw TestError()
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - ForAllPass

internal enum ForAllPassCommand: Stateful, Equatable, Sendable
{
    case step
    
    private static let options: TestOptions = .propertyOptions(
        iterations:     10,
        seed:           99
    )
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        await TKForAll(options: Self.options)
        {
            (n: Int) async in
            
            TKAssertEqual(n + 0, n)
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - ForAllFail

internal enum ForAllFailCommand: Stateful, Equatable, Sendable
{
    case step
    
    static let threshold: Int = 3
    
    private static let options: TestOptions = .propertyOptions(
        iterations:         10,
        maxShrinkSteps:     0,
        seed:               99
    )
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .step
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
    {
        model   += 1
        system  += 1
        
        await TKForAll(options: Self.options)
        {
            (_: Int) async in
            
            TKAssertTrue(false)
        }
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}
