//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import OSLog



package func TKAssume(
    _ condition: () -> Bool
) throws
{
    guard FailureInterceptor.current is PropertyInterceptor
    else
    {
        warnNoOp(for: "Assume")
        return
    }
    
    if !condition()
    {
        throw DiscardError()
    }
}



package func TKClassify(
    _       label       : String,
    when    condition   : () -> Bool
)
{
    guard let interceptor = FailureInterceptor.current as? PropertyInterceptor
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



package func TKCover(
    _       percentage  : Double,
    _       label       : String,
    when    condition   : () -> Bool
)
{
    guard let interceptor = FailureInterceptor.current as? PropertyInterceptor
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



package func TKLabel(
    _ label: String
)
{
    guard let interceptor = FailureInterceptor.current as? PropertyInterceptor
    else
    {
        warnNoOp(for: "Label")
        return
    }
    
    interceptor.recordLabel(label)
}



package func TKCollect<T>(
    _ value: T
)
{
    TKLabel("\(value)")
}



package func TKTabulate(
    _   table   : String,
    _   label   : String
)
{
    guard let interceptor = FailureInterceptor.current as? PropertyInterceptor
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



package func TKCoverTable(
    _   table           : String,
    _   requirements    : [(Double, String)]
)
{
    guard let interceptor = FailureInterceptor.current as? PropertyInterceptor
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
