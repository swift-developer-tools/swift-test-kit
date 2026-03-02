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
    /// Replaces the non-deterministic time portion of an `always` failure
    /// message with `<T>`.
    internal var timeless: String
    {
        return replacing(
            /failed after \d+(\.\d+)?\s*(ms|sec)/,
            with: "failed after <T>"
        )
    }
}
