//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Methods for failing assertions.
package extension AssertionKind
{
    // MARK: - Reason
    
    /// Reports a reason-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    func fail(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        reason      : String?,
        message     : () -> String,
        file        : StaticString,
        line        : UInt
    )
    {
        let text: String = makeReasonFailure(
            context:        context,
            captureKind:    captureKind,
            reason:         reason,
            message:        message
        )
        
        context.emit(
            text,
            file,
            line
        )
    }
    
    
    
    // MARK: - Diff
    
    /// Reports a diff-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - diff: The computed diff.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        diff        : DiffNode,
        message     : () -> String,
        file        : StaticString,
        line        : UInt,
        options     : TKOptions
    )
    {
        let result: Result<String, UnhandledError> = makeDiffFailure(
            context:        context,
            captureKind:    captureKind,
            diff:           diff,
            message:        message,
            options:        options
        )
        
        context.emit(
            getFailureMessage(from: result),
            file,
            line
        )
    }
    
    
    
    // MARK: - Single expression
    
    /// Reports a single-expression-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - actual: The string representation of the actual value, or `nil`
    ///   to omit.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    func fail(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        actual      : String?,
        message     : () -> String,
        file        : StaticString,
        line        : UInt
    )
    {
        let result: Result<String, UnhandledError> = makeSingleExprFailure(
            context:        context,
            captureKind:    captureKind,
            actual:         actual,
            message:        message
        )
        
        context.emit(
            getFailureMessage(from: result),
            file,
            line
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
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        context         : FailureContext,
        exprText        : String,
        evaluated       : [BooleanExpr],
        notEvaluated    : Int,
        message         : () -> String,
        file            : StaticString,
        line            : UInt,
        options         : TKOptions
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
            file,
            line
        )
    }
    
    
    
    // MARK: - Predicate
    
    /// Reports a predicate-based assertion failure.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - failure: Information about the failed predicate.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        failure     : PredicateFailure,
        message     : () -> String,
        file        : StaticString,
        line        : UInt,
        options     : TKOptions
    )
    {
        let text: String = makePredicateFailure(
            context:        context,
            captureKind:    captureKind,
            failure:        failure,
            message:        message,
            options:        options
        )
        
        context.emit(
            text,
            file,
            line
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
