//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The result of running a temporal test.
internal enum TemporalResult: Sendable
{
    /// The enclosing task was canceled.
    case canceled
    
    /// The temporal test passed.
    case passed
    
    /// The temporal test failed.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - elapsed: The elapsed duration at the point of resolution.
    ///   - error: The thrown error.
    case failed(
        failures    : [InterceptedFailure],
        elapsed     : Duration,
        error       : Error?
    )
}
