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
        var result: String = self.formatted(.units(
            allowed:            [.seconds, .milliseconds],
            width:              .abbreviated,
            maximumUnitCount:   1,
            zeroValueUnits:     .hide,
            fractionalPart:     .show(length: 1)
        ))
        
        result.replace(".0 ", with: " ")
        
        return result
    }
}
