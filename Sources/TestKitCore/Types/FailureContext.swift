//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for an assertion failure.
public struct FailureContext: Sendable
{
    /// The framework kind.
    public let framework    : FrameworkKind
    
    /// Emits a failure message.
    public let emit         : @Sendable (String, StaticString, UInt) -> Void
    
    
    
    /// Initializes a ``FailureContext`` from the given values.
    public init(
        framework   : FrameworkKind,
        emit        : @Sendable @escaping (String, StaticString, UInt) -> Void
    )
    {
        self.framework  = framework
        self.emit       = emit
    }
}
