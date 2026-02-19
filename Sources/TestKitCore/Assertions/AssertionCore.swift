//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



// MARK: - Boolean (functions)

package func evaluateTKAssert(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
)
{
    let assertion: AssertionKind = .assert
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertTrue(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
)
{
    let assertion: AssertionKind = .true
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertFalse(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
)
{
    let assertion: AssertionKind = .false
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    .none,
        reason:     nil,
        message:    message,
        file:       file,
        line:       line
    )
}



// MARK: - Boolean (macros)

package func evaluateTKAssert(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    if result
    {
        return
    }
    
    AssertionKind.assert.fail(
        context:        context,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



package func evaluateTKAssertTrue(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    if result
    {
        return
    }
    
    AssertionKind.true.fail(
        context:        context,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}



package func evaluateTKAssertFalse(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    context         : FailureContext
)
{
    if !result
    {
        return
    }
    
    AssertionKind.false.fail(
        context:        context,
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

package func evaluateTKAssertNil(
    capture : ExprCaptureKind,
    expr    : () throws -> Any?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
)
{
    let assertion: AssertionKind = .nil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
                context:    context,
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
                context:    context,
                capture:    capture,
                actual:     String(describing: value!),
                message:    message,
                file:       file,
                line:       line
            )
    }
}



package func evaluateTKAssertNotNil(
    capture : ExprCaptureKind,
    expr    : () throws -> Any?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
)
{
    let assertion: AssertionKind = .notNil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
                context:    context,
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
                context:    context,
                capture:    capture,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



package func evaluateTKUnwrap<T>(
    capture : ExprCaptureKind,
    expr    : () throws -> T?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) throws -> T
{
    let assertion: AssertionKind = .unwrap
    
    let result: Result<T?, Error> = evaluateExpr(
        expr,
        assertion:  assertion,
        context:    context,
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
                        context:    context,
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
                        context:    context,
                        capture:    capture,
                        actual:     nil,
                        message:    message,
                        file:       file,
                        line:       line
                    )
            }
            
            throw UnwrapError(context.framework)
            
        case let .failure(error):
            
            throw error
    }
}



// MARK: - Equality and inequality

package func evaluateTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expected    : () throws -> T,
    actual      : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Equatable
{
    let assertion: AssertionKind = .equal
    
    let expResult: Result<T, Error> = evaluateExpr(
        expected,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
            context:    context,
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
        context:    context,
        capture:    capture,
        diff:       diff,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertNotEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) where T : Equatable
{
    let assertion: AssertionKind = .notEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertIdentical(
    capture : ExprCaptureKind,
    expr1   : () throws -> AnyObject?,
    expr2   : () throws -> AnyObject?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
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
            context:    context,
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
            context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not identical to (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertNotIdentical(
    capture : ExprCaptureKind,
    expr1   : () throws -> AnyObject?,
    expr2   : () throws -> AnyObject?,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
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
            context:    context,
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
            context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "both values are identical (\(quote(value1)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : FloatingPoint
{
    let assertion: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Numeric
{
    let assertion: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not equal to (\(quote(value2)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertNotEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : FloatingPoint
{
    let assertion: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertNotEqual<T>(
    capture     : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where T : Numeric
{
    let assertion: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "both values equal (\(quote(value1)))"
                    + " +/- (\(quote(accuracy)))",
        message:    message,
        file:       file,
        line:       line
    )
}



// MARK: - Comparable

package func evaluateTKAssertGreaterThan<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) where T : Comparable
{
    let assertion: AssertionKind = .greaterThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not greater than"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertGreaterThanOrEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) where T : Comparable
{
    let assertion: AssertionKind = .greaterThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not greater than or equal to"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertLessThanOrEqual<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) where T : Comparable
{
    let assertion: AssertionKind = .lessThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not less than or equal to"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



package func evaluateTKAssertLessThan<T>(
    capture : ExprCaptureKind,
    expr1   : () throws -> T,
    expr2   : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
) where T : Comparable
{
    let assertion: AssertionKind = .lessThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertion,
        context:    context,
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
        context:    context,
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
        context:    context,
        capture:    capture,
        reason:     "(\(quote(value1))) is not less than"
                    + " (\(quote(value2)))",
        message:    message,
        file:       file,
        line:       line
    )
}



// MARK: - Error

package func evaluateTKAssertThrowsError<T>(
    capture         : ExprCaptureKind,
    expr            : () throws -> T,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions,
    errorHandler    : (any Error) -> Void,
    context         : FailureContext
)
{
    let assertion: AssertionKind = .throwsError
    
    let result: Result<T, Error> = evaluateExpr(
        expr,
        assertion:      assertion,
        context:    context,
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
                context:    context,
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
                context:    context,
                capture:    capture,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



package func evaluateTKAssertNoThrow<T>(
    capture : ExprCaptureKind,
    expr    : () throws -> T,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : TestOptions,
    context : FailureContext
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
                    context:    context,
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
                    context:    context,
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

package func evaluateTKAssertAllSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection
{
    let assertion: AssertionKind = .satisfyAll
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertAnySatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection
{
    let assertion: AssertionKind = .satisfyAny
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertNoneSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection
{
    let assertion: AssertionKind = .satisfyNone
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    atLeast     : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
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
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    atMost      : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
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
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertSatisfy<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    range       : ClosedRange<Int>,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
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
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertExactly<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    count       : Int,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
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
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertExactlyOne<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection
{
    let assertion: AssertionKind = .exactlyOne
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertSorted<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element, C.Element) throws -> Bool,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection
{
    let assertion: AssertionKind = .sorted
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
            context:    context,
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
                    context:    context,
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
                context:    context,
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



package func evaluateTKAssertUnique<C>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection, C.Element : Hashable
{
    let assertion: AssertionKind = .unique
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



package func evaluateTKAssertUnique<C, K>(
    capture     : ExprCaptureKind,
    collection  : () throws -> C,
    predicate   : (C.Element) throws -> K,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions,
    context     : FailureContext
) where C : Collection, K : Hashable
{
    let assertion: AssertionKind = .uniqueByKey
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertion,
        context:    context,
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
                context:    context,
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
        context:    context,
        capture:    capture,
        failure:    failure,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
}



// MARK: - Support

/// Evaluates the given expression.
///
/// - Important: This fails the assertion if the given expression throws an
/// error when called. This does not apply to ``AssertionKind/throwsErrow``.
/// In this single case, `.failure` indicates that the expresion threw an
/// error as expected, and the assertion passed. For all other cases,
/// `.failure`indicates that the expression unexpectedly threw an error, and
/// the assertion failed.
///
/// - Parameters:
///   - expr: The expression to evaluate.
///   - assertion: The assertion kind.
///   - context: The assertion failure context.
///   - capture: The kind of captured assertion expression.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - errorHandler: An optional handler for errors thrown by `expr`.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
private func evaluateExpr<T>(
    _ expr          : () throws -> T,
    assertion       : AssertionKind,
    context         : FailureContext,
    capture         : ExprCaptureKind,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    errorHandler    : (any Error) -> Void   = { _ in }
) -> Result<T, Error>
{
    do
    {
        return .success(try expr())
    }
    catch
    {
        if assertion == .throwsError
        {
            errorHandler(error)
        }
        else
        {
            assertion.fail(
                context:    context,
                capture:    capture,
                reason:     "threw error \(quote(error))",
                message:    message,
                file:       file,
                line:       line
            )
        }
        
        return .failure(error)
    }
}



/// Evaluates the given collection.
///
/// - Important: This fails the assertion if the given collection expression
/// throws an error when called.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - assertion: The assertion kind.
///   - context: The assertion failure context.
///   - capture: The kind of captured assertion expression.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given collection expression.
private func evaluateCollection<C>(
    _ collection    : () throws -> C,
    assertion       : AssertionKind,
    context         : FailureContext,
    capture         : ExprCaptureKind,
    message         : () -> String,
    file            : StaticString,
    line            : UInt
) -> Result<C, Error> where C : Collection
{
    do
    {
        return .success(try collection())
    }
    catch
    {
        assertion.fail(
            context:    context,
            capture:    capture,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line
        )
        
        return .failure(error)
    }
}
