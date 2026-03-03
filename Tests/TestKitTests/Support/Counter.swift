//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A thread-safe counter.
internal actor Counter: Sendable
{
    private var count: Int = 0
    
    var value: Int
    {
        return count
    }
    
    @discardableResult
    func increment() -> Int
    {
        count += 1
        return count
    }
}
