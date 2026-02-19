//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



// MARK: - Boolean

internal func _XCTKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    evaluateXCTKAssert(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertTrueMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    evaluateXCTKAssertTrue(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertFalseMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    evaluateXCTKAssertFalse(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



// MARK: - Nil and non-nil

internal func _XCTKAssertNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    evaluateXCTKAssertNil(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    evaluateXCTKAssertNotNil(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKUnwrapMacro<T>(
    expr        : @autoclosure () throws -> T?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) throws -> T
{
    return try evaluateXCTKUnwrap(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



// MARK: - Equality and inequality

internal func _XCTKAssertEqualMacro<T>(
    expected        : @autoclosure () throws -> T,
    actual          : @autoclosure () throws -> T,
    expectedText    : String,
    actualText      : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where T : Equatable
{
    evaluateXCTKAssertEqual(
        capture:    .double(expectedText, actualText),
        expected:   expected,
        actual:     actual,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Equatable
{
    evaluateXCTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    evaluateXCTKAssertIdentical(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    evaluateXCTKAssertNotIdentical(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : FloatingPoint
{
    evaluateXCTKAssertEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Numeric
{
    evaluateXCTKAssertEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : FloatingPoint
{
    evaluateXCTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Numeric
{
    evaluateXCTKAssertNotEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        accuracy:   accuracy,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



// MARK: - Comparable

internal func _XCTKAssertGreaterThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    evaluateXCTKAssertGreaterThan(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertGreaterThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    evaluateXCTKAssertGreaterThanOrEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertLessThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    evaluateXCTKAssertLessThanOrEqual(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertLessThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    evaluateXCTKAssertLessThan(
        capture:    .double(expr1Text, expr2Text),
        expr1:      expr1,
        expr2:      expr2,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



// MARK: - Error

internal func _XCTKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?,
    errorHandler    : (any Error) -> Void
)
{
    evaluateXCTKAssertThrowsError(
        capture:        .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        errorHandler:   errorHandler
    )
}



internal func _XCTKAssertNoThrowMacro<T>(
    expr        : () throws -> T,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    evaluateXCTKAssertNoThrow(
        capture:    .single(exprText),
        expr:       expr,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global
    )
}



// MARK: - Fail

internal func _XCTKFailMacro(
    message : String,
    file    : StaticString,
    line    : UInt
)
{
    XCTFail(
        message,
        file:   file,
        line:   line
    )
}



// MARK: - Predicate

internal func _XCTKAssertAllSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertAllSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertAnySatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertAnySatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNoneSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertNoneSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atLeast         : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        atLeast:        atLeast,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atMost          : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        atMost:         atMost,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        range:          range,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertExactlyMacro<C>(
    collection      : @autoclosure () throws -> C,
    count           : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertExactly(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        count:          count,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertExactlyOneMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    evaluateXCTKAssertExactlyOne(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertSortedMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element, C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?        
) where C : Collection
{
    evaluateXCTKAssertSorted(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertUniqueMacro<C>(
    collection      : @autoclosure () throws -> C,
    collectionText  : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection, C.Element : Hashable
{
    evaluateXCTKAssertUnique(
        capture:        .single(collectionText),
        collection:     collection,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertUniqueMacro<C, K>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> K,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection, K : Hashable
{
    evaluateXCTKAssertUnique(
        capture:        .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}
