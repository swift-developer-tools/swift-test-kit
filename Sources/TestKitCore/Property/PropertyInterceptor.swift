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
public final class PropertyInterceptor: Sendable
{
    /// The current interceptor, if running inside a property evaluator.
    @TaskLocal
    public static var current   : PropertyInterceptor?
    
    /// The current interceptor state.
    private let state           : Mutex<[InterceptedFailure]>
    
    
    
    /// Initializes a ``PropertyInterceptor`` instance.
    public init()
    {
        self.state = Mutex([])
    }
    
    
    
    /// Whether a failure has been recorded.
    public var didFail: Bool
    {
        return !failures.isEmpty
    }
    
    
    
    /// The recorded failures.
    public var failures: [InterceptedFailure]
    {
        return state.withLock { $0 }
    }
    
    
    
    /// Records an assertion failure.
    /// - Parameters:
    ///   - message: The failure message.
    ///   - file: The file where the failure occurred.
    ///   - line: The line where the failure occurred.
    public func record(
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
    public func reset()
    {
        state.withLock { $0 = [] }
    }
}



// MARK: - InterceptedFailure

/// A failure intercepted during property evaluation.
public struct InterceptedFailure: Equatable, Sendable
{
    /// The failure message.
    public let message  : String
    
    /// The file where the failure occurred.
    public let file     : StaticString
    
    /// The line where the failure occurred.
    public let line     : UInt
    
    
    
    public static func == (
        lhs: InterceptedFailure,
        rhs: InterceptedFailure
    ) -> Bool
    {
        return lhs.message == rhs.message
            && lhs.file.description == rhs.file.description
            && lhs.line == rhs.line
    }
}
