//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Synchronization



// MARK: - PropertyInterceptor

/// Intercepts assertion failures during property evaluation.
///
/// When an assertion fails inside a property evaluator, the failure message
/// is recorded here instead of being reported to the associated framework.
/// This allows the property body to be re-run for shrinking purposes.
package final class PropertyInterceptor: Sendable
{
    /// The current interceptor, if running inside a property evaluator.
    @TaskLocal
    package static var current  : PropertyInterceptor?
    
    /// The current interceptor state.
    private let state           : Mutex<[InterceptedFailure]>
    
    
    
    /// Initializes a ``PropertyInterceptor`` instance.
    package init()
    {
        self.state = Mutex([])
    }
    
    
    
    /// Whether a failure has been recorded.
    package var didFail: Bool
    {
        return !failures.isEmpty
    }
    
    
    
    /// The recorded failures.
    package var failures: [InterceptedFailure]
    {
        return state.withLock { $0 }
    }
    
    
    
    /// Records an assertion failure.
    /// - Parameters:
    ///   - message: The failure message.
    ///   - file: The file where the failure occurred.
    ///   - line: The line where the failure occurred.
    package func record(
        message : String,
        file    : StaticString,
        line    : UInt
    )
    {
        let failure = InterceptedFailure(
            message:    message,
            file:       file,
            line:       line
        )
        
        state.withLock { $0.append(failure) }
    }
    
    
    
    /// Resets the interceptor for reuse.
    ///
    /// This is used to reset the interceptor between shrink attempts.
    package func reset()
    {
        state.withLock { $0 = [] }
    }
}



// MARK: - InterceptedFailure

/// A failure intercepted during property evaluation.
package struct InterceptedFailure: Equatable, Sendable
{
    /// The failure message.
    package let message : String
    
    /// The file where the failure occurred.
    package let file    : StaticString
    
    /// The line where the failure occurred.
    package let line    : UInt
    
    
    
    package static func == (
        lhs: InterceptedFailure,
        rhs: InterceptedFailure
    ) -> Bool
    {
        return lhs.message == rhs.message
            && lhs.file.description == rhs.file.description
            && lhs.line == rhs.line
    }
}
