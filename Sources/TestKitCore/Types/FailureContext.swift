//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The context for an assertion failure.
package struct FailureContext: Sendable
{
    /// The framework kind.
    package let framework   : FrameworkKind
    
    /// Emits a failure message.
    package let emit        : @Sendable (String, StaticString, UInt) -> Void
    
    
    
    /// Initializes a ``FailureContext`` from the given values.
    package init(
        framework   : FrameworkKind,
        emit        : @Sendable @escaping (String, StaticString, UInt) -> Void
    )
    {
        self.framework  = framework
        self.emit       = emit
    }
}
