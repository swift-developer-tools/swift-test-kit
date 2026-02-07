//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal extension FixedWidthInteger
{
    /// Shrinks the value toward zero by repeatedly halving the distance.
    /// - Returns: The shrink candidates.
    func shrinkTowardZero() -> [Self]
    {
        guard self != 0
        else
        {
            return []
        }
        
        var candidates  : [Self]    = [0]
        var diff        : Self      = self
        
        while true
        {
            diff /= 2
            
            if diff == 0
            {
                break
            }
            
            candidates.append(self - diff)
        }
        
        return candidates
    }
}
