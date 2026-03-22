//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger
{
    /// Checks whether there is an overflow if the given value is added to
    /// the receiver.
    /// - Parameter value: The value to add.
    /// - Returns: Whether there is an overflow if the given value is added to
    /// the receiver.
    internal func overflows(
        add value: Self
    ) -> Bool
    {
        let (_, overflow): (Self, Bool)
            = self.addingReportingOverflow(value)
        
        return overflow
    }
    
    
    
    /// Checks whether there is an overflow if the given value is subtracted
    /// from the receiver.
    /// - Parameter value: The value to subtract.
    /// - Returns: Whether there is an overflow if the given value is
    /// subtracted from the receiver.
    internal func overflows(
        subtract value: Self
    ) -> Bool
    {
        let (_, overflow): (Self, Bool)
            = self.subtractingReportingOverflow(value)
        
        return overflow
    }
    
    
    
    /// Checks whether there is an overflow if the receiver is multiplied by
    /// the given value.
    /// - Parameter value: The value to multiply.
    /// - Returns: Whether there is an overflow if the receiver is multiplied
    /// by the given value.
    internal func overflows(
        multiply value: Self
    ) -> Bool
    {
        let (_, overflow): (Self, Bool)
            = self.multipliedReportingOverflow(by: value)
        
        return overflow
    }
}
