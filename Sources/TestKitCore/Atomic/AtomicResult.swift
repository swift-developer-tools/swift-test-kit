//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The result of an atomic test.
internal enum AtomicResult
{
    /// All assertions passed and the body did not throw an error.
    case passed
    
    /// The atomic test failed.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - error: The thrown error.
    case failed(
        failures:   [InterceptedFailure],
        error:      Error?
    )
}
