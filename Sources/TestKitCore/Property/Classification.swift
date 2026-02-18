//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog



private let logger = Logger(
    subsystem:  "swift-test-kit",
    category:   "Classification"
)



/// Tags the current iteration with the given label when the given condition
/// is true.
package func TKClassify(
    label       : String,
    condition   : () -> Bool
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("Classify called outside a property body (no-op)")
        return
    }
    
    if condition()
    {
        interceptor.recordLabel(label)
    }
}



/// Tags the current iteration with the given label when the given condition
/// is true, and registers a minimum coverage percentage for that label.
package func TKCover(
    percentage  : Double,
    label       : String,
    condition   : () -> Bool
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("Cover called outside a property body (no-op)")
        return
    }
    
    interceptor.recordCoverageRequirement(
        percentage,
        for: label
    )
    
    if condition()
    {
        interceptor.recordLabel(label)
    }
}



/// Tags the current iteration with the given label.
package func TKLabel(
    label: String
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("Label called outside a property body (no-op)")
        return
    }
    
    interceptor.recordLabel(label)
}



/// Tags the current iteration with the string representation of the given
/// value.
package func TKCollect<T>(
    value: T
)
{
    TKLabel(label: "\(value)")
}
