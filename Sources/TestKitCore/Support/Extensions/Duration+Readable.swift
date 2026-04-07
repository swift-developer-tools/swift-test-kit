//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Duration
{
    /// The duration formatted as seconds or milliseconds.
    internal var readable: String
    {
        guard self != .zero
        else
        {
            /// Use the smallest unit unambiguously.
            return "0 ns"
        }
        
        let ns: Double = self.nanoseconds
        
        let allowed         : Set<UnitsFormatStyle.Unit>
        let fractionalPart  : UnitsFormatStyle.FractionalPartDisplayStrategy
        
        if ns >= 1_000_000
        {
            /// 1 millisecond or more.
            allowed         = [.seconds, .milliseconds]
            fractionalPart  = .show(length: 1, rounded: .toNearestOrEven)
        }
        else if ns >= 1_000
        {
            /// 1 microsecond or more.
            allowed         = [.microseconds]
            fractionalPart  = .show(length: 1, rounded: .toNearestOrEven)
        }
        else
        {
            /// Less than 1 microsecond.
            allowed         = [.nanoseconds]
            fractionalPart  = .hide
        }
        
        var result: String = self.formatted(.units(
            allowed:            allowed,
            width:              .abbreviated,
            maximumUnitCount:   1,
            zeroValueUnits:     .hide,
            fractionalPart:     fractionalPart
        ))
        
        result.replace(".0 ", with: " ")
        
        return result
    }
}
