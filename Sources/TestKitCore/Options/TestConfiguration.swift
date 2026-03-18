//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Synchronization



/// The global configuration.
public enum TestConfiguration: Sendable
{
    private static let _global = Mutex<TestOptions>(.init())
    
    /// The global options.
    ///
    /// These options apply to all tests that do not specify explicit options,
    /// and are not called within a with-options method scope.
    ///
    /// - Important: ``TestConfiguration`` is thread-safe, but modifying global
    /// options during parallel test executions may cause logical races. Use
    /// a with-options method to scope options to a specific test, or set
    /// global options once before tests begin.
    public static var global: TestOptions
    {
        get { _global.withLock { $0 } }
        set { _global.withLock { $0 = newValue } }
    }
    
    
    
    @TaskLocal
    private static var _current: TestOptions?
    
    /// The resolved options for the current context.
    ///
    /// This returns the task-local options, if set by an enclosing scope,
    /// or the ``global`` options otherwise.
    package static var current: TestOptions
    {
        return _current ?? global
    }
    
    
    
    /// Calls the given closure with the given options.
    ///
    /// All tests executed within the given closure use the given options
    /// instead of the ``global`` options, unless those tests explicitly
    /// specify options.
    ///
    /// - Note: Scopes may be nested. An inner scope's options take precedence
    /// over an outer scope's options.
    ///
    /// - Parameters:
    ///   - options: The options for testing.
    ///   - body: The test closure to call.
    @Reasync
    public static func withOptions(
        _ options   : @autoclosure () -> TestOptions,
        body        : () async throws -> Void
    ) async rethrows
    {
        try await $_current.withValue(options())
        {
            try await body()
        }
    }
    
    
    
    /// Calls the given closure with modified options.
    ///
    /// The modification closure receives the currently-resolved options from
    /// an enclosing scope or the ``global`` options. All tests executed within
    /// the `body` closure use the modified options.
    ///
    /// - Parameters:
    ///   - modify: The closure that modifies the options.
    ///   - body: The test closure to call.
    @Reasync
    public static func withOptions(
        _ modify   : (inout TestOptions) -> Void,
        body        : () async throws -> Void
    ) async rethrows
    {
        var options: TestOptions = current
        
        modify(&options)
        
        try await withOptions(
            options,
            body: body
        )
    }
}
