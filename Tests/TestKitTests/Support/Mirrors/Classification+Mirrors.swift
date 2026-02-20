//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore

/// These functions are mirrors wrapping the actual internal functions,
/// allowing tests to benefit from autoclosures and variadic parameters.
/// Functions that have neither of those features are not mirrored here.



internal func TKAssume(
    _ condition: @autoclosure () -> Bool
) throws
{
    try TestKitCore.TKAssume(condition)
}



internal func TKClassify(
    _       label       : String,
    when    condition   : @autoclosure () -> Bool
)
{
    TestKitCore.TKClassify(
        label,
        when: condition
    )
}



internal func TKCover(
    _       percentage  : Double,
    _       label       : String,
    when    condition   : @autoclosure () -> Bool
)
{
    TestKitCore.TKCover(
        percentage,
        label,
        when: condition
    )
}



internal func TKCoverTable(
    _   table           : String,
    _   requirements    : (Double, String)...
)
{
    TestKitCore.TKCoverTable(
        table,
        requirements
    )
}
