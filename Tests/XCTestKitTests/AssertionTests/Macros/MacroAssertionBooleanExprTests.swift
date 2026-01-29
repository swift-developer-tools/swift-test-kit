//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit
@testable import XCTestKitTestUtilities



internal final class MacroAssertionBooleanExprTests: XCTestKitCase
{
    // MARK: - AND chains
    
    func testAndChainFirstFalseShortCircuits() throws
    {
        let a       : Bool  = false
        let b       : Bool  = true
        let c       : Bool  = true
        let expr    : Bool  = a && b && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssert(expr)
        }
        
        let expected: String =
        """
        Expression: a && b && c

            a = false ←

            (2 expressions not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAndChainMiddleFalseShortCircuits() throws
    {
        let a       : Bool  = true
        let b       : Bool  = false
        let c       : Bool  = true
        let expr    : Bool  = a && b && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssert(expr)
        }
        
        let expected: String =
        """
        Expression: a && b && c

            a = true
            b = false ←

            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAndChainLastFalseNoShortCircuit() throws
    {
        let a       : Bool  = true
        let b       : Bool  = true
        let c       : Bool  = false
        let expr    : Bool  = a && b && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssert(expr)
        }
        
        let expected: String =
        """
        Expression: a && b && c

            a = true
            b = true
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - OR chains
    
    func testOrChainFirstTrueShortCircuits() throws
    {
        let a       : Bool  = true
        let b       : Bool  = false
        let c       : Bool  = true
        let expr    : Bool  = a || b || c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertFalse(expr)
        }
        
        let expected: String =
        """
        Expression: a || b || c

            a = true ←

            (2 expressions not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrChainAllFalseNoShortCircuit() throws
    {
        let a       : Bool  = false
        let b       : Bool  = false
        let c       : Bool  = false
        let expr    : Bool  = a || b || c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: a || b || c

            a = false ←
            b = false ←
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nested expressions
    
    func testNestedOrInAndExprWithFalseLHS() throws
    {
        let a       : Bool  = false
        let b       : Bool  = false
        let c       : Bool  = false
        let expr    : Bool  = (a || b) && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: (a || b) && c

            a = false ←
            b = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNestedOrInAndExprWithTrueLHS() throws
    {
        let a       : Bool  = true
        let b       : Bool  = false
        let c       : Bool  = false
        let expr    : Bool  = (a || b) && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: (a || b) && c

            a = true
            c = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testParenthesizedSingleExprUnwrapping() throws
    {
        let a       : Bool  = false
        let expr    : Bool  = (a)
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: a

            a = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDeeplyNestedExpr() throws
    {
        let a       : Bool  = true
        let b       : Bool  = false
        let c       : Bool  = false
        let d       : Bool  = true
        let expr    : Bool  = ((a && (b)) || c) && d
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: ((a && (b)) || c) && d

            a = true
            b = false ←
            c = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOperatorPrecedence() throws
    {
        let a       : Bool  = false
        let b       : Bool  = true
        let c       : Bool  = false
        let expr    : Bool  = a || b && c
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: a || b && c

            a = false ←
            b = true
            c = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Single expression
    
    func testSingleExprAssertTrueWhenFalse() throws
    {
        let isValid: Bool = false
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(isValid)
        }
        
        let expected: String =
        """
        Expression: isValid

            isValid = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleExprAssertFalseWhenTrue() throws
    {
        let isValid: Bool = true
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertFalse(isValid)
        }
        
        let expected: String =
        """
        Expression: isValid

            isValid = true ←
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Function leaves
    
    func testFunctionCallAsLeaf() throws
    {
        func isValid() -> Bool { return false }
        
        let isEnabled: Bool = true
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(isValid() && isEnabled)
        }
        
        let expected: String =
        """
        Expression: isValid() && isEnabled

            isValid() = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Other expressions
    
    func testNegation() throws
    {
        let a       : Bool  = true
        let b       : Bool  = false
        let c       : Bool  = false
        let expr    : Bool  = (!a || !(!b)) && !(!(!c))
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(expr)
        }
        
        let expected: String =
        """
        Expression: (!a || !(!b)) && !(!(!c))

            !a = false ←
            !!b = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPropertyAccessExprs() throws
    {
        struct SomeObject: Equatable
        {
            let isActive    : Bool
            let isValid     : Bool
            let value       : Int
        }
        
        let obj = SomeObject(
            isActive:   true,
            isValid:    false,
            value:      10
        )
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(obj.isActive && obj.isValid && obj.value >= 30)
        }
        
        let expected: String =
        """
        Expression: obj.isActive && obj.isValid && obj.value >= 30

            obj.isActive = true
            obj.isValid = false ←
        
            (1 expression not evaluated)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMethodCalls() throws
    {
        struct Value: Equatable
        {
            func isValid() -> Bool
            {
                return false
            }
        }
        
        let obj     : String    = "something"
        let key     : String    = "anything"
        let value   : Value     = .init()
        
        let actual: String? = withOneExpectedFailure
        {
            #XCTKAssertTrue(obj.contains(key) && value.isValid())
        }
        
        let expected: String =
        """
        Expression: obj.contains(key) && value.isValid()

            obj.contains(key) = false ←
            value.isValid() = false ←
        """
        
        XCTAssertEqual(expected, actual)
    }
}
