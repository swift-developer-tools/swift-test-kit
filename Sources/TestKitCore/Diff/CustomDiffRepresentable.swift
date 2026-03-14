//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - CustomDiffRepresentable

/// A type with a customized structural diff representation.
///
/// Types that conform to this protocol can control which properties are
/// recursed into when computing diffs. Conformance to this protocol takes
/// precedence over all built-in diffing.
public protocol CustomDiffRepresentable
{
    var diffRepresentation: DiffRepresentation { get }
}



// MARK: - DiffRepresentation

/// A custom representation of a value for structural diffing.
///
/// A diff representation is a list of named properties to recurse into when
/// computing diffs. Properties not included in the list will not appear in
/// the diff.
public struct DiffRepresentation
{
    /// The properties to include in the diff.
    public let properties: [Property]
    
    
    
    /// Initializes a ``DiffRepresentation`` instance from the given properties.
    public init(
        _ properties: [Property]
    )
    {
        self.properties = properties
    }
    
    
    
    /// A named property in a diff representation.
    public struct Property
    {
        /// The property name.
        public let name     : String
        
        /// The property value.
        public let value    : Any
        
        
        
        /// Initializes a ``Property`` instance from the given values.
        public init(
            _   name    : String,
            _   value   : Any
        )
        {
            self.name   = name
            self.value  = value
        }
    }
}
