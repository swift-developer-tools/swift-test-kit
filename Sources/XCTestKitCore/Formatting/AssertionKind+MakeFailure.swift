//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Methods for failing assertions.
extension AssertionKind
{
    // MARK: - Reason
    
    /// Creates a reason-based failure message.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    /// - Returns: The reason-based failure message.
    public func makeReasonFailure(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        reason      : String?,
        message     : () -> String?
    ) -> String
    {
        var text: String
        
        switch captureKind
        {
            case .none:
                
                text = makeHeader(
                    framework:  context.framework,
                    isMacro:    false
                )
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                
            case let .single(exprText):
                
                text = makeHeader(
                    framework:  context.framework,
                    isMacro:    false
                )
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                
                text += "\n\nExpression: \(exprText)"
                
            case let .double(expr1Text, expr2Text):
                
                text = makeHeader(
                    framework:  context.framework,
                    isMacro:    true
                )
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                
                text += "\n\nExpression 1: \(expr1Text)"
                text += "\nExpression 2: \(expr2Text)"
        }
        
        return text
    }
    
    
    
    // MARK: - Diff
    
    /// Creates a diff-based failure message.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - diff: The computed diff.
    ///   - message: The description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The diff-based failure message, or an ``UnhandledError``
    /// for ``ExprCaptureKind/single``.
    public func makeDiffFailure(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        diff        : DiffNode,
        message     : () -> String?,
        options     : TKOptions
    ) -> Result<String, UnhandledError>
    {
        let diffOutput: String = Formatter.formatDiff(
            diff,
            options: options.formatOptions
        )
        
        switch captureKind
        {
            case .none:
                
                var text: String = makeHeader(
                    framework:  context.framework,
                    isMacro:    false
                )
                
                appendMessage(message, to: &text)
                
                text += "\n\n\(diffOutput)"
                
                return .success(text)
                
            case let .double(expText, actText):
                
                var text: String = makeHeader(
                    framework:  context.framework,
                    isMacro:    true
                )
                
                appendMessage(message, to: &text)
                
                text += "\n\nExpected: \(expText)"
                text += "\nActual:   \(actText)"
                text += "\n\n\(diffOutput)"
                
                return .success(text)
                
            case .single:
                
                let error: UnhandledError = makeUnhandledError(
                    context:        context,
                    captureKind:    captureKind,
                    message:        message
                )
                
                return .failure(error)
        }
    }
    
    
    
    // MARK: - Single expression
    
    /// Creates a single-expression-based failure message.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - actual: The string representation of the actual value, or `nil`
    ///   to omit.
    ///   - message: The description of a failure.
    /// - Returns: The single-expression-based failure message, or an
    /// ``UnhandledError`` for ``ExprCaptureKind/none`` and
    /// ``ExprCaptureKind/double``.
    public func makeSingleExprFailure(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        actual      : String?,
        message     : () -> String?
    ) -> Result<String, UnhandledError>
    {
        switch captureKind
        {
            case let .single(exprText):
                
                var text: String = makeHeader(
                    framework:  context.framework,
                    isMacro:    true
                )
                
                appendMessage(message, to: &text)
                
                text += "\n\nExpression: \(exprText)"
                
                if let actual
                {
                    text += self == .noThrow
                        ? "\nThrew:      \(actual)"
                        : "\nActual:     \(actual)"
                }
                
                return .success(text)
                
            case
                .none,
                .double:
                
                let error: UnhandledError = makeUnhandledError(
                    context:        context,
                    captureKind:    captureKind,
                    message:        message
                )
                
                return .failure(error)
        }
    }
    
    
    
    // MARK: - Boolean expressions
    
    /// Creates a boolean-expression-based failure message for macro assertions.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - exprText: The expression source text.
    ///   - evaluated: The evaluated boolean expressions.
    ///   - notEvaluated: The number of unevaluated boolean expressions.
    ///   - message: The description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The boolean-expression-based failure message.
    public func makeBooleanExprFailure(
        context         : FailureContext,
        exprText        : String,
        evaluated       : [TKBooleanExpr],
        notEvaluated    : Int,
        message         : () -> String?,
        options         : TKOptions
    ) -> String
    {
        let output: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   notEvaluated,
            expectedValue:  self == .false ? false : true,
            options:        options.formatOptions
        )
        
        var text: String = makeHeader(
            framework:  context.framework,
            isMacro:    true
        )
        
        appendMessage(message, to: &text)
        
        text += "\n\n\(output)"
        
        return text
    }
    
    
    
    // MARK: - Predicate
    
    /// Creates a predicate-based failure message.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The kind of captured assertion expression.
    ///   - failure: Information about the failed predicate.
    ///   - message: The description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The predicate-based failure message.
    public func makePredicateFailure(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        failure     : PredicateFailure,
        message     : () -> String?,
        options     : TKOptions
    ) -> String
    {
        let output  : String
        let isMacro : Bool
        
        switch captureKind
        {
            case .none:
                
                isMacro = false
                
                output = Formatter.formatPredicate(
                    failure,
                    options: options.formatOptions
                )
                
            case let .single(collectionText):
                
                isMacro = true
                
                output = Formatter.formatPredicate(
                    failure,
                    collectionText:     collectionText,
                    predicateText:      nil,
                    options:            options.formatOptions
                )
                
            case let .double(collectionText, predicateText):
                
                isMacro = true
                
                output = Formatter.formatPredicate(
                    failure,
                    collectionText:     collectionText,
                    predicateText:      predicateText,
                    options:            options.formatOptions
                )
        }
        
        var text: String = makeHeader(
            framework:  context.framework,
            isMacro:    isMacro
        )
        
        appendMessage(message, to: &text)

        text += "\n\n\(output)"
        
        return text
    }
    
    
    
    // MARK: - Macro expansion

    /// Creates a failure message for use during macro expansion in
    /// ``BooleanExprWalker``.
    /// - Parameters:
    ///   - framework: The framework kind.
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    /// - Returns: The failure message.
    public func makeMacroExpansionFailure(
        framework   : FrameworkKind,
        reason      : String?,
        message     : String?
    ) -> String
    {
        var text: String = makeHeader(
            framework:  framework,
            isMacro:    true
        )
        
        appendReason(reason, to: &text)
        appendMessage({ return message }, to: &text)
        
        return text
    }
    
    
    
    // MARK: - Support
    
    /// Appends the given message to the given failure text.
    /// - Parameters:
    ///   - message: The description of a failure.
    ///   - text: The failure text to update.
    private func appendMessage(
        _   message : () -> String?,
        to  text    : inout String
    )
    {
        guard
            let msg: String = message(),
            !msg.isEmpty
        else
        {
            return
        }
        
        text += " - \(msg)"
    }
    
    
    
    /// Appends the given reason to the given failure text.
    /// - Parameters:
    ///   - reason: The optional failure reason.
    ///   - text: The failure text to update.
    private func appendReason(
        _   reason  : String?,
        to  text    : inout String
    )
    {
        guard let reason
        else
        {
            return
        }
        
        text += ": \(reason)"
    }
    
    
    
    /// Creates the assertion failure header.
    /// - Parameters:
    ///   - framework: The framework kind.
    ///   - isMacro: Whether the failure is from a macro assertion.
    /// - Returns: The assertion failure header.
    private func makeHeader(
        framework   : FrameworkKind,
        isMacro     : Bool
    ) -> String
    {
        let displayName: String = isMacro
            ? macroDisplayName(for: framework)
            : name(for: framework)
        
        return "\(displayName) failed"
    }
    
    
    
    /// An error for an unhandled ``ExprCaptureKind``.
    public enum UnhandledError: Error, CustomStringConvertible
    {
        case invalid(
            _ message: String
        )
        
        
        
        public var description: String
        {
            switch self
            {
                case let .invalid(message): return message
            }
        }
    }
    
    
    
    /// Creates an error for the given unhandled expression capture kind.
    /// - Parameters:
    ///   - context: The assertion failure context.
    ///   - captureKind: The unhandled expression capture kind.
    ///   - message: The description of a failure.
    /// - Returns: The error for the given unhandled expression capture kind.
    private func makeUnhandledError(
        context     : FailureContext,
        captureKind : ExprCaptureKind,
        message     : () -> String?
    ) -> UnhandledError
    {
        let reason: String = "Unhandled expression capture kind for"
            + " assertion \(quote(name))."
            + " Please submit an XCTestKit bug report"
            + " (https://github.com/swift-developer-tools/XCTestKit)."
        
        var text: String = makeHeader(
            framework:  context.framework,
            isMacro:    captureKind != .none
        )
        
        appendReason(reason, to: &text)
        appendMessage(message, to: &text)
        
        return .invalid(text)
    }
}
