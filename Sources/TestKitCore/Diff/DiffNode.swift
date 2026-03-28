//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - DiffNode

/// A node in a diff tree.
///
/// A diff tree represents the structural differences between an expected
/// value and an actual value. Each node in the tree has a label describing
/// its position within its parent (for example, the label may be a property
/// name or an array index), and a kind describing the comparison result at
/// that position.
package struct DiffNode: Equatable
{
    /// The node label.
    package let label   : DiffNodeLabel
    
    /// The kind of diff node.
    package let kind    : DiffNodeKind
    
    
    
    /// Initializes a ``DiffNode`` instance from the given values.
    package init(
        label   : DiffNodeLabel,
        kind    : DiffNodeKind
    )
    {
        self.label  = label
        self.kind   = kind
    }
}



// MARK: - CycleLocation

/// The location where a cycle was detected.
package enum CycleLocation: Equatable, CustomStringConvertible
{
    /// A cycle was detected in the expected value.
    case expected
    
    /// A cycle was detected in the actual value.
    case actual
    
    /// A cycle was detected in both the expected and actual values.
    case both
    
    
    
    /// A description of where the cycle location was detected.
    package var description: String
    {
        switch self
        {
            case .expected:
                
                return "Cycle detected in expected value"
                
            case .actual:
                
                return "Cycle detected in actual value"
                
            case .both:
                
                return "Cycle detected in both expected and actual values"
        }
    }
}



// MARK: - DiffNodeKind

/// The kind of diff computed between by comparing an expected value to an
/// actual value.
package enum DiffNodeKind: Equatable
{
    /// A cycle was detected during comparison.
    ///
    /// A cycle may occur when comparing reference types (classes) that contain
    /// a circular reference. The comparison stops immediately to prevent
    /// infinite recursion (rather than waiting to stop at the limit specified
    /// by ``DiffOptions/maxRecursionDepth``, if any).
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - location: The location where the cycle was detected.
    case cycle(
        expected    : DiffValue,
        actual      : DiffValue,
        location    : CycleLocation
    )
    
    /// The values are equal.
    case same
    
    /// The values are not equal.
    ///
    /// The diff tree will be empty at leaf nodes. For example:
    /// - When comparing primitive values.
    /// - When the max recursion depth is reached.
    /// - When comparing types that cannot be meaningfully decomposed using
    /// `Mirror` (for example, closures or opaque types).
    /// - When comparing enum cases that differ, but have no shared recursable
    /// structure.
    ///
    /// The diff tree will be populated at structural nodes. For example:
    /// - When comparing structs and recursing through their properties.
    /// - When comparing arrays and recursing through their elements.
    /// - When comparing dictionaries and recursing through their entries.
    /// - When comparing enum cases with different associated values.
    ///
    /// Generally, the diff tree will be populated when it can be used to
    /// explain where inside the values the difference is located. It will be
    /// empty when all that can be said is that the values are different.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - tree: The diff tree representing the difference between the
    ///   expected and actual values. This will be empty at leaf nodes.
    case different(
        expected    : DiffValue,
        actual      : DiffValue,
        tree        : [DiffNode]
    )
    
    /// An element or key was present in the expected value, but missing from
    /// the actual value.
    /// - Parameter expected: The expected value.
    case missing(
        _ expected: DiffValue
    )
    
    /// An element or key was present in the actual value, but was not in the
    /// expected value.
    /// - Parameter actual: The actual value.
    case unexpected(
        _ actual: DiffValue
    )
    
    
    
    package var isCycle: Bool
    {
        switch self
        {
            case .cycle : return true
            default     : return false
        }
    }
    
    
    
    package var isSame: Bool
    {
        switch self
        {
            case .same  : return true
            default     : return false
        }
    }
    
    
    
    package var isDifferent: Bool
    {
        switch self
        {
            case .different : return true
            default         : return false
        }
    }
    
    
    
    package var isMissing: Bool
    {
        switch self
        {
            case .missing   : return true
            default         : return false
        }
    }
    
    
    
    package var isUnexpected: Bool
    {
        switch self
        {
            case .unexpected    : return true
            default             : return false
        }
    }
}



// MARK: - DiffNodeLabel

/// The label of a node in a diff tree.
package enum DiffNodeLabel: Equatable, Sendable
{
    /// The root node of a diff tree.
    /// - Parameter typeName: The name of the value's type.
    case root(
        typeName: String
    )
    
    /// A property of an enum, class, or struct.
    ///
    /// Other types handled by this case include labeled tuple elements,
    /// labeled enum associated values, and the wrapped value of an `Optional`
    /// instance.
    ///
    /// - Parameter name: The property name.
    case property(
        name: String
    )
    
    /// An element in an ordered collection (for example, an array).
    ///
    /// Other types handled by this case include unlabeled tuple elements and
    /// unlabeled enum associated values.
    ///
    /// - Parameter index: The zero-indexed index.
    case index(
        _ index: Int
    )
    
    /// A key in a keyed collection (for example, a dictionary).
    /// - Parameters:
    ///   - description: The string representation of the key.
    ///   - typeName: The string representation of the key's type.
    case key(
        _ description:  String,
        typeName:       String
    )
    
    /// A member of an unordered collection (for example, a set).
    case member
    
    /// A line in a multi-line string.
    /// - Parameter index: The zero-indexed line number.
    case line(
        _ index: Int
    )
    
    /// A character in a string.
    /// - Parameters:
    ///   - index: The zero-indexed character position.
    ///   - count: The number of different characters.
    case character(
        index   : Int,
        count   : Int
    )
    
    
    
    /// A string key used for sorting.
    package var sortKey: String
    {
        switch self
        {
            case .root                      : return ""
            case let .property(name)        : return name
            case let .index(index)          : return String(index)
            case let .key(description, _)   : return description
            case .member                    : return ""
            case let .line(index)           : return String(index)
            case let .character(index, _)   : return String(index)
        }
    }
    
    
    
    package var isRoot: Bool
    {
        switch self
        {
            case .root  : return true
            default     : return false
        }
    }
    
    
    
    package var isProperty: Bool
    {
        switch self
        {
            case .property  : return true
            default         : return false
        }
    }
    
    
    
    package var isIndex: Bool
    {
        switch self
        {
            case .index : return true
            default     : return false
        }
    }
    
    
    
    package var isKey: Bool
    {
        switch self
        {
            case .key   : return true
            default     : return false
        }
    }
    
    
    
    package var isMember: Bool
    {
        switch self
        {
            case .member    : return true
            default         : return false
        }
    }
    
    
    
    package var isLine: Bool
    {
        switch self
        {
            case .line  : return true
            default     : return false
        }
    }
    
    
    
    package var isCharacter: Bool
    {
        switch self
        {
            case .character : return true
            default         : return false
        }
    }
    
    
    
    /// Creates a ``DiffNodeLabel/key(description:typeName:)`` instance from
    /// the given key.
    /// - Parameter key: The key to use.
    /// - Returns: The created node label.
    package static func makeKey<K>(
        _ key: K
    ) -> DiffNodeLabel where K : Hashable
    {
        let unwrapped: Any = (key as AnyHashable).base
        
        return .key(
            String(describing: unwrapped),
            typeName: String(describing: type(of: unwrapped))
        )
    }
}
