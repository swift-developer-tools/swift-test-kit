//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Methods for failing assertions.
extension AssertionKind
{
    // MARK: - Reason
    
    /// Reports a reason-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - capture: The kind of captured assertion expression.
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    package func fail(
        context     : FailureContext,
        capture     : ExprCaptureKind,
        reason      : String?,
        message     : () -> String,
        fileID      : StaticString,
        file        : StaticString,
        line        : UInt,
        column      : UInt
    )
    {
        let text: String = makeReasonFailure(
            context:    context,
            capture:    capture,
            reason:     reason,
            message:    message
        )
        
        context.emit(
            text,
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Diff
    
    /// Reports a diff-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - capture: The kind of captured assertion expression.
    ///   - diff: The computed diff.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    ///   - options: The options for testing.
    package func fail(
        context : FailureContext,
        capture : ExprCaptureKind,
        diff    : DiffNode,
        message : () -> String,
        fileID  : StaticString,
        file    : StaticString,
        line    : UInt,
        column  : UInt,
        options : TestOptions
    )
    {
        let result: Result<String, UnhandledError> = makeDiffFailure(
            context:    context,
            capture:    capture,
            diff:       diff,
            message:    message,
            options:    options
        )
        
        context.emit(
            getFailureMessage(from: result),
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Single expression
    
    /// Reports a single-expression-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - capture: The kind of captured assertion expression.
    ///   - actual: The string representation of the actual value, or `nil`
    ///   to omit.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    package func fail(
        context : FailureContext,
        capture : ExprCaptureKind,
        actual  : String?,
        message : () -> String,
        fileID  : StaticString,
        file    : StaticString,
        line    : UInt,
        column  : UInt
    )
    {
        let result: Result<String, UnhandledError> = makeSingleExprFailure(
            context:    context,
            capture:    capture,
            actual:     actual,
            message:    message
        )
        
        context.emit(
            getFailureMessage(from: result),
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Boolean expressions
    
    /// Reports a boolean-expression-based macro assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - exprText: The expression source text.
    ///   - evaluated: The evaluated boolean expressions.
    ///   - notEvaluated: The number of unevaluated boolean expressions.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    ///   - options: The options for testing.
    package func fail(
        context         : FailureContext,
        exprText        : String,
        evaluated       : [BooleanExpr],
        notEvaluated    : Int,
        message         : () -> String,
        fileID          : StaticString,
        file            : StaticString,
        line            : UInt,
        column          : UInt,
        options         : TestOptions
    )
    {
        let text: String = makeBooleanExprFailure(
            context:        context,
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   notEvaluated,
            message:        message,
            options:        options
        )
        
        context.emit(
            text,
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Predicate
    
    /// Reports a predicate-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - capture: The kind of captured assertion expression.
    ///   - failure: Information about the failed predicate.
    ///   - message: The description of a failure.
    ///   - fileID: The ID of the file where the failure occurs.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - column: The column where the failure occurs.
    ///   - options: The options for testing.
    package func fail(
        context : FailureContext,
        capture : ExprCaptureKind,
        failure : PredicateFailure,
        message : () -> String,
        fileID  : StaticString,
        file    : StaticString,
        line    : UInt,
        column  : UInt,
        options : TestOptions
    )
    {
        let text: String = makePredicateFailure(
            context:    context,
            capture:    capture,
            failure:    failure,
            message:    message,
            options:    options
        )
        
        context.emit(
            text,
            fileID,
            file,
            line,
            column
        )
    }
    
    
    
    // MARK: - Support
    
    /// Gets the failure message from the given result.
    /// - Parameter result: The result from which to get the failure message.
    /// - Returns: The failure message.
    private func getFailureMessage(
        from result: Result<String, UnhandledError>
    ) -> String
    {
        switch result
        {
            case let .success(text)     : return text
            case let .failure(error)    : return error.description
        }
    }
}
