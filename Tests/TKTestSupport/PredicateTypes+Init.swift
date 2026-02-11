//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



extension ElementResult
{
    /// Initializes an ``ElementResult`` instance from the given values.
    package init(
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



extension CountMismatch
{
    /// Initializes a ``CountMismatch`` instance from the given values, and
    /// an empty ``CountMismatch/errorElements`` array.
    package init(
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



extension OrderingViolation
{
    /// Initializes an ``OrderingViolation`` instance from the given values.
    package init(
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



extension DuplicateGroup
{
    /// Initializes a ``DuplicateGroup`` instance from the given values.
    package init(
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



extension DuplicateKeyGroup
{
    /// Initializes a ``DuplicateKeyGroup`` instance from the given values.
    package init(
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



extension IndexedElement
{
    /// Initializes an ``IndexedElement`` instance from the given values.
    package init(
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
