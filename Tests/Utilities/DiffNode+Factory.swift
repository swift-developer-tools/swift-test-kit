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
    static func makeRoot<T>(
        typeName    : String,
        expected    : T,
        actual      : T,
        tree        : [DiffNode]
    ) -> DiffNode where T : Equatable
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
    static func makeLeaf<T>(
        label       : DiffNodeLabel,
        expected    : T,
        actual      : T
    ) -> DiffNode where T : Equatable
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
    static func makeStructural<T>(
        label       : DiffNodeLabel,
        expected    : T,
        actual      : T,
        tree        : [DiffNode]
    ) -> DiffNode where T : Equatable
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
    
    
    
    /// Creates a different structural node from the given values.
    ///
    /// Use this when the expected and actual values cannot conform to
    /// `Equatable` (for example, tuples).
    ///
    /// - Parameters:
    ///   - label: The diff node label.
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - tree: The diff nodes.
    /// - Returns: The different structural node.
    static func makeStructuralAny(
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
    static func makeCycle<T>(
        label       : DiffNodeLabel,
        expected    : T,
        actual      : T,
        location    : CycleLocation
    ) -> DiffNode where T : Equatable
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
    static func makeMissing<T>(
        label       : DiffNodeLabel,
        expected    : T
    ) -> DiffNode where T : Equatable
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
    static func makeUnexpected<T>(
        label   : DiffNodeLabel,
        actual  : T
    ) -> DiffNode where T : Equatable
    {
        return DiffNode(
            label:  label,
            kind:   .unexpected(actual: DiffValue(actual))
        )
    }
}
