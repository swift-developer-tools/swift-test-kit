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
    options : TestOptions
)
{
    let assertion: AssertionKind = .assert
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    .none,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertTrue(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion: AssertionKind = .true
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    .none,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertFalse(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion: AssertionKind = .false
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    .none,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
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
    options         : TestOptions
)
{
    if result
    {
        return
    }
    
    AssertionKind.assert.fail(
        context:        failureContext,
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
    options         : TestOptions
)
{
    if result
    {
        return
    }
    
    AssertionKind.true.fail(
        context:        failureContext,
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
    options         : TestOptions
)
{
    if !result
    {
        return
    }
    
    AssertionKind.false.fail(
        context:        failureContext,
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
    capture : ExprCaptureKind,
    expr    : () throws -> Any?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion: AssertionKind = .nil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    switch capture
    {
        case .none:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case
            .single,
            .double:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                actual:     String(describing: value!),
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertNotNil(
    capture : ExprCaptureKind,
    expr    : () throws -> Any?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion: AssertionKind = .notNil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    switch capture
    {
        case .none:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case
            .single,
            .double:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKUnwrap<T>(
    capture : ExprCaptureKind,
    expr    : () throws -> T?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) throws -> T
{
    let assertion: AssertionKind = .unwrap
    
    let result: Result<T?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    switch result
    {
        case let .success(value):
            
            if let value
            {
                return value
            }
            
            switch capture
            {
                case .none:
                    
                    assertion.fail(
                        context:    failureContext,
                        capture:    capture,
                        reason:     nil,
                        message:    message,
                        file:       file,
                        line:       line
                    )
                    
                case
                    .single,
                    .double:
                    
                    assertion.fail(
                        context:    failureContext,
                        capture:    capture,
                        actual:     nil,
                        message:    message,
                        file:       file,
                        line:       line
                    )
            }
            
            throw XCTKUnwrapError()
            
        case let .failure(error):
            
            throw error
    }
}



// MARK: - Equality and inequality

internal func evaluateXCTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expected    : () throws -> T,
    actual      : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where T : Equatable
{
    let assertion: AssertionKind = .equal
    
    let expResult: Result<T, Error> = evaluateExpr(
        expected,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(exp) = expResult
    else
    {
        return
    }
    
    
    
    let actResult: Result<T, Error> = evaluateExpr(
        actual,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "(\(quote(exp))) is not equal to (\(quote(act)))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    let diff: DiffNode = Comparator.computeDiff(
        expected:   exp,
        actual:     act,
        options:    options.diffOptions
    )
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        diff:       diff,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) where T : Equatable
{
    let assertion: AssertionKind = .notEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertIdentical(
    capture : ExprCaptureKind,
    expr1   : () throws -> AnyObject?,
    expr2   : () throws -> AnyObject?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion   : AssertionKind     = .identical
    let value1      : AnyObject?
    
    do
    {
        value1 = try expr1()
    }
    catch
    {
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
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
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    if value1 === value2
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not identical to (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertNotIdentical(
    capture : ExprCaptureKind,
    expr1   : () throws -> AnyObject?,
    expr2   : () throws -> AnyObject?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion   : AssertionKind     = .notIdentical
    let value1      : AnyObject?
    
    do
    {
        value1 = try expr1()
    }
    catch
    {
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
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
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return
    }
    
    
    
    if value1 !== value2
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "both values are identical (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where T : FloatingPoint
{
    let assertion: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = value1.equals(
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where T : Numeric
{
    let assertion: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = value1.equals(
        value2,
        accuracy: accuracy
    )
    
    if equal
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where T : FloatingPoint
{
    let assertion: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = value1.equals(
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertNotEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where T : Numeric
{
    let assertion: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value2) = result2
    else
    {
        return
    }
    
    
    
    let equal: Bool = value1.equals(
        value2,
        accuracy: accuracy
    )
    
    if !equal
    {
        return
    }
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



// MARK: - Comparable

internal func evaluateXCTKAssertGreaterThan<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) where T : Comparable
{
    let assertion: AssertionKind = .greaterThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not greater than"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertGreaterThanOrEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) where T : Comparable
{
    let assertion: AssertionKind = .greaterThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not greater than or equal to"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertLessThanOrEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) where T : Comparable
{
    let assertion: AssertionKind = .lessThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not less than or equal to"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



internal func evaluateXCTKAssertLessThan<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
) where T : Comparable
{
    let assertion: AssertionKind = .lessThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(value1) = result1
    else
    {
        return
    }
    
    
    
    let result2: Result<T, Error> = evaluateExpr(
        expr2,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        reason:     "(\(quote(value1))) is not less than"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



// MARK: - Error

internal func evaluateXCTKAssertThrowsError<T>(
    capture         : ExprCaptureKind,
    expr            : () throws -> T,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    errorHandler    : (any Error) -> Void
)
{
    let assertion: AssertionKind = .throwsError
    
    let result: Result<T, Error> = evaluateExpr(
        expr,
        assertion:      assertion,
        capture:        capture,
        message:        message,
        file:           file,
        line:           line,
        errorHandler:   errorHandler
    )
    
    if case .failure = result
    {
        return
    }
    
    switch capture
    {
        case .none:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case
            .single,
            .double:
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertNoThrow<T>(
    capture : ExprCaptureKind,
    expr    : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions
)
{
    let assertion: AssertionKind = .noThrow
    
    do
    {
        _ = try expr()
    }
    catch
    {
        switch capture
        {
            case .none:
                
                assertion.fail(
                    context:    failureContext,
                    capture:    capture,
                    reason:     "threw error \(quote(error))",
                    message:    message,
                    file:       file,
                    line:       line
                )
                
            case
                .single,
                .double:
                
                assertion.fail(
                    context:    failureContext,
                    capture:    capture,
                    actual:     String(describing: error),
                    message:    message,
                    file:       file,
                    line:       line
                )
        }
    }
}



// MARK: - Predicate

internal func evaluateXCTKAssertAllSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    let assertion: AssertionKind = .satisfyAll
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertAnySatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    let assertion: AssertionKind = .satisfyAny
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertNoneSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    let assertion: AssertionKind = .satisfyNone
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    atLeast     : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    precondition(
        atLeast >= 0,
        "atLeast must be non-negative"
    )
    
    let assertion: AssertionKind = .satisfyAtLeast
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    atMost      : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    precondition(
        atMost >= 0,
        "atMost must be non-negative"
    )
    
    let assertion: AssertionKind = .satisfyAtMost
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    range       : ClosedRange<Int>,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
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
    
    let assertion: AssertionKind = .satisfyRange
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertExactly<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    count       : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    precondition(
        count >= 0,
        "count must be non-negative"
    )
    
    let assertion: AssertionKind = .exactly
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertExactlyOne<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    let assertion: AssertionKind = .exactlyOne
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertSorted<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element, C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection
{
    let assertion: AssertionKind = .sorted
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    if !elements.isOrdered
    {
        let typeName = String(describing: type(of: elements))
        
        assertion.fail(
            context:    failureContext,
            capture:    capture,
            reason:     "unordered collection type (\(typeName))",
            message:    message,
            file:       file,
            line:       line
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
                
                assertion.fail(
                    context:    failureContext,
                    capture:    capture,
                    failure:    failure,
                    message:    message,
                    file:       file,
                    line:       line,
                    options:    options
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
            
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                failure:    failure,
                message:    message,
                file:       file,
                line:       line,
                options:    options
            )
            
            return
        }
        
        previous = current
        index += 1
    }
}



internal func evaluateXCTKAssertUnique<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection, C.Element : Hashable
{
    let assertion: AssertionKind = .unique
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertUnique<C, K>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> K,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions
) where C : Collection, K : Hashable
{
    let assertion: AssertionKind = .uniqueByKey
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        capture:    capture,
        message:    message,
        file:       file,
        line:       line
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
            assertion.fail(
                context:    failureContext,
                capture:    capture,
                reason:     "threw error \(quote(error)) at index \(index)",
                message:    message,
                file:       file,
                line:       line
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
    
    assertion.fail(
        context:    failureContext,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}
