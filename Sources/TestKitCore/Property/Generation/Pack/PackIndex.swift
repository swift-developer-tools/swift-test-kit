//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A sequential counter for reconstructing typed tuples from arrays via
/// pack expansion.
internal final class PackIndex
{
    /// The current pack index.
    private var current: Int = 0
    
    
    
    /// Initializes a ``PackIndex`` instance.
    internal init() { }
    
    
    
    /// Gets the next pack index.
    ///
    /// Each call to this method returns and increments ``current``. This
    /// allows `repeat array[index.next()] as! each T` to map each pack
    /// position to the correct array parameter.
    ///
    /// - Returns: The next pack index.
    internal func next() -> Int
    {
        defer
        {
            current += 1
        }
        
        return current
    }
}
