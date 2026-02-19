//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Information about a failing counterexample.
package struct Counterexample<T>
{
    /// The minimal counterexample (after shrinking).
    package let value           : T
    
    /// The original counterexample (before shrinking).
    package let originalValue   : T
    
    /// The seed used to initialize the random number generator.
    package let seed            : UInt64
    
    /// The 1-indexed iteration at which the original counterexample was found.
    package let iteration       : Int
    
    /// The number of shrink steps performed.
    package let shrinkSteps     : Int
    
    /// The assertion failures from the final run with the shrunken value.
    package let failures        : [InterceptedFailure]
    
    /// The error thrown by the property body, if any.
    package let thrownError     : Error?
}
