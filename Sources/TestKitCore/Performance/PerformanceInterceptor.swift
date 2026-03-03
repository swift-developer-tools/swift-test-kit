//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Intercepts assertion failures during performance testing.
///
/// When an assertion fails inside a performance test, the failure is recorded
/// here instead of being reported to the associated framework. This allows
/// the performance runner to emit a single failure.
///
/// - Note: This class currently does not implement any features beyond those
/// that it inherits from ``FailureInterceptor``. It is a separate class for
/// extensibility and clarity.
///
/// - Note: See ``FailureInterceptor`` regarding `Sendable` conformance.
package final class PerformanceInterceptor:
    FailureInterceptor, @unchecked Sendable
{
    
}
