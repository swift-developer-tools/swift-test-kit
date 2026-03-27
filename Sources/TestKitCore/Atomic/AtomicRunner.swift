//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Reasync



/// Runs atomic tests.
internal struct AtomicRunner
{
    // MARK: - Run
    
    /// Runs an atomic test.
    /// - Parameter body: The atomic body.
    /// - Returns: The result of the atomic test.
    @Reasync
    internal static func run(
        body: () async throws -> Void,
    ) async -> AtomicResult
    {
        let interceptor : AtomicInterceptor     = .init()
        var thrownError : Error?                = nil
        
        await FailureInterceptor.$current.withValue(interceptor)
        {
            do
            {
                try await body()
            }
            catch
            {
                thrownError = error
            }
        }
        
        if
            interceptor.didFail
            || thrownError != nil
        {
            return .failed(
                failures:   interceptor.failures,
                error:      thrownError
            )
        }
        
        return .passed
    }
}
