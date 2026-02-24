//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Runs a stateful property test that validates the given system against the
/// given model.
///
/// SwiftTestKit assertions used inside commands or invariants are
/// automatically intercepted rather than reported directly to Swift Testing.
///
/// - Important: Native Swift Testing assertions are not intercepted by
/// SwiftTestKit. If a native Swift Testing assertion fails inside a command
/// or invariant, it bypasses shrinking and produces an immediate test failure.
/// Use only SwiftTestKit assertions inside commands or invariants.
///
/// - Parameters:
///   - message: An optional description of a failure.
///   - model: A factory that creates a new model instance.
///   - system: A factory that creates a new system instance.
///   - command: The command type.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - invariant: An optional closure that checks invariants after each
///   command.
public func STKStateful<C>(
    _ message   : @autoclosure () -> String                     = "",
    model       : () -> C.Model,
    system      : () -> C.System,
    command     : C.Type,
    fileID      : StaticString                                  = #fileID,
    file        : StaticString                                  = #filePath,
    line        : UInt                                          = #line,
    column      : UInt                                          = #column,
    options     : TestOptions?                                  = nil,
    invariant   : ((C.Model, C.System) async throws -> Void)?   = nil
) async where C : Stateful
{
    await TKStateful(
        message,
        model:      model,
        system:     system,
        command:    command,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        invariant:  invariant,
        context:    failureContext
    )
}
