//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Boolean

package func TKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssert(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertTrueMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertTrue(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertFalseMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    evaluateTKAssertFalse(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



// MARK: - Nil and non-nil

package func TKAssertNilMacro(
    expr        : () throws -> Any?,
    exprText    : String,
    message     : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options     : TestOptions,
    context     : FailureContext
)
{
    evaluateTKAssertNil(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertNotNilMacro(
    expr        : () throws -> Any?,
    exprText    : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
)
{
    evaluateTKAssertNotNil(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKUnwrapMacro<T>(
    expr        : () throws -> T?,
    exprText    : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) throws -> T
{
    return try evaluateTKUnwrap(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Equality and inequality

package func TKAssertEqualMacro<T>(
    expected        : () throws -> T,
    actual          : () throws -> T,
    expectedText    : String,
    actualText      : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context     : FailureContext
) where T : Equatable
{
    evaluateTKAssertEqual(
        capture:    .double(expectedText, actualText),
        expected:   expected,
        actual:     actual,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Equatable
{
    evaluateTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertIdenticalMacro(
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
)
{
    evaluateTKAssertIdentical(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertNotIdenticalMacro(
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
)
{
    evaluateTKAssertNotIdentical(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : FloatingPoint
{
    evaluateTKAssertEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Numeric
{
    evaluateTKAssertEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : FloatingPoint
{
    evaluateTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertNotEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Numeric
{
    evaluateTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Comparable

package func TKAssertGreaterThanMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Comparable
{
    evaluateTKAssertGreaterThan(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertGreaterThanOrEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Comparable
{
    evaluateTKAssertGreaterThanOrEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertLessThanOrEqualMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Comparable
{
    evaluateTKAssertLessThanOrEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



package func TKAssertLessThanMacro<T>(
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Comparable
{
    evaluateTKAssertLessThan(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Error

package func TKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    errorHandler    : (any Error) -> Void,
    context         : FailureContext
)
{
    evaluateTKAssertThrowsError(
        capture:        .single(exprText),
        expr:           expr,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        errorHandler:   errorHandler,
        context:        context
    )
}



package func TKAssertNoThrowMacro<T>(
    expr        : () throws -> T,
    exprText    : String,
    message     : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    context     : FailureContext
)
{
    evaluateTKAssertNoThrow(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        context:    context
    )
}



// MARK: - Fail

package func TKFailMacro(
    message : String,
    fileID  : StaticString,
    file    : StaticString,
    line    : UInt,
    column  : UInt,
    context : FailureContext
)
{
    context.emit(
        message,
        fileID,
        file,
        line,
        column
    )
}



// MARK: - Predicate

package func TKAssertAllSatisfyMacro<C>(
    collection      : () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertAllSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertAnySatisfyMacro<C>(
    collection      : () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertAnySatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertNoneSatisfyMacro<C>(
    collection      : () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertNoneSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfyMacro<C>(
    collection      : () throws -> C,
    atLeast         : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        atLeast:        atLeast,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfyMacro<C>(
    collection      : () throws -> C,
    atMost          : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        atMost:         atMost,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertSatisfyMacro<C>(
    collection      : () throws -> C,
    range           : ClosedRange<Int>,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        range:          range,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertExactlyMacro<C>(
    collection      : () throws -> C,
    count           : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertExactly(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        count:          count,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertExactlyOneMacro<C>(
    collection      : () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertExactlyOne(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertSortedMacro<C>(
    collection      : () throws -> C,
    predicate       : (C.Element, C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection
{
    evaluateTKAssertSorted(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertUniqueMacro<C>(
    collection      : () throws -> C,
    collectionText  : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection, C.Element : Hashable
{
    evaluateTKAssertUnique(
        capture:        .single(collectionText),
        collection:     collection,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}



package func TKAssertUniqueMacro<C, K>(
    collection      : () throws -> C,
    predicate       : (C.Element) throws -> K,
    collectionText  : String,
    predicateText   : String,
    message         : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    context         : FailureContext
) where C : Collection, K : Hashable
{
    evaluateTKAssertUnique(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options,
        context:        context
    )
}
