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



internal struct BooleanExprWalker
{
    // MARK: - Expansion
    
    /// Generates the macro expansion for the specified boolean assertion.
    /// - Parameters:
    ///   - kind: The assertion kind.
    ///   - expr: The expression.
    ///   - message: An optional description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The expanded macro expression.
    static func expand(
        kind    : AssertionKind,
        expr    : ExprSyntax,
        message : ExprSyntax,
        options : ExprSyntax
    ) -> ExprSyntax
    {
        if shouldDecompose(expr)
        {
            return expandDecomposable(
                kind:       kind,
                expr:       expr,
                message:    message,
                options:    options
            )
        }
        
        return expandSimple(
            kind:       kind,
            expr:       expr,
            message:    message,
            options:    options
        )
    }
    
    
    
    /// Generates the macro expansion for the given non-decomposable expression.
    /// - Parameters:
    ///   - kind: The assertion kind.
    ///   - expr: The expression.
    ///   - message: An optional description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The expanded macro expression.
    private static func expandSimple(
        kind    : AssertionKind,
        expr    : ExprSyntax,
        message : ExprSyntax,
        options : ExprSyntax
    ) -> ExprSyntax
    {
        let exprText: String = expr.trimmedDescription
        
        let code: ExprSyntax =
        """
            let _v0: Bool = \(expr)
        
            let evaluated = XCTKBooleanExpr(
                text:   \(literal: exprText),
                value:  _v0
            )
        
            \(raw: kind.macroInternalName)(
                result:         _v0,
                exprText:       \(literal: exprText),
                evaluated:      [evaluated],
                notEvaluated:   0,
                message:        \(message),
                file:           #filePath,
                line:           #line,
                options:        \(options)
            )
        """
        
        return wrapWithErrorHandling(
            code:       code,
            kind:       kind,
            expr:       expr,
            message:    message,
            options:    options
        )
    }
    
    
    
    /// Generates the macro expansion for the given expression containing
    /// logical operators.
    /// - Parameters:
    ///   - kind: The assertion kind.
    ///   - expr: The expression.
    ///   - message: An optional description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The expanded macro expression.
    private static func expandDecomposable(
        kind    : AssertionKind,
        expr    : ExprSyntax,
        message : ExprSyntax,
        options : ExprSyntax
    ) -> ExprSyntax
    {
        let node    : Node              = parse(expr)
        let context : CodeGenContext    = .init()
        
        let evaluationResult = EvaluationResult.makeEvaluation(
            node,
            context: context
        )
        
        let code: ExprSyntax =
        """
            var _evaluated      : [XCTKBooleanExpr]     = []
            var _notEvaluated   : Int                   = 0
            
            \(raw: evaluationResult.code)
            
            \(raw: kind.macroInternalName)(
                result:         \(raw: evaluationResult.varName),
                exprText:       \(literal: expr.trimmedDescription),
                evaluated:      _evaluated,
                notEvaluated:   _notEvaluated,
                message:        \(message),
                file:           #filePath,
                line:           #line,
                options:        \(options)
            )
        """
        
        return wrapWithErrorHandling(
            code:       code,
            kind:       kind,
            expr:       expr,
            message:    message,
            options:    options
        )
    }
    
    
    
    /// Wraps the given code in an immediately-invoked closure, with error
    /// handling if the given expression can throw.
    ///
    /// If the given expression contains a `try` expression, the given code is
    /// wrapped in a `do`/`catch` statement that reports thrown errors as
    /// assertion failures. Otherwise, the code is wrapped in plain closure.
    ///
    /// - Parameters:
    ///   - code: The code to wrap.
    ///   - kind: The assertion kind.
    ///   - expr: The expression.
    ///   - message: An optional description of a failure.
    ///   - options: The options for testing.
    /// - Returns: The expanded macro expression.
    private static func wrapWithErrorHandling(
        code    : ExprSyntax,
        kind    : AssertionKind,
        expr    : ExprSyntax,
        message : ExprSyntax,
        options : ExprSyntax
    ) -> ExprSyntax
    {
        if expr.containsTry
        {
            return """
            {
                do
                {
                    \(raw: code)
                }
                catch
                {
                    \(raw: kind.sourceExpr).failMacroExpansion(
                        reason:     "threw error \\\"\\(error)\\\"",
                        message:    \(message),
                        file:       #filePath,
                        line:       #line,
                        options:    \(options)
                    )
                }
            }()
            """
        }
        
        return """
        {
            \(raw: code)
        }()
        """
    }
    
    
    
    /// Context for tracking state during code generation.
    private final class CodeGenContext
    {
        /// Counter for generating unique variable names.
        private var varCounter: Int = 0
        
        /// Generates the next unique variable name.
        /// - Returns: The next unique variable name.
        func nextVar() -> String
        {
            let name: String = "_v\(varCounter)"
            
            varCounter += 1
            
            return name
        }
    }
    
    
    
    // MARK: - Evaluation
    
    /// Checks whether the given expression contains decomposable logical
    /// operators (`&&` or `||`) at the top level.
    ///
    /// Expressions inside negations, function calls, or other constructs are
    /// not considered decomposable.
    ///
    /// - Parameter expr: The expression to check.
    /// - Returns: Whether the given expression should be decomposed.
    private static func shouldDecompose(
        _ expr: ExprSyntax
    ) -> Bool
    {
        if let wrappedExpr: ExprSyntax = unwrap(expr)
        {
            return shouldDecompose(wrappedExpr)
        }
        
        return expr.isLogicalBinaryOperation
    }
    
    
    
    /// Parses the given expression.
    /// - Parameter expr: The expression to parse.
    /// - Returns: The parsed tree.
    private static func parse(
        _ expr: ExprSyntax
    ) -> Node
    {
        if let wrappedExpr: ExprSyntax = unwrap(expr)
        {
            return parse(wrappedExpr)
        }
        
        if expr.is(PrefixOperatorExprSyntax.self)
        {
            return .leaf(expr)
        }
        
        if let kind: LogicalOperatorKind = expr.logicalOperatorKind
        {
            switch kind
            {
                case let .and(infix):
                    
                    return .and(
                        lhs:    parse(infix.leftOperand),
                        rhs:    parse(infix.rightOperand)
                    )
                    
                case let .or(infix):
                    
                    return .or(
                        lhs:    parse(infix.leftOperand),
                        rhs:    parse(infix.rightOperand)
                    )
            }
        }
        
        return .leaf(expr)
    }
    
    
    
    /// Evaluation code for tree nodes.
    private struct EvaluationResult
    {
        /// The generated code.
        let code    : String
        
        /// The result variable name.
        let varName : String
        
        
        
        /// Generates evaluation code for the given node.
        /// - Parameters:
        ///   - node: The node for which to generate code.
        ///   - context: The code generation context.
        /// - Returns: The generated evaluation code.
        static func makeEvaluation(
            _ node  : Node,
            context : CodeGenContext
        ) -> EvaluationResult
        {
            switch node
            {
                case let .leaf(expr):
                    
                    return makeLeafEvaluation(
                        expr:       expr,
                        context:    context
                    )
                    
                case let .and(lhs, rhs):
                    
                    return makeAndEvaluation(
                        lhs:        lhs,
                        rhs:        rhs,
                        context:    context
                    )
                    
                case let .or(lhs, rhs):
                    
                    return makeOrEvaluation(
                        lhs:        lhs,
                        rhs:        rhs,
                        context:    context
                    )
            }
        }
        
        
        
        /// Generates evaluation code for the given leaf node.
        /// - Parameters:
        ///   - expr: The expression.
        ///   - context: The code generation context.
        /// - Returns: The generated evaluation code.
        static func makeLeafEvaluation(
            expr    : ExprSyntax,
            context : CodeGenContext
        ) -> EvaluationResult
        {
            let varName     : String    = context.nextVar()
            let escapedText : String    = expr.trimmedDescription.escaped
            
            let code: String =
            """
            let \(varName): Bool = \(expr.trimmedDescription)
            
            _evaluated.append(XCTKBooleanExpr(
                text:   \(quote(escapedText)),
                value:  \(varName)
            ))
            """
            
            return EvaluationResult(
                code:       code,
                varName:    varName
            )
        }
        
        
        
        /// Generates evaluation code for the specified AND node.
        /// - Parameters:
        ///   - lhs: The left-hand side operand.
        ///   - rhs: The right-hand side operand.
        ///   - context: The code generation context.
        /// - Returns: The generated evaluation code.
        static func makeAndEvaluation(
            lhs     : Node,
            rhs     : Node,
            context : CodeGenContext
        ) -> EvaluationResult
        {
            let lhsResult: EvaluationResult = makeEvaluation(
                lhs,
                context: context
            )
            
            let rhsResult: EvaluationResult = makeEvaluation(
                rhs,
                context: context
            )
            
            let resultVarName: String = context.nextVar()
            
            let code: String =
            """
            \(lhsResult.code)
            
            let \(resultVarName): Bool
            
            if !\(lhsResult.varName)
            {
                _notEvaluated += \(rhs.leafCount)
                
                \(resultVarName) = false
            }
            else
            {
                \(rhsResult.code)
                
                \(resultVarName) = \(rhsResult.varName)
            }
            """
            
            return EvaluationResult(
                code:       code,
                varName:    resultVarName
            )
        }
        
        
        
        /// Generates evaluation code for the specified OR node.
        /// - Parameters:
        ///   - lhs: The left-hand side operand.
        ///   - rhs: The right-hand side operand.
        ///   - context: The code generation context.
        /// - Returns: The generated evaluation code.
        static func makeOrEvaluation(
            lhs     : Node,
            rhs     : Node,
            context : CodeGenContext
        ) -> EvaluationResult
        {
            let lhsResult: EvaluationResult = makeEvaluation(
                lhs,
                context: context
            )
            
            let rhsResult: EvaluationResult = makeEvaluation(
                rhs,
                context: context
            )
            
            let resultVarName: String = context.nextVar()
            
            let code: String =
            """
            \(lhsResult.code)
            
            let \(resultVarName): Bool
            
            if \(lhsResult.varName)
            {
                _notEvaluated += \(rhs.leafCount)
                
                \(resultVarName) = true
            }
            else
            {
                \(rhsResult.code)
                
                \(resultVarName) = \(rhsResult.varName)
            }
            """
            
            return EvaluationResult(
                code:       code,
                varName:    resultVarName
            )
        }
    }
    
    
    
    // MARK: - Support
    
    /// Logical operators.
    enum LogicalOperatorKind: CustomStringConvertible
    {
        /// A logical AND operator.
        /// - Parameter infix: The infix operator expression.
        case and(
            _ infix: InfixOperatorExprSyntax
        )
        
        /// A logical OR operator.
        /// - Parameter infix: The infix operator expression.
        case or(
            _ infix: InfixOperatorExprSyntax
        )
        
        
        
        /// Initializes a ``BooleanBinaryOperator`` instance from the given
        /// values.
        /// - Parameters:
        ///   - text: The operator text.
        ///   - infix: The infix operator expression.
        init?(
            text    : String,
            infix   : InfixOperatorExprSyntax
        )
        {
            switch text
            {
                case "&&"   : self = .and(infix)
                case "||"   : self = .or(infix)
                default     : return nil
            }
        }
        
        
        
        /// The string representation of the operator.
        var description: String
        {
            switch self
            {
                case .and   : return "&&"
                case .or    : return "||"
            }
        }
    }
    
    
    
    /// Removes parentheses from the given expressions and returns the wrapped
    /// expression.
    /// - Parameter expr: The expression to unwrap.
    /// - Returns: The wrapped expression, or `nil` if the given expression is
    /// not wrapped in parentheses.
    private static func unwrap(
        _ expr: ExprSyntax
    ) -> ExprSyntax?
    {
        guard let tuple = expr.as(TupleExprSyntax.self)
        else
        {
            return nil
        }
        
        return tuple.elements.first?.expression
    }
    
    
    
    /// A node in the boolean expression tree.
    private indirect enum Node
    {
        /// A leaf expression that is not further decomposed.
        /// - Parameter expr: The expression.
        case leaf(
            _ expr: ExprSyntax
        )
        
        /// A logical AND (`&&`) of two sub-expressions.
        /// - Parameters:
        ///   - lhs: The left-hand side operand.
        ///   - rhs: The right-hand side operand.
        case and(
            lhs:    Node,
            rhs:    Node
        )
        
        /// A logical OR (`||`) of two sub-expressions.
        /// - Parameters:
        ///   - lhs: The left-hand side operand.
        ///   - rhs: The right-hand side operand.
        case or(
            lhs:    Node,
            rhs:    Node
        )
        
        
        
        /// The number of leaf nodes in this subtree.
        var leafCount: Int
        {
            switch self
            {
                case .leaf:
                    
                    return 1
                    
                case
                    let .and(lhs, rhs),
                    let .or(lhs, rhs):
                    
                    return lhs.leafCount + rhs.leafCount
            }
        }
    }
}
