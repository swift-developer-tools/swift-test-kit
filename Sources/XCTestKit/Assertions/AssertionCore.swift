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
    line    : UInt,
    options : XCTKOptions?
)
{
    let assertionKind: AssertionKind = .assert
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertTrue(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
)
{
    let assertionKind: AssertionKind = .true
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
    )
}



internal func evaluateXCTKAssertFalse(
    expr    : () throws -> Bool,
    message : () -> String,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
)
{
    let assertionKind: AssertionKind = .false
    
    let result: Result<Bool, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
    line            : UInt,
    options         : XCTKOptions?
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
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertTrue(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
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
        line:           line,
        options:        options
    )
}



internal func evaluateXCTKAssertFalse(
    result          : Bool,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
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
    options     : XCTKOptions?
)
{
    let assertionKind: AssertionKind = .nil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
                line:       line,
                options:    options
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     String(describing: value!),
                message:    message,
                file:       file,
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
)
{
    let assertionKind: AssertionKind = .notNil
    
    let result: Result<Any?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
                line:       line,
                options:    options
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) throws -> T
{
    let assertionKind: AssertionKind = .unwrap
    
    let result: Result<T?, Error> = evaluateExpr(
        expr,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
                        line:       line,
                        options:    options
                    )
                    
                case let .single(text):
                    
                    failAssertion(
                        kind:       assertionKind,
                        exprText:   text,
                        actual:     nil,
                        message:    message,
                        file:       file,
                        line:       line,
                        options:    options
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
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
            line:       line,
            options:    options
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
                message:    message,
                file:       file,
                line:       line,
                options:    options
            )
            
        case .single:
            
            break
            
        case let .double(expText, actText):
            
            failAssertion(
                kind:           assertionKind,
                expectedText:   expText,
                actualText:     actText,
                diff:           diff,
                message:        message,
                file:           file,
                line:           line,
                options:        options
            )
    }
}



internal func evaluateXCTKAssertNotEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
) where T : Equatable
{
    let assertionKind: AssertionKind = .notEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
            )
    }
}



internal func evaluateXCTKAssertIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
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
            line:       line,
            options:    options
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
            line:       line,
            options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
            )
    }
}



internal func evaluateXCTKAssertNotIdentical(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> AnyObject?,
    expr2       : () throws -> AnyObject?,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
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
            line:       line,
            options:    options
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
            line:       line,
            options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) where T : Numeric
{
    let assertionKind: AssertionKind = .equalWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) where T : FloatingPoint
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) where T : Numeric
{
    let assertionKind: AssertionKind = .notEqualWithAccuracy
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
            )
    }
}



internal func evaluateXCTKAssertGreaterThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
) where T : Comparable
{
    let assertionKind: AssertionKind = .greaterThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
            )
    }
}



internal func evaluateXCTKAssertLessThanOrEqual<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThanOrEqual
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
            )
    }
}



internal func evaluateXCTKAssertLessThan<T>(
    captureKind : ExprCaptureKind,
    expr1       : () throws -> T,
    expr2       : () throws -> T,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
) where T : Comparable
{
    let assertionKind: AssertionKind = .lessThan
    
    let result1: Result<T, Error> = evaluateExpr(
        expr1,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        line:       line,
        options:    options
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
                line:       line,
                options:    options
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
                line:       line,
                options:    options
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
    options         : XCTKOptions?,
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
        options:        options,
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
                line:       line,
                options:    options
            )
            
        case let .single(text):
            
            failAssertion(
                kind:       assertionKind,
                exprText:   text,
                actual:     nil,
                message:    message,
                file:       file,
                line:       line,
                options:    options
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
    line        : UInt,
    options     : XCTKOptions?
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
                    line:       line,
                    options:    options
                )
                
            case let .single(text):
                
                failAssertion(
                    kind:       assertionKind,
                    exprText:   text,
                    actual:     String(describing: error),
                    message:    message,
                    file:       file,
                    line:       line,
                    options:    options
                )
                
            case .double:
                
                break
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
    options     : XCTKOptions?
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyAll
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .elementsFailed(iterationResult.allFailed),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyAny
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    let assertionKind: AssertionKind = .satisfyNone
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : failureKind,
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    precondition(
        atLeast >= 0,
        "atLeast must be non-negative"
    )
    
    let assertionKind: AssertionKind = .satisfyAtLeast
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    precondition(
        atMost >= 0,
        "atMost must be non-negative"
    )
    
    let assertionKind: AssertionKind = .satisfyAtMost
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
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
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    precondition(
        count >= 0,
        "count must be non-negative"
    )
    
    let assertionKind: AssertionKind = .exactly
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    let assertionKind: AssertionKind = .exactlyOne
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .countMismatch(countMismatch),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection
{
    let assertionKind: AssertionKind = .sorted
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
    )
    
    guard case let .success(elements) = collectionResult
    else
    {
        return
    }
    
    
    
    if !elements.isOrdered
    {
        let typeName = String(describing: type(of: elements))
        
        failAssertion(
            kind:       assertionKind,
            reason:     "unordered collection type (\(typeName))",
            message:    message,
            file:       file,
            line:       line,
            options:    options
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
                    collectionCount : elements.count,
                    kind            : .orderingViolation(violation),
                    isOrdered       : true
                )
                
                failPredicateAssertion(
                    kind:           assertionKind,
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
                collectionCount : elements.count,
                kind            : .orderingViolation(violation),
                isOrdered       : true
            )
            
            failPredicateAssertion(
                kind:           assertionKind,
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
    options     : XCTKOptions?
) where C : Collection, C.Element : Hashable
{
    let assertionKind: AssertionKind = .unique
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        collectionCount : elements.count,
        kind            : .duplicates(duplicateGroups),
        isOrdered       : true
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
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
    key         : (C.Element) throws -> K,
    message     : () -> String,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
) where C : Collection, K : Hashable
{
    let assertionKind: AssertionKind = .uniqueByKey
    
    let collectionResult: Result<C, Error> = evaluateCollection(
        collection,
        assertion:  assertionKind,
        message:    message,
        file:       file,
        line:       line,
        options:    options
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
        let extractedKey: K
        
        do
        {
            extractedKey = try key(element)
        }
        catch
        {
            failAssertion(
                kind:       assertionKind,
                reason:     "key extractor threw error \(quote(error))"
                            + " at index \(index)",
                message:    message,
                file:       file,
                line:       line,
                options:    options
            )
            
            return
        }
        
        let indexedElement = IndexedElement(
            index:  index,
            value:  DiffValue(element)
        )
        
        elementsByKey[extractedKey, default: []].append(indexedElement)
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
        collectionCount : elements.count,
        kind            : .duplicateKeys(duplicateGroups),
        isOrdered       : elements.isOrdered
    )
    
    failPredicateAssertion(
        kind:           assertionKind,
        captureKind:    captureKind,
        failure:        failure,
        message:        message,
        file:           file,
        line:           line,
        options:        options
    )
}

