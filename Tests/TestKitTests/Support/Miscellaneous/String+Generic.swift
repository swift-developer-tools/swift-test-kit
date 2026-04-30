//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension String
{
    /// Strips alignment padding from threshold lines and replaces
    /// non-deterministic median values with `<M>`.
    internal var medianless: String
    {
        return replacing(/\    Threshold:\s+(.+)/)
        {
            "    Threshold: \($0.output.1)"
        }
        .replacing(/\    Median:\s+.+?\s(\(\d+ runs?\))(.*)/)
        {
            "    Median: <M> \($0.output.1)\($0.output.2)"
        }
    }
    
    
    
    /// Replaces the non-deterministic time portion of an `always` failure
    /// message with `<T>`.
    internal var timeless: String
    {
        return replacing(
            /failed after \d+(\.\d+)?\s*(ns|μs|ms|sec)/,
            with: "failed after <T>"
        )
    }
}
