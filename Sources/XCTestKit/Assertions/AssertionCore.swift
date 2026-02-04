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



// MARK: - Boolean (functions)

internal func evaluateXCTKAssert(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TKOptions
)
{
    let assertionKind: AssertionKind = .assert
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    .none,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    .none,
        reason:         nil,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertTrue(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TKOptions
)
{
    let assertionKind: AssertionKind = .true
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    .none,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    .none,
        reason:         nil,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertFalse(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TKOptions
)
{
    let assertionKind: AssertionKind = .false
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    .none,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if !value
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    .none,
        reason:         nil,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Boolean (macros)

internal func evaluateXCTKAssert(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions
)
{
    if result
    {
        return
    }
    
    AssertionKind.assert.fail(
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertTrue(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions
)
{
    if result
    {
        return
    }
    
    AssertionKind.true.fail(
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertFalse(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions
)
{
    if !result
    {
        return
    }
    
    AssertionKind.false.fail(
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



// MARK: - Nil and non-nil

internal func evaluateXCTKAssertNil(
    captureKind : ExprCaptureKind,
    expr        : () throws -> Any?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
)
{
    let assertionKind: AssertionKind = .nil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value == nil
    {
        return
    }
    
    switch captureKind
    {
        case .none:
            
            assertionKind.fail(
                captureKind:    captureKind,
                reason:         nil,
                message:        message,
                file:           file,
                line:           line
            )
            
        case
            .single,
            .double:
            
            assertionKind.fail(
                captureKind:    captureKind,
                actual:         String(describing: value!),
                message:        message,
                file:           file,
                line:           line
            )
    }
}



internal func evaluateXCTKAssertNotNil(
    captureKind : ExprCaptureKind,
    expr        : () throws -> Any?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
)
{
    let assertionKind: AssertionKind = .notNil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value) = result
    else
    {
        return
    }
    
    if value != nil
    {
        return
    }
    
    switch captureKind
    {
        case .none:
            
            assertionKind.fail(
                captureKind:    captureKind,
                reason:         nil,
                message:        message,
                file:           file,
                line:           line
            )
            
        case
            .single,
            .double:
            
            assertionKind.fail(
                captureKind:    captureKind,
                actual:         nil,
                message:        message,
                file:           file,
                line:           line
            )
    }
}



internal func evaluateXCTKUnwrap<T>(
    captureKind : ExprCaptureKind,
    expr        : () throws -> T?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) throws -> T
{
    let assertionKind: AssertionKind = .unwrap
    
    let result: Result<T?, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    switch result
    {
        case let .success(value):
            
            if let value
            {
                return value
            }
            
            switch captureKind
            {
                case .none:
                    
                    assertionKind.fail(
                        captureKind:    captureKind,
                        reason:         nil,
                        message:        message,
                        file:           file,
                        line:           line
                    )
                    
                case
                    .single,
                    .double:
                    
                    assertionKind.fail(
                        captureKind:    captureKind,
                        actual:         nil,
                        message:        message,
                        file:           file,
                        line:           line
                    )
            }
            
            throw XCTKUnwrapError()
            
        case let .failure(error):
            
            throw error
    }
}



// MARK: - Equality and inequality

internal func evaluateXCTKAssertEqual<T>(
    captureKind : ExprCaptureKind,
    expected    : () throws -> T,
    actual      : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Equatable
{
    let assertionKind: AssertionKind = .equal
    
    let expResult: Result<T, Error> = evaluateExpr(
        expected,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(exp) = expResult
    else
    {
        return
    }
    
    
    
    let actResult: Result<T, Error> = evaluateExpr(
        actual,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(act) = actResult
    else
    {
        return
    }
    
    
    
    if exp == act
    {
        return
    }
    
    
    
    guard options.diffEnabled
    else
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "(\(quote(exp))) is not equal to (\(quote(act)))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    let diff: DiffNode = Comparator.computeDiff(
        expected:   exp,
        actual:     act,
        options:    options.diffOptions
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        diff:           diff,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Equatable
{
    let assertionKind: AssertionKind = .notEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 != value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "both values equal (\(quote(value1)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
)
{
    let assertionKind   : AssertionKind     = .identical
    let value1          : AnyObject?
    
    do
    {
        value1 = try expr1()
    }
    catch
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "threw error \(quote(error))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    
    
    let value2: AnyObject?
    
    do
    {
        value2 = try expr2()
    }
    catch
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "threw error \(quote(error))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    
    
    if value1 === value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not identical"
                        + " to (\(quote(value2)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertNotIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
)
{
    let assertionKind   : AssertionKind     = .notIdentical
    let value1          : AnyObject?
    
    do
    {
        value1 = try expr1()
    }
    catch
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "threw error \(quote(error))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    
    
    let value2: AnyObject?
    
    do
    {
        value2 = try expr2()
    }
    catch
    {
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "threw error \(quote(error))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    
    
    if value1 !== value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "both values are identical (\(quote(value1)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not equal to (\(quote(value2)))"
                        + " +/- (\(quote(accuracy)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Numeric
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not equal to (\(quote(value2)))"
                        + " +/- (\(quote(accuracy)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "both values equal (\(quote(value1)))"
                        + " +/- (\(quote(accuracy)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Numeric
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = areEqual(
        value1,
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "both values equal (\(quote(value1)))"
                        + " +/- (\(quote(accuracy)))",
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Comparable

internal func evaluateXCTKAssertGreaterThan<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 > value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not greater than"
                        + " (\(quote(value2)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertGreaterThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 >= value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not greater than or equal to"
                        + " (\(quote(value2)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertLessThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 <= value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not less than or equal to"
                        + " (\(quote(value2)))",
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertLessThan<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    if value1 < value2
    {
        return
    }
    
    assertionKind.fail(
        captureKind:    captureKind,
        reason:         "(\(quote(value1))) is not less than"
                        + " (\(quote(value2)))",
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Error

internal func evaluateXCTKAssertThrowsError<T>(
    captureKind     : ExprCaptureKind,
    expr            : () throws -> T,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TKOptions,
    errorHandler    : (any Error) -> Void
)
{
    let assertionKind: AssertionKind = .throwsError
    
    let result: Result<T, Error> = evaluateExpr(
        expr,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line,
        errorHandler:   errorHandler
    )
    
    if case .failure = result
    {
        return
    }
    
    switch captureKind
    {
        case .none:
            
            assertionKind.fail(
                captureKind:    captureKind,
                reason:         nil,
                message:        message,
                file:           file,
                line:           line
            )
            
        case
            .single,
            .double:
            
            assertionKind.fail(
                captureKind:    captureKind,
                actual:         nil,
                message:        message,
                file:           file,
                line:           line
            )
    }
}



internal func evaluateXCTKAssertNoThrow<T>(
    captureKind : ExprCaptureKind,
    expr        : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
)
{
    let assertionKind: AssertionKind = .noThrow
    
    do
    {
        _ = try expr()
    }
    catch
    {
        switch captureKind
        {
            case .none:
                
                assertionKind.fail(
                    captureKind:    captureKind,
                    reason:         "threw error \(quote(error))",
                    message:        message,
                    file:           file,
                    line:           line
                )
                
            case
                .single,
                .double:
                
                assertionKind.fail(
                    captureKind:    captureKind,
                    actual:         String(describing: error),
                    message:        message,
                    file:           file,
                    line:           line
                )
        }
    }
}



// MARK: - Predicate

internal func evaluateXCTKAssertAllSatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyAll
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if iterationResult.allFailedCount == 0
    {
        return
    }
    
    
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:              .elementsFailed(iterationResult.allFailed),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertAnySatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyAny
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount > 0,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .any,
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertNoneSatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyNone
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount == 0,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let failureKind: PredicateFailureKind
    
    if iterationResult.matchedCount > 0
    {
        failureKind = .elementsMatched(iterationResult.matchedElements)
    }
    else
    {
        let countMismatch = CountMismatch(
            expected:           .exactly(0),
            matchedIndices:     iterationResult.matchedIndices,
            errorElements:      iterationResult.errorElements
        )
        
        failureKind = .countMismatch(countMismatch)
    }
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               failureKind,
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    atLeast     : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    precondition(
        atLeast >= 0,
        "atLeast must be non-negative"
    )
    
    let assertionKind: AssertionKind = .satisfyAtLeast
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount >= atLeast,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .atLeast(atLeast),
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    atMost      : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    precondition(
        atMost >= 0,
        "atMost must be non-negative"
    )
    
    let assertionKind: AssertionKind = .satisfyAtMost
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount <= atMost,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .atMost(atMost),
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    range       : ClosedRange<Int>,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    precondition(
        range.lowerBound <= range.upperBound,
        "range.lowerBound must be less than or equal to range.upperBound"
    )
    
    precondition(
        range.lowerBound >= 0,
        "range.lowerBound must be non-negative"
    )
    
    let assertionKind: AssertionKind = .satisfyRange
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount >= range.lowerBound,
        iterationResult.matchedCount <= range.upperBound,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .range(range),
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertExactly<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    count       : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    precondition(
        count >= 0,
        "count must be non-negative"
    )
    
    let assertionKind: AssertionKind = .exactly
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount == count,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .exactly(count),
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertExactlyOne<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    let assertionKind: AssertionKind = .exactlyOne
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    let iterationResult: PredicateIterationResult = iteratePredicate(
        predicate,
        over: elements
    )
    
    if
        iterationResult.matchedCount == 1,
        iterationResult.errorCount == 0
    {
        return
    }
    
    
    
    let countMismatch = CountMismatch(
        expected:           .exactly(1),
        matchedIndices:     iterationResult.matchedIndices,
        errorElements:      iterationResult.errorElements
    )
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .countMismatch(countMismatch),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertSorted<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element, C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection
{
    let assertionKind: AssertionKind = .sorted
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    if !elements.isOrdered
    {
        let typeName = String(describing: type(of: elements))
        
        assertionKind.fail(
            captureKind:    captureKind,
            reason:         "unordered collection type (\(typeName))",
            message:        message,
            file:           file,
            line:           line
        )
        
        return
    }
    
    
    
    var iterator = elements.makeIterator()
    
    guard var previous: C.Element = iterator.next()
    else
    {
        /// Empty arrays are sorted.
        return
    }
    
    var index: Int = 0
    
    while let current: C.Element = iterator.next()
    {
        do
        {
            let inOrder: Bool = try predicate(previous, current)
            
            if !inOrder
            {
                let violation = OrderingViolation(
                    index:      index,
                    first:      DiffValue(previous),
                    second:     DiffValue(current),
                    error:      nil
                )
                
                let failure = PredicateFailure(
                    collectionCount:    elements.count,
                    kind:               .orderingViolation(violation),
                    isOrdered:          true
                )
                
                assertionKind.fail(
                    captureKind:    captureKind,
                    failure:        failure,
                    message:        message,
                    file:           file,
                    line:           line,
                    options:        options
                )
                
                return
            }
        }
        catch
        {
            let violation = OrderingViolation(
                index:      index,
                first:      DiffValue(previous),
                second:     DiffValue(current),
                error:      error.localizedDescription
            )
            
            let failure = PredicateFailure(
                collectionCount:    elements.count,
                kind:               .orderingViolation(violation),
                isOrdered:          true
            )
            
            assertionKind.fail(
                captureKind:    captureKind,
                failure:        failure,
                message:        message,
                file:           file,
                line:           line,
                options:        options
            )
            
            return
        }
        
        previous = current
        index += 1
    }
}



internal func evaluateXCTKAssertUnique<C>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection, C.Element : Hashable
{
    let assertionKind: AssertionKind = .unique
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    if
        !elements.isOrdered
        || elements.isEmpty
    {
        /// Sets are unique by definition. Dictionary elements are key-value
        /// pairs, and since dictionary keys are unique, so are the elements.
        /// Empty arrays have unique elements.
        return
    }
    
    
    
    var indicesByElement: [C.Element : [Int]] = [:]
    
    for (index, element) in elements.enumerated()
    {
        indicesByElement[element, default: []].append(index)
    }
    
    
    
    var duplicateGroups: [DuplicateGroup] = []
    
    for (element, indices) in indicesByElement
    {
        if indices.count > 1
        {
            let group = DuplicateGroup(
                value:      DiffValue(element),
                indices:    indices
            )
            
            duplicateGroups.append(group)
        }
    }
    
    if duplicateGroups.isEmpty
    {
        return
    }
    
    
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .duplicates(duplicateGroups),
        isOrdered:          true
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertUnique<C, K>(
    captureKind : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> K,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TKOptions
) where C : Collection, K : Hashable
{
    let assertionKind: AssertionKind = .uniqueByKey
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertionKind:  assertionKind,
        captureKind:    captureKind,
        message:        message,
        file:           file,
        line:           line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    if elements.isEmpty
    {
        /// Empty collections have unique elements.
        return
    }
    
    
    
    var elementsByKey: [K : [IndexedElement]] = [:]
    
    for (index, element) in elements.enumerated()
    {
        let key: K
        
        do
        {
            key = try predicate(element)
        }
        catch
        {
            assertionKind.fail(
                captureKind:    captureKind,
                reason:         "threw error \(quote(error)) at index \(index)",
                message:        message,
                file:           file,
                line:           line
            )
            
            return
        }
        
        let indexedElement = IndexedElement(
            index:  index,
            value:  DiffValue(element)
        )
        
        elementsByKey[key, default: []].append(indexedElement)
    }
    
    
    
    var duplicateGroups: [DuplicateKeyGroup] = []
    
    for (extractedKey, indexedElements) in elementsByKey
    {
        if indexedElements.count > 1
        {
            let group = DuplicateKeyGroup(
                key:        DiffValue(extractedKey),
                elements:   indexedElements
            )
            
            duplicateGroups.append(group)
        }
    }
    
    if duplicateGroups.isEmpty
    {
        return
    }
    
    
    
    let failure = PredicateFailure(
        collectionCount:    elements.count,
        kind:               .duplicateKeys(duplicateGroups),
        isOrdered:          elements.isOrdered
    )
    
    assertionKind.fail(
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}
