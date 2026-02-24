//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
@testable import XCTestKit



/// This function is a mirror wrapping the actual internal function,
/// allowing tests to benefit from autoclosures and default parameters.
/// The XCTestKit failure context is used since tests are run with XCTest.
internal func TKStateful<C>(
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
    await TestKitCore.TKStateful(
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
