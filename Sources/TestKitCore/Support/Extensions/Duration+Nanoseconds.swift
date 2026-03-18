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
    /// The total nanoseconds.
    internal var nanoseconds: Double
    {
        let (seconds, attoseconds): (Int64, Int64) = components
        
        return Double(seconds) * 1_000_000_000
            + Double(attoseconds) * 1e-9
    }
}
