//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog



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
        warnNoOp(for: "Classify")
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
        warnNoOp(for: "Cover")
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
        warnNoOp(for: "Label")
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



/// Tags the current iteration with the given label in the specified table.
package func TKTabulate(
    table   : String,
    label   : String
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        warnNoOp(for: "Tabulate")
        return
    }
    
    interceptor.recordTableLabel(
        label,
        table: table
    )
}



/// Registers minimum coverage percentages for the given labels in the
/// specified table.
package func TKCoverTable(
    table           : String,
    requirements    : [(Double, String)]
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        warnNoOp(for: "CoverTable")
        return
    }
    
    for (percentage, label) in requirements
    {
        interceptor.recordTableCoverageRequirement(
            percentage,
            for:    label,
            in:     table
        )
    }
}



// MARK: - Support

private let logger = Logger(
    subsystem:  "swift-test-kit",
    category:   "Classification"
)



/// Warns that the specified function was called outside a property body.
/// - Parameter functionName: The function name.
private func warnNoOp(
    for functionName: String
)
{
    logger.warning("\(functionName) called outside a property body (no-op)")
}
