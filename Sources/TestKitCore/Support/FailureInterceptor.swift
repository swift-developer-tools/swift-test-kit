//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Synchronization



// MARK: - FailureInterceptor

/// Intercepts assertion failures.
///
/// This class must use `@unchecked Sendable` since it is subclassed by the
/// interceptors of various evaluators, and therefore cannot be `final`.
/// Unchecked `Sendable` conformance is safe since mutable state is protected
/// by `Mutex`, and subclassing is restricted to this package.
package class FailureInterceptor: @unchecked Sendable
{
    /// The current interceptor.
    @TaskLocal
    package static var current  : FailureInterceptor?
    
    /// The current interceptor state.
    private let failureState    : Mutex<[InterceptedFailure]>
    
    
    
    /// Initializes a ``FailureInterceptor`` instance.
    internal init()
    {
        self.failureState = Mutex([])
    }
    
    
    
    /// Whether a failure has been recorded.
    internal var didFail: Bool
    {
        return !failures.isEmpty
    }
    
    
    
    /// The recorded failures.
    internal var failures: [InterceptedFailure]
    {
        return failureState.withLock { $0 }
    }
    
    
    
    /// Records the specified assertion failure.
    /// - Parameters:
    ///   - message: An optional description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    package func recordFailure(
        message : String,
        fileID  : StaticString,
        file    : StaticString,
        line    : UInt,
        column  : UInt
    )
    {
        let failure = InterceptedFailure(
            message:    message,
            fileID:     fileID,
            file:       file,
            line:       line,
            column:     column
        )
        
        failureState.withLock { $0.append(failure) }
    }
    
    
    
    /// Resets the interceptor for reuse.
    internal func reset()
    {
        failureState.withLock
        {
            $0 = []
        }
    }
}



// MARK: - InterceptedFailure

/// A failure intercepted during property evaluation.
internal struct InterceptedFailure: Equatable, Sendable
{
    /// The failure message.
    internal let message    : String
    
    /// The ID of the file where the failure occured.
    internal let fileID     : StaticString
    
    /// The file where the failure occurred.
    internal let file       : StaticString
    
    /// The line where the failure occurred.
    internal let line       : UInt
    
    /// The column where the failure occured.
    internal let column     : UInt
    
    
    
    internal static func == (
        lhs: InterceptedFailure,
        rhs: InterceptedFailure
    ) -> Bool
    {
        return lhs.message == rhs.message
            && lhs.fileID.description == rhs.fileID.description
            && lhs.file.description == rhs.file.description
            && lhs.line == rhs.line
            && lhs.column == rhs.column
    }
}

