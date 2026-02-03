//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import XCTest



// MARK: - Boolean

internal func _XCTKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [TKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions?
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
    evaluated       : [TKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions?
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
    evaluated       : [TKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions?
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
    options     : TKOptions?
)
{
    evaluateXCTKAssertNil(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKAssertNotNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions?
)
{
    evaluateXCTKAssertNotNil(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



internal func _XCTKUnwrapMacro<T>(
    expr        : @autoclosure () throws -> T?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions?
) throws -> T
{
    return try evaluateXCTKUnwrap(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options         : TKOptions?
) where T : Equatable
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expectedText, actualText),
        expected:       expected,
        actual:         actual,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Equatable
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
)
{
    evaluateXCTKAssertIdentical(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
)
{
    evaluateXCTKAssertNotIdentical(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : FloatingPoint
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Numeric
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : FloatingPoint
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Numeric
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Comparable
{
    evaluateXCTKAssertGreaterThan(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Comparable
{
    evaluateXCTKAssertGreaterThanOrEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Comparable
{
    evaluateXCTKAssertLessThanOrEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options     : TKOptions?
) where T : Comparable
{
    evaluateXCTKAssertLessThan(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}



// MARK: - Error

internal func _XCTKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions?,
    errorHandler    : (any Error) -> Void
)
{
    evaluateXCTKAssertThrowsError(
        captureKind:    .single(exprText),
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
    options     : TKOptions?
)
{
    evaluateXCTKAssertNoThrow(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertAllSatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertAnySatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertNoneSatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertSatisfy(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertExactly(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection
{
    evaluateXCTKAssertExactlyOne(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?        
) where C : Collection
{
    evaluateXCTKAssertSorted(
        captureKind:    .double(collectionText, predicateText),
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
    options         : TKOptions?
) where C : Collection, C.Element : Hashable
{
    evaluateXCTKAssertUnique(
        captureKind:    .single(collectionText),
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
    options         : TKOptions?
) where C : Collection, K : Hashable
{
    evaluateXCTKAssertUnique(
        captureKind:    .double(collectionText, predicateText),
        collection:     collection,
        predicate:      predicate,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global
    )
}
