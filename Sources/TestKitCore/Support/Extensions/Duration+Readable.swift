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
    ///
    /// Durations of one second or more are formatted as seconds with one
    /// decimal place. Durations under one second are formatted as whole
    /// milliseconds.
    internal var readable: String
    {
        let (seconds, attoseconds): (Int64, Int64) = components
        
        let totalNanoseconds: Int64
            = seconds * 1_000_000_000
            + attoseconds / 1_000_000_000
        
        let totalMilliseconds: Int64 = totalNanoseconds / 1_000_000
        
        if totalMilliseconds >= 1000
        {
            let second: Double = Double(totalMilliseconds) / 1000.0
            
            return String(format: "%.1fs", second)
        }

        return "\(totalMilliseconds)ms"
    }
}
