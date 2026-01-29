//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore



// MARK: - ExprCaptureKind

/// The kind of captured assertion expression.
internal enum ExprCaptureKind: Equatable, Sendable
{
    /// A function assertion with no expression capture.
    case none
    
    /// A single-expression macro assertion.
    /// - Parameter text: The expression source text.
    case single(
        _ text: String
    )
    
    /// A double-expression macro assertion.
    /// - Parameters:
    ///   - text1: The source text of the first expression.
    ///   - text2: The source text of the second expression.
    case double(
        _ text1: String,
        _ text2: String
    )
}



// MARK: - Boolean (functions)

internal func evaluateXCTKAssert(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt
)
{
    let assertionKind: AssertionKind = .assert
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
    
    failAssertion(
        kind:       assertionKind,
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
    line    : UInt
)
{
    let assertionKind: AssertionKind = .true
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
    
    failAssertion(
        kind:       assertionKind,
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
    line    : UInt
)
{
    let assertionKind: AssertionKind = .false
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
    
    failAssertion(
        kind:       assertionKind,
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
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt
)
{
    if result
    {
        return
    }
    
    failAssertion(
        kind:           .assert,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertTrue(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt
)
{
    if result
    {
        return
    }
    
    failAssertion(
        kind:           .true,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



internal func evaluateXCTKAssertFalse(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt
)
{
    if !result
    {
        return
    }
    
    failAssertion(
        kind:           .false,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line
    )
}



// MARK: - Nil and non-nil

internal func evaluateXCTKAssertNil(
    captureKind : ExprCaptureKind,
    expr        : () throws -> Any?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
)
{
    let assertionKind: AssertionKind = .nil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     String(describing: value!),
                message:    message,
                file:       file,
                line:       line
            )
            
        case .double:
            
            break
    }
}



internal func evaluateXCTKAssertNotNil(
    captureKind : ExprCaptureKind,
    expr        : () throws -> Any?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
)
{
    let assertionKind: AssertionKind = .notNil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .double:
            
            break
    }
}



internal func evaluateXCTKUnwrap<T>(
    captureKind : ExprCaptureKind,
    expr        : () throws -> T?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) throws -> T
{
    let assertionKind: AssertionKind = .unwrap
    
    let result: Result<T?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
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
            
            switch captureKind
            {
                case .none:
                    
                    failAssertion(
                        kind:       assertionKind,
                        reason:     nil,
                        message:    message,
                        file:       file,
                        line:       line
                    )
                    
                case let .single(text):
                    
                    failAssertion(
                        kind:       assertionKind,
                        exprText:   text,
                        actual:     nil,
                        message:    message,
                        file:       file,
                        line:       line
                    )
                    
                case .double:
                    
                    break
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
    options     : XCTKOptions?
) where T : Equatable
{
    let assertionKind: AssertionKind = .equal
    
    let expResult: Result<T, Error> = evaluateExpr(
        expected,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    
    
    let opts: XCTKOptions = options ?? XCTKConfig.global
    
    guard opts.diffEnabled
    else
    {
        failAssertion(
            kind:       assertionKind,
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
        options:    opts.diffOptions
    )
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                diff:       diff,
                options:    opts.formatOptions,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(expText, actText):
            
            failAssertion(
                kind:           assertionKind,
                expectedText:   expText,
                actualText:     actText,
                diff:           diff,
                options:        opts.formatOptions,
                message:        message,
                file:           file,
                line:           line
            )
    }
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Equatable
{
    let assertionKind: AssertionKind = .notEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    let reason: String = "both values equal (\(quote(value1)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
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
        failAssertion(
            kind:       assertionKind,
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
        failAssertion(
            kind:       assertionKind,
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
    
    let reason: String
        = "(\(quote(value1))) is not identical to (\(quote(value2)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertNotIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
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
        failAssertion(
            kind:       assertionKind,
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
        failAssertion(
            kind:       assertionKind,
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
    
    let reason: String = "both values are identical (\(quote(value1)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line
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
    
    let reason: String
        = "(\(quote(value1))) is not equal to (\(quote(value2)))"
        + " +/- (\(quote(accuracy)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Numeric
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line
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
    
    let reason: String
        = "(\(quote(value1))) is not equal to (\(quote(value2)))"
        + " +/- (\(quote(accuracy)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line
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
    
    let reason: String = "both values equal (\(quote(value1)))"
        + " +/- (\(quote(accuracy)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    accuracy    : T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Numeric
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line
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
    
    let reason: String = "both values equal (\(quote(value1)))"
        + " +/- (\(quote(accuracy)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



// MARK: - Comparable

internal func evaluateXCTKAssertGreaterThan<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    let reason: String = "(\(quote(value1))) is not greater than"
        + " (\(quote(value2)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertGreaterThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    let reason: String = "(\(quote(value1))) is not greater than or equal to"
        + " (\(quote(value2)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertLessThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    let reason: String = "(\(quote(value1))) is not less than or equal to"
        + " (\(quote(value2)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



internal func evaluateXCTKAssertLessThan<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
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
        assertion:  assertionKind,
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
    
    let reason: String = "(\(quote(value1))) is not less than"
        + " (\(quote(value2)))"
    
    switch captureKind
    {
        case .none:
            
            failAssertion(
                kind:       assertionKind,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .single:
            
            break
            
        case let .double(text1, text2):
            
            failAssertion(
                kind:       assertionKind,
                expr1Text:  text1,
                expr2Text:  text2,
                reason:     reason,
                message:    message,
                file:       file,
                line:       line
            )
    }
}



// MARK: - Error

internal func evaluateXCTKAssertThrowsError<T>(
    captureKind     : ExprCaptureKind,
    expr            : () throws -> T,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    errorHandler    : (any Error) -> Void
)
{
    let assertionKind: AssertionKind = .throwsError
    
    let result: Result<T, Error> = evaluateExpr(
        expr,
        assertion:      assertionKind,
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
            
            failAssertion(
                kind:       assertionKind,
                reason:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line
            )
            
        case .double:
            
            break
    }
}



internal func evaluateXCTKAssertNoThrow<T>(
    captureKind : ExprCaptureKind,
    expr        : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt
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
                
                failAssertion(
                    kind:       assertionKind,
                    reason:     "threw error \(quote(error))",
                    message:    message,
                    file:       file,
                    line:       line
                )
                
            case let .single(text):
                
                failAssertion(
                    kind:       assertionKind,
                    exprText:   text,
                    actual:     String(describing: error),
                    message:    message,
                    file:       file,
                    line:       line
                )
                
            case .double:
                
                break
        }
    }
}
