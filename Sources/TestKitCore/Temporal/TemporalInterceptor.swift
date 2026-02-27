//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Intercepts assertion failures during temporal assertion polling.
///
/// When an assertion fails inside a temporal assertion, the failure is
/// recorded here instead of being reported to the associated framework.
/// This allows the temporal runner to evaluate whether the polling loop
/// should continue or resolve.
///
/// - Note: This class currently does not implement any features beyond those
/// that it inherits from ``FailureInterceptor``. It is a separate class for
/// extensibility and clarity.
///
/// - Note: See ``FailureInterceptor`` regarding `Sendable` conformance.
package final class TemporalInterceptor:
    FailureInterceptor, @unchecked Sendable
{
    
}
