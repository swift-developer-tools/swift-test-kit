//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The label of a node in a diff tree.
internal enum DiffNodeLabel: Equatable, Sendable
{
    /// The root node of a diff tree.
    case root
    
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
