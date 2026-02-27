//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Runs temporal assertions.
internal struct TemporalRunner
{
    /// Temporal assertion kinds.
    internal enum Kind
    {
        /// All assertions must always pass.
        ///
        /// This polls continuously, immediately fails on any assertion failure,
        /// and succeeds on timeout.
        case always
        
        /// All assertions must eventually pass.
        ///
        /// This polls continuously until all assertions pass, and fails on
        /// timeout.
        case eventually
    }
    
    
    
    /// Runs the specified temporal assertion.
    /// - Parameters:
    ///   - kind: The kind of temporal test.
    ///   - timeout: The timeout duration.
    ///   - interval: The polling interval.
    ///   - body: The assertion body.
    /// - Returns: The result of running the temporal assertion.
    internal static func run(
        kind        : Kind,
        timeout     : Duration,
        interval    : Duration,
        body        : () async throws -> Void
    ) async -> TemporalResult
    {
        let interceptor = TemporalInterceptor()
        
        let start: ContinuousClock.Instant = .now
        
        while true
        {
            guard !Task.isCancelled
            else
            {
                return .canceled
            }
            
            
            
            interceptor.reset()
            
            var thrownError: Error? = nil
            
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
            
            
            
            switch kind
            {
                case .always:
                    
                    if
                        interceptor.didFail
                        || thrownError != nil
                    {
                        return .failed(
                            failures:   interceptor.failures,
                            elapsed:    start.elapsed,
                            error:      thrownError
                        )
                    }
                    
                    if start.elapsed >= timeout
                    {
                        return .passed
                    }
                    
                case .eventually:
                    
                    if
                        !interceptor.didFail,
                        thrownError == nil
                    {
                        return .passed
                    }
                    
                    if start.elapsed >= timeout
                    {
                        return .failed(
                            failures:   interceptor.failures,
                            elapsed:    start.elapsed,
                            error:      thrownError
                        )
                    }
            }
            
            
            
            try? await Task.sleep(
                for:    interval,
                clock:  ContinuousClock()
            )
        }
    }
}
