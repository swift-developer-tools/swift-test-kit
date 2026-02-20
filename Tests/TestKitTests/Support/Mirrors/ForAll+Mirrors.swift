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

/// These functions are mirrors wrapping the actual internal functions,
/// allowing tests to benefit from autoclosures and default parameters.
/// The XCTestKit failure context is used since tests are run with XCTest.



@Reasync
internal func TKForAll<each T>(
    _ message   : @autoclosure () -> String             = "",
    fileID      : StaticString                          = #fileID,
    file        : StaticString                          = #filePath,
    line        : UInt                                  = #line,
    column      : UInt                                  = #column,
    options     : TestOptions                           = .init(),
    _ property  : (repeat each T) async throws -> Void
) async where repeat each T : Arbitrary
{
    await TestKitCore.TKForAll(
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        property,
        context:    failureContext
    )
}



@Reasync
internal func TKForAll<each T>(
    using generators    : repeat Generator<each T>,
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions                           = .init(),
    _ property          : (repeat each T) async throws -> Void
) async
{
    await TestKitCore.TKForAll(
        using:      repeat each generators,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        property,
        context:    failureContext
    )
}



@Reasync
internal func TKForAll<each T>(
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions                           = .init(),
    _ property          : (repeat each T) async throws -> Void
) async where repeat each T : Arbitrary
{
    await TestKitCore.TKForAll(
        where:      precondition,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        property,
        context:    failureContext
    )
}



@Reasync
internal func TKForAll<each T>(
    using generators    : repeat Generator<each T>,
    where precondition  : @escaping (repeat each T) -> Bool,
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions                           = .init(),
    _ property          : (repeat each T) async throws -> Void
) async
{
    await TestKitCore.TKForAll(
        using:      repeat each generators,
        where:      precondition,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        property,
        context:    failureContext
    )
}
