//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import XCTestKit



extension DiffNode
{
    /// Creates a root node from the given values.
    /// - Parameters:
    ///   - typeName: The type name.
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - tree: The diff nodes.
    /// - Returns: The root node.
    static func makeRoot(
        typeName    : String,
        expected    : Any,
        actual      : Any,
        tree        : [DiffNode]
    ) -> DiffNode
    {
        return makeStructural(
            label:      .root(typeName: typeName),
            expected:   expected,
            actual:     actual,
            tree:       tree
        )
    }
    
    
    
    /// Creates a different leaf node from the given values.
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    /// - Returns: The different leaf node.
    static func makeLeaf(
        label       : DiffNodeLabel,
        expected    : Any,
        actual      : Any
    ) -> DiffNode
    {
        return DiffNode(
            label:  label,
            kind:   .different(
                        expected:   DiffValue(expected),
                        actual:     DiffValue(actual),
                        tree:       []
                    )
        )
    }
    
    
    
    /// Creates a different structural node from the given values.
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - tree: The diff nodes.
    /// - Returns: The different structural node.
    static func makeStructural(
        label       : DiffNodeLabel,
        expected    : Any,
        actual      : Any,
        tree        : [DiffNode]
    ) -> DiffNode
    {
        return DiffNode(
            label:  label,
            kind:   .different(
                        expected:   DiffValue(expected),
                        actual:     DiffValue(actual),
                        tree:       tree
                    )
        )
    }
    
    
    
    /// Creates a cycle node from the given values.
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - location: The cycle location.
    /// - Returns: The cycle node.
    static func makeCycle(
        label       : DiffNodeLabel,
        expected    : Any,
        actual      : Any,
        location    : CycleLocation
    ) -> DiffNode
    {
        return DiffNode(
            label:  label,
            kind:   .cycle(
                        expected:   DiffValue(expected),
                        actual:     DiffValue(actual),
                        location:   location
                    )
        )
    }
    
    
    
    /// Creates a missing node from the given values.
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - expected: The expected value.
    /// - Returns: The missing node.
    static func makeMissing(
        label       : DiffNodeLabel,
        expected    : Any
    ) -> DiffNode
    {
        return DiffNode(
            label:  label,
            kind:   .missing(expected: DiffValue(expected))
        )
    }
    
    
    
    /// Creates an unexpected node from the given values.
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - actual: The actual value.
    /// - Returns: The unexpected node.
    static func makeUnexpected(
        label   : DiffNodeLabel,
        actual  : Any
    ) -> DiffNode
    {
        return DiffNode(
            label:  label,
            kind:   .unexpected(actual: DiffValue(actual))
        )
    }
}
