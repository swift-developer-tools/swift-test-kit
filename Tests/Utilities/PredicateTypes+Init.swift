//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore



internal extension ElementResult
{
    /// Initializes an ``ElementResult`` instance from the given values.
    init(
        index   : Int,
        value   : Any,
        error   : String?     = nil
    )
    {
        self.init(
            index:  index,
            value:  DiffValue(value),
            error:  error
        )
    }
}



internal extension CountMismatch
{
    /// Initializes a ``CountMismatch`` instance from the given values, and
    /// an empty ``CountMismatch/errorElements`` array.
    init(
        expected        : CountExpectationKind,
        matchedIndices  : [Int]
    )
    {
        self.init(
            expected:           expected,
            matchedIndices:     matchedIndices,
            errorElements:      []
        )
    }
}



internal extension OrderingViolation
{
    /// Initializes an ``OrderingViolation`` instance from the given values.
    init(
        index   : Int,
        first   : Any,
        second  : Any,
        error   : String? = nil
    )
    {
        self.init(
            index:      index,
            first:      DiffValue(first),
            second:     DiffValue(second),
            error:      error
        )
    }
}



internal extension DuplicateGroup
{
    /// Initializes a ``DuplicateGroup`` instance from the given values.
    init(
        value   : Any,
        indices : [Int]
    )
    {
        self.init(
            value:      DiffValue(value),
            indices:    indices
        )
    }
}



internal extension DuplicateKeyGroup
{
    /// Initializes a ``DuplicateKeyGroup`` instance from the given values.
    init(
        key         : Any,
        elements    : [IndexedElement]
    )
    {
        self.init(
            key:        DiffValue(key),
            elements:   elements
        )
    }
}



internal extension IndexedElement
{
    /// Initializes an ``IndexedElement`` instance from the given values.
    init(
        _ index   : Int,
        _ value   : Any
    )
    {
        self.init(
            index:  index,
            value:  DiffValue(value)
        )
    }
}
