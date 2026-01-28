//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



// MARK: - Boolean

internal func _XCTKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt
)
{
    evaluateXCTKAssert(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertTrueMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt
)
{
    evaluateXCTKAssertTrue(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertFalseMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt
)
{
    evaluateXCTKAssertFalse(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Nil and non-nil

internal func _XCTKAssertNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
)
{
    evaluateXCTKAssertNil(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertNotNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
)
{
    evaluateXCTKAssertNotNil(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKUnwrapMacro<T>(
    expr        : @autoclosure () throws -> T?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
) throws -> T
{
    return try evaluateXCTKUnwrap(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line
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
    options         : XCTKOptions?
) where T : Equatable
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expectedText, actualText),
        expected:       expected,
        actual:         actual,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
) where T : Equatable
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
)
{
    evaluateXCTKAssertIdentical(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertNotIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
)
{
    evaluateXCTKAssertNotIdentical(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
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
    line        : UInt
) where T : FloatingPoint
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
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
    line        : UInt
) where T : Numeric
{
    evaluateXCTKAssertEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
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
    line        : UInt
) where T : FloatingPoint
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
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
    line        : UInt
) where T : Numeric
{
    evaluateXCTKAssertNotEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        accuracy:       accuracy,
        message:        message,
        file:           file,
        line:           line
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
    line        : UInt
) where T : Comparable
{
    evaluateXCTKAssertGreaterThan(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertGreaterThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    evaluateXCTKAssertGreaterThanOrEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertLessThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    evaluateXCTKAssertLessThanOrEqual(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func _XCTKAssertLessThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    evaluateXCTKAssertLessThan(
        captureKind:    .double(expr1Text, expr2Text),
        expr1:          expr1,
        expr2:          expr2,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Error

internal func _XCTKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    errorHandler    : (any Error) -> Void
)
{
    evaluateXCTKAssertThrowsError(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line,
        errorHandler:   errorHandler
    )
}



internal func _XCTKAssertNoThrowMacro<T>(
    expr        : () throws -> T,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt
)
{
    evaluateXCTKAssertNoThrow(
        captureKind:    .single(exprText),
        expr:           expr,
        message:        message,
        file:           file,
        line:           line
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
