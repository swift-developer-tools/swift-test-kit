//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

internal extension Array<Any>
{
    /// An array of hashable type-erased values, or `nil` if the array
    /// elements are not hashable.
    var hashable: [AnyHashable]?
    {
        var result: [AnyHashable] = []
        
        result.reserveCapacity(self.count)
        
        for element in self
        {
            guard let hashableElement = element as? AnyHashable
            else
            {
                return nil
            }
            
            result.append(hashableElement)
        }
        
        return result
    }
}
