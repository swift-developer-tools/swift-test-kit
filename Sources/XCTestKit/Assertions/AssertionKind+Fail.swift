//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore



/// Methods for failing assertions.
internal extension AssertionKind
{
    // MARK: - Reason
    
    /// Reports an assertion failure with the given reason.
    ///
    /// - Note: This handles all ``ExprCaptureKind`` cases.
    ///
    /// - Parameters:
    ///   - captureKind: The kind of captured assertion expression.
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        captureKind : ExprCaptureKind,
        reason      : String?,
        message     : () -> String?,
        file        : StaticString,
        line        : UInt,
        options     : XCTKOptions?
    )
    {
        switch captureKind
        {
            case .none:
                
                var text: String = makeHeader(isMacro: false)
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                emit(text, file: file, line: line)
                
            case let .single(exprText):
                
                var text: String = makeHeader(isMacro: false)
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                
                text += "\n\nExpression: \(exprText)"
                
                emit(text, file: file, line: line)
                
            case let .double(expr1Text, expr2Text):
                
                var text: String = makeHeader(isMacro: true)
                
                appendReason(reason, to: &text)
                appendMessage(message, to: &text)
                
                text += "\n\nExpression 1: \(expr1Text)"
                text += "\nExpression 2: \(expr2Text)"
                
                emit(text, file: file, line: line)
        }
    }
    
    
    
    // MARK: - Diff
    
    /// Reports an assertion failure with the given diff.
    ///
    /// - Note: This reports an unhandled failure for
    /// ``ExprCaptureKind/single``.
    ///
    /// - Parameters:
    ///   - captureKind: The kind of captured assertion expression.
    ///   - diff: The computed diff.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        captureKind : ExprCaptureKind,
        diff        : DiffNode,
        message     : () -> String?,
        file        : StaticString,
        line        : UInt,
        options     : XCTKOptions?
    )
    {
        let diffOutput: String = Formatter.formatDiff(
            diff,
            options: options?.formatOptions
        )
        
        switch captureKind
        {
            case .none:
                
                var text: String = makeHeader(isMacro: false)
                
                appendMessage(message, to: &text)
                
                text += "\n\n\(diffOutput)"
                
                emit(text, file: file, line: line)
                
            case let .double(expText, actText):
                
                var text: String = makeHeader(isMacro: true)
                
                appendMessage(message, to: &text)
                
                text += "\n\nExpected: \(expText)"
                text += "\nActual:   \(actText)"
                text += "\n\n\(diffOutput)"
                
                emit(text, file: file, line: line)
                
            case .single:
                
                failUnhandled(
                    captureKind:    captureKind,
                    message:        message,
                    file:           file,
                    line:           line
                )
        }
    }
    
    
    
    // MARK: - Single expression
    
    /// Reports a macro assertion failure for a single captured expression.
    ///
    /// - Note: This reports an unhandled failure for ``ExprCaptureKind/none``
    /// and ``ExprCaptureKind/double``.
    ///
    /// - Parameters:
    ///   - captureKind: The kind of captured assertion expression.
    ///   - actual: The string representation of the actual value, or `nil`
    ///   to omit.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        captureKind : ExprCaptureKind,
        actual      : String?,
        message     : () -> String?,
        file        : StaticString,
        line        : UInt,
        options     : XCTKOptions?
    )
    {
        switch captureKind
        {
            case let .single(exprText):
                
                var text: String = makeHeader(isMacro: true)
                
                appendMessage(message, to: &text)
                
                text += "\n\nExpression: \(exprText)"
                
                if let actual
                {
                    text += self == .noThrow
                        ? "\nThrew:      \(actual)"
                        : "\nActual:     \(actual)"
                }
                
                emit(text, file: file, line: line)
                
            case
                .none,
                .double:
                
                failUnhandled(
                    captureKind:    captureKind,
                    message:        message,
                    file:           file,
                    line:           line
                )
        }
    }
    
    
    
    // MARK: - Boolean expressions
    
    /// Reports a macro assertion failure with boolean expression decomposition.
    ///
    /// - Note: This is always called in macro context.
    ///
    /// - Parameters:
    ///   - exprText: The expression source text.
    ///   - evaluated: The evaluated boolean expressions.
    ///   - notEvaluated: The number of unevaluated boolean expressions.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        exprText        : String,
        evaluated       : [XCTKBooleanExpr],
        notEvaluated    : Int,
        message         : () -> String?,
        file            : StaticString,
        line            : UInt,
        options         : XCTKOptions?
    )
    {
        let output: String = Formatter.formatBooleanExpr(
            exprText:       exprText,
            evaluated:      evaluated,
            notEvaluated:   notEvaluated,
            expectedValue:  self == .false ? false : true,
            options:        options?.formatOptions
        )
        
        var text: String = makeHeader(isMacro: true)
        
        appendMessage(message, to: &text)
        
        text += "\n\n\(output)"
        
        emit(text, file: file, line: line)
    }
    
    
    
    // MARK: - Predicate
    
    /// Reports a predicate assertion failure.
    ///
    /// - Note: This handles all ``ExprCaptureKind`` cases.
    ///
    /// - Parameters:
    ///   - captureKind: The kind of captured assertion expression.
    ///   - failure: Information about the failed predicate.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func fail(
        captureKind : ExprCaptureKind,
        failure     : PredicateFailure,
        message     : () -> String?,
        file        : StaticString,
        line        : UInt,
        options     : XCTKOptions?
    )
    {
        let output  : String
        let isMacro : Bool
        
        switch captureKind
        {
            case .none:
                
                isMacro = false
                
                output = Formatter.formatPredicate(
                    failure,
                    options: options?.formatOptions
                )
                
            case let .single(collectionText):
                
                isMacro = true
                
                output = Formatter.formatPredicate(
                    failure,
                    collectionText:     collectionText,
                    predicateText:      nil,
                    options:            options?.formatOptions
                )
                
            case let .double(collectionText, predicateText):
                
                isMacro = true
                
                output = Formatter.formatPredicate(
                    failure,
                    collectionText:     collectionText,
                    predicateText:      predicateText,
                    options:            options?.formatOptions
                )
        }
        
        var text: String = makeHeader(isMacro: isMacro)
        
        appendMessage(message, to: &text)

        text += "\n\n\(output)"
        
        emit(text, file: file, line: line)
    }
    
    
    
    // MARK: - Support
    
    /// Emits the assertion failure.
    /// - Parameters:
    ///   - text: The full failure text.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    private func emit(
        _ text  : String,
        file    : StaticString,
        line    : UInt
    )
    {
        XCTKFail(
            text,
            file:   file,
            line:   line
        )
    }
    
    
    
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
    /// - Parameter isMacro: Whether the failure is from a macro assertion.
    /// - Returns: The assertion failure header.
    private func makeHeader(
        isMacro: Bool
    ) -> String
    {
        let displayName: String = isMacro
            ? macroDisplayName
            : name
        
        return "\(displayName) failed"
    }
    
    
    
    /// Reports a failure for the given unhandled expression capture kind.
    /// - Parameters:
    ///   - captureKind: The unhandled expression capture kind.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    private func failUnhandled(
        captureKind : ExprCaptureKind,
        message     : () -> String?,
        file        : StaticString,
        line        : UInt
    )
    {
        let reason: String = "Unhandled expression capture kind for"
            + " assertion \(quote(name))."
            + " Please submit an XCTestKit bug report"
            + " (https://github.com/swift-developer-tools/XCTestKit)."
        
        var text: String = makeHeader(isMacro: captureKind != .none)
        
        appendReason(reason, to: &text)
        appendMessage(message, to: &text)
        emit(text, file: file, line: line)
    }
}



// MARK: - Macro expansion

@_documentation(visibility: internal)
public extension AssertionKind
{
    /// Reports a boolean macro assertion failure.
    ///
    /// - Note: This is public since it is used in boolean macro expansions.
    ///
    /// - Parameters:
    ///   - reason: The optional failure reason.
    ///   - message: The description of a failure.
    ///   - file: The file where the failure occurs.
    ///   - line: The line where the failure occurs.
    ///   - options: The options for testing.
    func failMacroExpansion(
        reason      : String?,
        message     : String?,
        file        : StaticString,
        line        : UInt,
        options     : XCTKOptions?
    )
    {
        var text: String = makeHeader(isMacro: true)
        
        appendReason(reason, to: &text)
        appendMessage({ return message }, to: &text)
        emit(text, file: file, line: line)
    }
}
