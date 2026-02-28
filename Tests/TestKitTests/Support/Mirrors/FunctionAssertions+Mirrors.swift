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



// MARK: - Boolean

internal func TKAssert(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions                       = .init(),
    context         : FailureContext                    = XCTestKit.failureContext
)
{
    TestKitCore.TKAssert(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertTrue(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions                       = .init(),
    context         : FailureContext                    = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertTrue(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertFalse(
    _ expression    : @autoclosure () throws -> Bool,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions                       = .init(),
    context         : FailureContext                    = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertFalse(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Nil and non-nil

internal func TKAssertNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions                       = .init(),
    context         : FailureContext                    = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertNil(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNotNil(
    _ expression    : @autoclosure () throws -> Any?,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions                       = .init(),
    context         : FailureContext                    = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertNotNil(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKUnwrap<T>(
    _ expression    : @autoclosure () throws -> T?,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) throws -> T
{
    return try TestKitCore.TKUnwrap(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Equality and inequality

internal func TKAssertEqual<T>(
    _ expected  : @autoclosure () throws -> T,
    _ actual    : @autoclosure () throws -> T,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions                   = .init(),
    context     : FailureContext                = XCTestKit.failureContext
) where T : Equatable
{
    TestKitCore.TKAssertEqual(
        expected,
        actual,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Equatable
{
    TestKitCore.TKAssertNotEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions                           = .init(),
    context         : FailureContext                        = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertIdentical(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNotIdentical(
    _ expression1   : @autoclosure () throws -> AnyObject?,
    _ expression2   : @autoclosure () throws -> AnyObject?,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions                           = .init(),
    context         : FailureContext                        = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertNotIdentical(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : FloatingPoint
{
    TestKitCore.TKAssertEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Numeric
{
    TestKitCore.TKAssertEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : FloatingPoint
{
    TestKitCore.TKAssertNotEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNotEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    accuracy        : T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Numeric
{
    TestKitCore.TKAssertNotEqual(
        expression1,
        expression2,
        accuracy:   accuracy,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Comparable

internal func TKAssertGreaterThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Comparable
{
    TestKitCore.TKAssertGreaterThan(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertGreaterThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Comparable
{
    TestKitCore.TKAssertGreaterThanOrEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertLessThanOrEqual<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Comparable
{
    TestKitCore.TKAssertLessThanOrEqual(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertLessThan<T>(
    _ expression1   : @autoclosure () throws -> T,
    _ expression2   : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where T : Comparable
{
    TestKitCore.TKAssertLessThan(
        expression1,
        expression2,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Error

internal func TKAssertThrowsError<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext,
    _ errorHandler  : (any Error) -> Void           = { _ in }
)
{
    TestKitCore.TKAssertThrowsError(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        errorHandler,
        context:    context
    )
}



internal func TKAssertNoThrow<T>(
    _ expression    : @autoclosure () throws -> T,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
)
{
    TestKitCore.TKAssertNoThrow(
        expression,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Fail

internal func TKFail(
    _ message   : String            = "",
    fileID      : StaticString      = #fileID,
    file        : StaticString      = #filePath,
    line        : UInt              = #line,
    column      : UInt              = #column,
    context     : FailureContext    = XCTestKit.failureContext
)
{
    TestKitCore.TKFail(
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        context:    context
    )
}



// MARK: - Predicate

internal func TKAssertAllSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertAllSatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertAnySatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertAnySatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertNoneSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertNoneSatisfy(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertSatisfy(
        collection,
        atLeast:    atLeast,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertSatisfy(
        collection,
        atMost:     atMost,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertSatisfy<C>(
    _ collection    : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertSatisfy(
        collection,
        range:      range,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertExactly<C>(
    _ collection    : @autoclosure () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertExactly(
        collection,
        count:      count,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertExactlyOne<C>(
    _ collection    : @autoclosure () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertExactlyOne(
        collection,
        predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertSorted<C>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : @autoclosure () -> String             = "",
    fileID          : StaticString                          = #fileID,
    file            : StaticString                          = #filePath,
    line            : UInt                                  = #line,
    column          : UInt                                  = #column,
    options         : TestOptions                           = .init(),
    context         : FailureContext                        = XCTestKit.failureContext
) where C : Collection
{
    TestKitCore.TKAssertSorted(
        collection,
        by:         predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertUnique<C>(
    _ collection    : @autoclosure () throws -> C,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection, C.Element : Hashable
{
    TestKitCore.TKAssertUnique(
        collection,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



internal func TKAssertUnique<C, K>(
    _ collection    : @autoclosure () throws -> C,
    by predicate    : (C.Element) throws -> K,
    _ message       : @autoclosure () -> String     = "",
    fileID          : StaticString                  = #fileID,
    file            : StaticString                  = #filePath,
    line            : UInt                          = #line,
    column          : UInt                          = #column,
    options         : TestOptions                   = .init(),
    context         : FailureContext                = XCTestKit.failureContext
) where C : Collection, K : Hashable
{
    TestKitCore.TKAssertUnique(
        collection,
        by:         predicate,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}
