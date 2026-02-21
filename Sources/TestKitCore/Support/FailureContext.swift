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
    package let framework: FrameworkKind
    
    /// Emits a failure message.
    /// - Parameters:
    ///   - message: An optional description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    package let emit: @Sendable (
        String,
        StaticString,
        StaticString,
        UInt,
        UInt
    ) -> Void
    
    
    
    /// Initializes a ``FailureContext`` from the given values.
    package init(
        framework   : FrameworkKind,
        emit        : @Sendable @escaping (
            String, StaticString, StaticString, UInt, UInt
        ) -> Void
    )
    {
        self.framework  = framework
        self.emit       = emit
    }
}
