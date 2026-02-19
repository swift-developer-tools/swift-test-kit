//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Boolean

package func TKAssert(
    _ expression    : () throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssert(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertTrue(
    _ expression    : () throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertTrue(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertFalse(
    _ expression    : () throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertFalse(
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



// MARK: - Nil and non-nil

package func TKAssertNil(
    _ expression    : () throws -> Any?,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertNil(
        capture:    .none,
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertNotNil(
    _ expression    : () throws -> Any?,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertNotNil(
        capture:    .none,
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKUnwrap<T>(
    _ expression    : () throws -> T?,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) throws -> T
{
    return try evaluateTKUnwrap(
        capture:    .none,
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



// MARK: - Equality and inequality

package func TKAssertEqual<T>(
    _ expected  : () throws -> T,
    _ actual    : () throws -> T,
    _ message   : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Equatable
{
    evaluateTKAssertEqual(
        capture:    .none,
        expected:   expected,
        actual:     actual,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Equatable
{
    evaluateTKAssertNotEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertIdentical(
    _ expression1   : () throws -> AnyObject?,
    _ expression2   : () throws -> AnyObject?,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertIdentical(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertNotIdentical(
    _ expression1   : () throws -> AnyObject?,
    _ expression2   : () throws -> AnyObject?,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertNotIdentical(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    accuracy        : T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : FloatingPoint
{
    evaluateTKAssertEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    accuracy        : T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Numeric
{
    evaluateTKAssertEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    accuracy        : T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : FloatingPoint
{
    evaluateTKAssertNotEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    accuracy        : T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Numeric
{
    evaluateTKAssertNotEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



// MARK: - Comparable

package func TKAssertGreaterThan<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Comparable
{
    evaluateTKAssertGreaterThan(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertGreaterThanOrEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Comparable
{
    evaluateTKAssertGreaterThanOrEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertLessThanOrEqual<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Comparable
{
    evaluateTKAssertLessThanOrEqual(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



package func TKAssertLessThan<T>(
    _ expression1   : () throws -> T,
    _ expression2   : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where T : Comparable
{
    evaluateTKAssertLessThan(
        capture:    .none,
        expr1:      expression1,
        expr2:      expression2,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



// MARK: - Error

package func TKAssertThrowsError<T>(
    _ expression    : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    _ errorHandler  : (any Error) -> Void,
    context         : FailureContext
)
{
    evaluateTKAssertThrowsError(
        capture:        .none,
        expr:           expression,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        errorHandler:   errorHandler,
        context:        context
    )
}



package func TKAssertNoThrow<T>(
    _ expression    : () throws -> T,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertNoThrow(
        capture:    .none,
        expr:       expression,
        message:    message,
        file:       file,
        line:       line,
        options:    options,
        context:    context
    )
}



// MARK: - Fail

package func TKFail(
    _ message   : String,
    file        : StaticString,
    line        : UInt,
    context     : FailureContext
)
{
    context.emit(
        message,
        file,
        line
    )
}



// MARK: - Predicate

package func TKAssertAllSatisfy<C>(
    _ collection    : () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertAllSatisfy(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertAnySatisfy<C>(
    _ collection    : () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertAnySatisfy(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertNoneSatisfy<C>(
    _ collection    : () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertNoneSatisfy(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfy<C>(
    _ collection    : () throws -> C,
    atLeast         : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSatisfy(
        capture:        .none,
        collection:     collection,
        atLeast:        atLeast,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfy<C>(
    _ collection    : () throws -> C,
    atMost          : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{    
    evaluateTKAssertSatisfy(
        capture:        .none,
        collection:     collection,
        atMost:         atMost,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfy<C>(
    _ collection    : () throws -> C,
    range           : ClosedRange<Int>,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{    
    evaluateTKAssertSatisfy(
        capture:        .none,
        collection:     collection,
        range:          range,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertExactly<C>(
    _ collection    : () throws -> C,
    count           : Int,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{    
    evaluateTKAssertExactly(
        capture:        .none,
        collection:     collection,
        count:          count,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertExactlyOne<C>(
    _ collection    : () throws -> C,
    _ predicate     : (C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertExactlyOne(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertSorted<C>(
    _ collection    : () throws -> C,
    by predicate    : (C.Element, C.Element) throws -> Bool,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSorted(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertUnique<C>(
    _ collection    : () throws -> C,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection, C.Element : Hashable
{
    evaluateTKAssertUnique(
        capture:        .none,
        collection:     collection,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}



package func TKAssertUnique<C, K>(
    _ collection    : () throws -> C,
    by predicate    : (C.Element) throws -> K,
    _ message       : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection, K : Hashable
{
    evaluateTKAssertUnique(
        capture:        .none,
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options,
        context:        context
    )
}
