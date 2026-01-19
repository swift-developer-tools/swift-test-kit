//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
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
///
/// Consider the follow type and values:
///
/// ```swift
/// struct User: Equatable
/// {
///     let name    : String
///     let age     : Int
///     let tags    : [String]
/// }
///
/// let expected    = User(name: "Someone", age: 30, tags: ["a", "b", "c"])
/// let actual      = User(name: "Someone", age: 20, tags: ["a", "x"])
/// ```
///
/// The resulting diff tree would be:
///
/// ```swift
/// DiffNode(label: .root, kind: .different(
///     expected:   User(...),
///     actual:     User(...),
///     tree:
///     [
///         DiffNode(
///             label:  .property(name: "age"),
///             kind:   .different(
///                         expected:   30,
///                         actual:     20,
///                         tree:       []
///                     )
///         ),
///
///         DiffNode(
///             label:  .property(name: "tags"),
///             kind:   .different(
///                         expected:   ["a", "b", "c"],
///                         actual:     ["a", "x"],
///                         tree:
///                         [
///                             DiffNode(
///                                 label:  .index(1),
///                                 kind:   .different(
///                                             expected:   "b",
///                                             actual:     "x",
///                                             tree:       []
///                                         )
///                             ),
///
///                             DiffNode(
///                                 label:  .index(2),
///                                 kind:   .missingElement(expected: "c")
///                             )
///                         ]
///                     )
///         )
///     ]
/// ))
/// ```
///
/// Note that in the diff tree:
/// - Equal values like `name` and `tags[0]` are not included in the diff tree,
/// since only the differences are reported.
/// - The `age` comparison is a leaf node (`tree` is empty), since integers
/// and other primitive values cannot be further decomposed.
/// - The `tags` comparison is a structural node (`tree` is non-empty), since
/// arrays can be further decomposed.
/// - The `tags[2]` element uses ``DiffNodeKind/missingElement(expected:)``,
/// since it exists in `expected` but not in `actual`.
internal struct DiffNode
{
    /// The node label.
    let label   : DiffNodeLabel
    
    /// The kind of diff node.
    let kind    : DiffNodeKind
}



// MARK: - CycleLocation

/// The location where a cycle was detected.
internal enum CycleLocation: CustomStringConvertible
{
    /// A cycle was detected in the expected value.
    case expected
    
    /// A cycle was detected in the actual value.
    case actual
    
    /// A cycle was detected in both the expected and actual values.
    case both
    
    
    
    /// A description of where the cycle location was detected.
    var description: String
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
internal enum DiffNodeKind
{
    /// A cycle was detected during comparison.
    ///
    /// A cycle may occur when comparing reference types (classes) that contain
    /// a circular reference. The comparison stops immediately to prevent
    /// infinite recursion (rather than waiting to stop at the limit specified
    /// by ``XCTKDiffOptions/maxRecursionDepth``, if any).
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
    case missingElement(
        expected: DiffValue
    )
    
    /// An element or key was present in the actual value, but was not in the
    /// expected value.
    /// - Parameter actual: The actual value.
    case unexpectedElement(
        actual: DiffValue
    )
}



// MARK: - DiffNodeLabel

/// The label of a node in a diff tree.
internal enum DiffNodeLabel: Equatable, Sendable
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
        description:    String,
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
    /// - Parameter index: The zero-indexed character position.
    case character(
        _ index: Int
    )
    
    
    
    /// A string key used for sorting.
    var sortKey: String
    {
        switch self
        {
            case .root                      : return ""
            case let .property(name)        : return name
            case let .index(index)          : return String(index)
            case let .key(description, _)   : return description
            case .member                    : return ""
            case let .line(index)           : return String(index)
            case let .character(index)      : return String(index)
        }
    }
    
    
    
    /// Creates a ``DiffNodeLabel/key(description:typeName:)`` instance from
    /// the given key.
    /// - Parameter key: The key to use.
    /// - Returns: The created node label.
    static func makeKey<T>(
        _ key: T
    ) -> DiffNodeLabel
    {
        var unwrapped: Any = key
        
        if let hashable = key as? AnyHashable
        {
            unwrapped = hashable.base
        }
        
        return .key(
            description:    String(describing: unwrapped),
            typeName:       String(describing: type(of: unwrapped))
        )
    }
}
