//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore



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



// MARK: - ModelAwareShrink

internal enum ModelAwareShrinkCommand: Stateful, Equatable, Sendable
{
    case add(Int)
    
    static let threshold: Int = 5
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        return .add(threshold + max(1, context.size))
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
        
        if model >= Self.threshold
        {
            FailureInterceptor.current?.recordFailure()
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
        return []
    }
    
    func shrink(
        model: Int
    ) -> [Self]
    {
        switch self
        {
            case let .add(n):
                
                let needed: Int = max(1, Self.threshold - model)
                
                if n > needed
                {
                    return [.add(needed)]
                }
                
                return []
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
        
        (FailureInterceptor.current as? PropertyInterceptor)?
            .recordLabel(Self.text)
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
            FailureInterceptor.current?.recordFailure()
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
        
        FailureInterceptor.current?.recordFailure()
        
        throw TestError()
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
}



// MARK: - PostCFail

internal enum PostCFailCommand: Stateful, Equatable, Sendable
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
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
    
    func postcondition(
        model   : Int,
        system  : Int
    ) -> Bool
    {
        return model < Self.threshold
    }
}



// MARK: - PostCState

internal enum PostCStateCommand: Stateful, Equatable, Sendable
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
        model   += 10
        system  += 10
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 10
    }
    
    func postcondition(
        model   : Int,
        system  : Int
    ) -> Bool
    {
        return model % 10 == 0
            && system % 10 == 0
    }
}



// MARK: - PostCAfterRunFail

internal enum PostCAfterRunFailCommand: Stateful, Equatable, Sendable
{
    case step
    
    /// Tracks whether the postcondition was called.
    ///
    /// Stateful tests run sequentially within a single task, so this is safe.
    nonisolated(unsafe) static var postconditionCallCount: Int = 0
    
    static let message: String = "run failure"
    
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
        
        FailureInterceptor.current?.recordFailure(
            message:    Self.message,
            fileID:     "",
            file:       "",
            line:       0,
            column:     0
        )
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
    
    func postcondition(
        model   : Int,
        system  : Int
    ) -> Bool
    {
        Self.postconditionCallCount += 1
        
        return false
    }
}



// MARK: - PostCSkipsInvariant

internal enum PostCSkipsInvariantCommand: Stateful, Equatable, Sendable
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
    }
    
    func advance(
        model: inout Int
    )
    {
        model += 1
    }
    
    func postcondition(
        model   : Int,
        system  : Int
    ) -> Bool
    {
        return false
    }
}



// MARK: - Cycle

internal enum CycleCommand: Stateful, Equatable, Sendable
{
    case alpha
    case beta
    case gamma
    
    static let threshold: Int = 3
    
    static func arbitrary(
        using context   : GenerationContext,
        model           : Int
    ) -> Self
    {
        /// Cycle between commands (`alpha`, `beta`, `gamma`, repeat).
        switch model % threshold
        {
            case 0  : return .alpha
            case 1  : return .beta
            default : return .gamma
        }
    }
    
    func run(
        model   : inout Int,
        system  : inout Int
    ) async throws
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
