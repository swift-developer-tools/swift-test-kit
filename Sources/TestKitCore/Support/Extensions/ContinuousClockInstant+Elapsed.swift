//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension ContinuousClock.Instant
{
    /// The time elapsed between the receiver and now.
    internal var elapsed: Duration
    {
        return ContinuousClock.now - self
    }
}
