//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The error thrown when unwrapping a value that is `nil`.
public struct UnwrapError: Error, CustomStringConvertible
{
    /// The framework kind.
    private let framework: FrameworkKind
    
    
    
    /// Initializes an ``UnwrapError`` from the given framework kind.
    internal init(
        _ framework: FrameworkKind
    )
    {
        self.framework = framework
    }
    
    
    
    /// The error description.
    public var description: String
    {
        let name: String = AssertionKind.unwrap.name(for: framework)
        
        return "\(name) unwrapped a nil value"
    }
}
