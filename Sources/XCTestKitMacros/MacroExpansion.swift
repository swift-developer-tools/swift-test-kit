//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import SwiftSyntax
import SwiftSyntaxMacros



// MARK: - Protocols

/// A macro expression.
internal protocol AssertionMacro: ExpressionMacro
{
    /// The underlying assertion kind.
    static var kind: AssertionKind { get }
}

/// A macro expression with no evaluated expression.
internal protocol NoExprMacro       : AssertionMacro { }

/// A macro expression with one evaluated expression.
internal protocol SingleExprMacro   : AssertionMacro { }

/// A macro expression with two evaluated expressions.
internal protocol DoubleExprMacro   : AssertionMacro { }



// MARK: - No expression

extension NoExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    public static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let message: ExprSyntax = node.arguments.positionalArgs.first
            ?? .makeStringLiteral("")
        
        return """
        \(raw: kind.macroInternalName)(
            message:    \(message),
            file:       #filePath,
            line:       #line
        )
        """
    }
}



// MARK: - Single expression

extension SingleExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    public static func expansion(
        of  node    : some FreestandingMacroExpansionSyntax,
        in  context : some MacroExpansionContext
    ) throws -> ExprSyntax
    {
        let positionalArgs: [ExprSyntax] = node.arguments.positionalArgs
        
        let message: ExprSyntax = positionalArgs.count > 1
            ? positionalArgs[1]
            : .makeStringLiteral("")
        
        
        
        guard let expr: ExprSyntax = positionalArgs.first
        else
        {
            throw MacroExpansionErrorMessage("Missing expression argument")
        }
        
        let exprText: String = expr.trimmedDescription
        
        
        
        switch kind
        {
            case
                .assert,
                .true,
                .false:
                
                return BooleanExprWalker.expand(
                    kind:       kind,
                    expr:       expr,
                    message:    message
                )
                
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
                \(raw: kind.macroInternalName)(
                    expr:           { \(expr) },
                    exprText:       \(literal: exprText),
                    message:        \(message),
                    file:           #filePath,
                    line:           #line,
                    errorHandler:   \(errorHandler)
                )
                """
                
            case .noThrow:
                
                return """
                \(raw: kind.macroInternalName)(
                    expr:       { \(expr) },
                    exprText:   \(literal: exprText),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line
                )
                """
                
            default:
                
                return """
                \(raw: kind.macroInternalName)(
                    expr:       \(expr),
                    exprText:   \(literal: exprText),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line
                )
                """
        }
    }
}



// MARK: - Double expression

extension DoubleExprMacro
{
    /// Expands the macro.
    /// - Parameters:
    ///   - node: The AST node.
    ///   - context: The context in which the macro appears.
    /// - Returns: The expanded macro expression.
    public static func expansion(
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
            
            throw MacroExpansionErrorMessage(errorMessage)
        }
        
        
        
        let expr1       : ExprSyntax    = positionalArgs[0]
        let expr2       : ExprSyntax    = positionalArgs[1]
        let expr1Text   : String        = expr1.trimmedDescription
        let expr2Text   : String        = expr2.trimmedDescription
        
        let message: ExprSyntax = positionalArgs.count > 2
            ? positionalArgs[2]
            : .makeStringLiteral("")
        
        
        
        switch kind
        {
            case .equal:
                
                let options: ExprSyntax = args.getArg(labeled: "options")
                    ?? .makeNilLiteral()
                
                return """
                \(raw: kind.macroInternalName)(
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
                .equalWithAccuracy,
                .notEqualWithAccuracy:
                
                guard let accuracy: ExprSyntax
                        = args.getArg(labeled: "accuracy")
                else
                {
                    throw MacroExpansionErrorMessage(
                        "Missing accuracy argument"
                    )
                }
                
                return """
                \(raw: kind.macroInternalName)(
                    expr1:      \(expr1),
                    expr2:      \(expr2),
                    expr1Text:  \(literal: expr1Text),
                    expr2Text:  \(literal: expr2Text),
                    accuracy:   \(accuracy),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line
                )
                """
                
            default:
                
                return """
                \(raw: kind.macroInternalName)(
                    expr1:      \(expr1),
                    expr2:      \(expr2),
                    expr1Text:  \(literal: expr1Text),
                    expr2Text:  \(literal: expr2Text),
                    message:    \(message),
                    file:       #filePath,
                    line:       #line
                )
                """
        }
    }
}
