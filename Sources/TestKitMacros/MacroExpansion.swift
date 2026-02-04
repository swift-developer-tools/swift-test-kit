//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import SwiftSyntax
import SwiftSyntaxMacros



// MARK: - Protocols

/// A macro expression.
public protocol AssertionMacro: ExpressionMacro
{
    typealias ExpansionError = MacroExpansionErrorMessage
    
    /// The underlying assertion kind.
    static var kind         : AssertionKind { get }
    
    /// The framework kind.
    static var framework    : FrameworkKind { get }
}

/// A macro expression with no evaluated expression.
public protocol NoExprMacro                 : AssertionMacro { }

/// A macro expression with one evaluated expression.
public protocol SingleExprMacro             : AssertionMacro { }

/// A macro expression with two evaluated expressions.
public protocol DoubleExprMacro             : AssertionMacro { }

/// A macro expression for a predicate assertion.
public protocol DoubleExprPredicateMacro    : AssertionMacro { }



public extension AssertionMacro
{
    /// Creates an error for an unhandled assertion kind during macro expansion.
    ///
    /// This indicates an internal bug where an ``AssertionKind`` was routed
    /// to a protocol extension that does not handle it.
    static func makeUnhandledKindError() -> ExpansionError
    {
        return ExpansionError(
            "Unhandled assertion kind"
            + " \"\(kind.macroDisplayName(for: framework))\""
            + " during macro expansion. Please submit an XCTestKit bug report"
            + " (https://github.com/swift-developer-tools/swift-test-kit)."
        )
    }
}



// MARK: - No expression

public extension NoExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let message: ExprSyntax = node.arguments.positionalArgs.first
            ?? .makeStringLiteral("")
        
        return """
        \(raw: kind.macroInternalName(for: framework))(
            message:    \(message),
            file:       #filePath,
            line:       #line
        )
        """
    }
}



// MARK: - Single expression

public extension SingleExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let args            : LabeledExprListSyntax     = node.arguments
        let positionalArgs  : [ExprSyntax]              = args.positionalArgs
        
        guard let expr: ExprSyntax = positionalArgs.first
        else
        {
            throw ExpansionError("Missing expression argument")
        }
        
        let exprText: String = expr.trimmedDescription
        
        let message: ExprSyntax = positionalArgs.count > 1
            ? positionalArgs[1]
            : .makeStringLiteral("")
        
        let options: ExprSyntax = args.getArg(labeled: "options")
            ?? .makeNilLiteral()
        
        
        
        switch kind
        {
            case
                .assert,
                .true,
                .false:
                
                return BooleanExprWalker.expand(
                    kind:       kind,
                    framework:  framework,
                    expr:       expr,
                    message:    message,
                    options:    options
                )
                
            case
                .nil,
                .notNil,
                .unwrap:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expr:       \(expr),
                    exprText:   \(literal: exprText),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line,
                    options:    \(options)
                )
                """
                
            case .throwsError:
                
                let errorHandler: ExprSyntax
                
                if let trailingClosure: ClosureExprSyntax
                    = node.trailingClosure
                {
                    errorHandler = ExprSyntax(trailingClosure)
                }
                else if
                    positionalArgs.count > 2,
                    positionalArgs[2].is(ClosureExprSyntax.self)
                {
                    errorHandler = positionalArgs[2]
                }
                else
                {
                    errorHandler = ExprSyntax(
                        ClosureExprSyntax(
                            signature: ClosureSignatureSyntax(
                                parameterClause: .simpleInput(
                                    ClosureShorthandParameterListSyntax([
                                        ClosureShorthandParameterSyntax(
                                            name: .wildcardToken(
                                                trailingTrivia: .space
                                            )
                                        )
                                    ])
                                )
                            ),
                            statements: CodeBlockItemListSyntax([])
                        )
                    )
                }
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expr:           { \(expr) },
                    exprText:       \(literal: exprText),
                    message:        \(message),
                    file:           #filePath,
                    line:           #line,
                    options:        \(options),
                    errorHandler:   \(errorHandler)
                )
                """
                
            case .noThrow:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expr:       { \(expr) },
                    exprText:   \(literal: exprText),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line,
                    options:    \(options)
                )
                """
                
            case .unique:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    collection:         \(expr),
                    collectionText:     \(literal: exprText),
                    message:            \(message),
                    file:               #filePath,
                    line:               #line,
                    options:            \(options)
                )
                """
            
            default:
                
                throw makeUnhandledKindError()
        }
    }
}



// MARK: - Double expression

public extension DoubleExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let args            : LabeledExprListSyntax     = node.arguments
        let positionalArgs  : [ExprSyntax]              = args.positionalArgs
        
        guard positionalArgs.count >= 2
        else
        {
            let errorMessage: String = kind == .equal
                ? "Missing expected and actual value arguments"
                : "Missing expression arguments"
            
            throw ExpansionError(errorMessage)
        }
        
        
        
        let expr1       : ExprSyntax    = positionalArgs[0]
        let expr2       : ExprSyntax    = positionalArgs[1]
        let expr1Text   : String        = expr1.trimmedDescription
        let expr2Text   : String        = expr2.trimmedDescription
        
        let message: ExprSyntax = positionalArgs.count > 2
            ? positionalArgs[2]
            : .makeStringLiteral("")
        
        let options: ExprSyntax = args.getArg(labeled: "options")
            ?? .makeNilLiteral()
        
        switch kind
        {
            case .equal:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expected:       \(expr1),
                    actual:         \(expr2),
                    expectedText:   \(literal: expr1Text),
                    actualText:     \(literal: expr2Text),
                    message:        \(message),
                    file:           #filePath,
                    line:           #line,
                    options:        \(options)
                )
                """
                
            case
                .notEqual,
                .identical,
                .notIdentical,
                .greaterThan,
                .greaterThanOrEqual,
                .lessThanOrEqual,
                .lessThan:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expr1:      \(expr1),
                    expr2:      \(expr2),
                    expr1Text:  \(literal: expr1Text),
                    expr2Text:  \(literal: expr2Text),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line,
                    options:    \(options)
                )
                """
                
            case
                .equalWithAccuracy,
                .notEqualWithAccuracy:
                
                guard let accuracy: ExprSyntax
                        = args.getArg(labeled: "accuracy")
                else
                {
                    throw ExpansionError("Missing accuracy argument")
                }
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    expr1:      \(expr1),
                    expr2:      \(expr2),
                    expr1Text:  \(literal: expr1Text),
                    expr2Text:  \(literal: expr2Text),
                    accuracy:   \(accuracy),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line,
                    options:    \(options)
                )
                """
                
            default:
                
                throw makeUnhandledKindError()
        }
    }
}



// MARK: - Predicate

/// The predicate and message of a predicate macro assertion.
private struct PredicateExtractionResult
{
    /// The predicate expression.
    let predicate   : ExprSyntax

    /// The message expression.
    let message : ExprSyntax
}



public extension DoubleExprPredicateMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let args            : LabeledExprListSyntax     = node.arguments
        let positionalArgs  : [ExprSyntax]              = args.positionalArgs
        
        guard !positionalArgs.isEmpty
        else
        {
            throw ExpansionError("Missing collection argument")
        }
        
        
        
        let collection      : ExprSyntax    = positionalArgs[0]
        let collectionText  : String        = collection.trimmedDescription
        
        let options: ExprSyntax = args.getArg(labeled: "options")
            ?? .makeNilLiteral()
        
        
        
        var predicateLabel: String? = nil
        
        if
            kind == .sorted
            || kind == .uniqueByKey
        {
            predicateLabel = "by"
        }
        
        let extractionResult: PredicateExtractionResult
            = try extractPredicateAndMessage(
                from:               node,
                args:               args,
                positionalArgs:     positionalArgs,
                predicateLabel:     predicateLabel
            )
        
        let predicate       : ExprSyntax    = extractionResult.predicate
        let predicateText   : String        = predicate.trimmedDescription
        let message         : ExprSyntax    = extractionResult.message
        
        let boundNames: [AssertionKind : String] =
        [
            .satisfyAtLeast : "atLeast",
            .satisfyAtMost  : "atMost",
            .satisfyRange   : "range",
            .exactly        : "count"
        ]
        
        
        
        switch kind
        {
            case
                .satisfyAll,
                .satisfyAny,
                .satisfyNone,
                .exactlyOne,
                .sorted,
                .uniqueByKey:
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    collection:         \(collection),
                    predicate:          \(predicate),
                    collectionText:     \(literal: collectionText),
                    predicateText:      \(literal: predicateText),
                    message:            \(message),
                    file:               #filePath,
                    line:               #line,
                    options:            \(options)
                )
                """
                
            case
                .satisfyAtLeast,
                .satisfyAtMost,
                .satisfyRange,
                .exactly:
                
                guard let boundName: String = boundNames[kind]
                else
                {
                    throw makeUnhandledKindError()
                }
                
                guard let bound: ExprSyntax = args.getArg(labeled: boundName)
                else
                {
                    throw ExpansionError("Missing \(boundName) argument")
                }
                
                return """
                \(raw: kind.macroInternalName(for: framework))(
                    collection:         \(collection),
                    \(raw: boundName):  \(bound),
                    predicate:          \(predicate),
                    collectionText:     \(literal: collectionText),
                    predicateText:      \(literal: predicateText),
                    message:            \(message),
                    file:               #filePath,
                    line:               #line,
                    options:            \(options)
                )
                """
                
            default:
                
                throw makeUnhandledKindError()
        }
    }
    
    
    
    /// Extracts the predicate and message from the given node.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - args: The predicate assertion arguments.
    ///   - positionalArgs: The predicate assertion position arugments.
    ///   - predicateLabel: The predicate parameter label.
    /// - Returns: The predicate and message of the predicate assertion.
    private static func extractPredicateAndMessage(
        from node       : some FreestandingMacroExpansionSyntax,
        args            : LabeledExprListSyntax,
        positionalArgs  : [ExprSyntax],
        predicateLabel  : String?
    ) throws -> PredicateExtractionResult
    {
        let predicate       : ExprSyntax
        let messageIndex    : Int
        
        if let trailingClosure: ClosureExprSyntax = node.trailingClosure
        {
            predicate       = ExprSyntax(trailingClosure)
            messageIndex    = 1
        }
        else if
            let label       : String        = predicateLabel,
            let labeledArg  : ExprSyntax    = args.getArg(labeled: label)
        {
            predicate       = labeledArg
            messageIndex    = 1
        }
        else if positionalArgs.count > 1
        {
            predicate       = positionalArgs[1]
            messageIndex    = 2
        }
        else
        {
            throw ExpansionError("Missing predicate argument")
        }
        
        let message: ExprSyntax = positionalArgs.count > messageIndex
            ? positionalArgs[messageIndex]
            : .makeStringLiteral("")
        
        return PredicateExtractionResult(
            predicate:  predicate,
            message:    message
        )
    }
}
