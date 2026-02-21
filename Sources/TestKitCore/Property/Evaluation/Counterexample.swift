//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A failing counterexample.
internal struct Counterexample<T>
{
    /// The minimal counterexample (after shrinking).
    internal let value          : T
    
    /// The original counterexample (before shrinking).
    internal let originalValue  : T
    
    /// The seed used to initialize the random number generator.
    internal let seed           : UInt64
    
    /// The 1-indexed iteration at which the original counterexample was found.
    internal let iteration      : Int
    
    /// The number of shrink steps performed.
    internal let shrinkSteps    : Int
    
    /// The assertion failures from the final run with the shrunken value.
    internal let failures       : [InterceptedFailure]
    
    /// The error thrown by the property body, if any.
    internal let thrownError    : Error?
}
