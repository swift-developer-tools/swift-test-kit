//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest
@testable import XCTestKit



internal final class ForAllMessageTests: XCTestKitCase
{
    func testArbitraryMessageNotEvalOnSuccess() throws
    {
        testMessageNotEvalOnSuccess(.arbitrary)
    }
    
    
    
    func testArbitraryMessageEvalOnceOnFailure() throws
    {
        testMessageEvalOnceOnFailure(.arbitrary)
    }
    
    
    
    func testGeneratorMessageNotEvalOnSuccess() throws
    {
        testMessageNotEvalOnSuccess(.generator)
    }
    
    
    
    func testGeneratorMessageEvalOnceOnFailure() throws
    {
        testMessageEvalOnceOnFailure(.generator)
    }
    
    
    
    func testPreconditionMessageNotEvalOnSuccess() throws
    {
        testMessageNotEvalOnSuccess(.precondition)
    }
    
    
    
    func testPreconditionMessageEvalOnceOnFailure() throws
    {
        testMessageEvalOnceOnFailure(.precondition)
    }
    
    
    
    func testPreconditionMessageEvalOnceOnExhaustion() throws
    {
        testMessageEvalOnceOnExhaustion(useGenerator: false)
    }
    
    
    
    func testPreconditionGeneratorMessageNotEvalOnSuccess() throws
    {
        testMessageNotEvalOnSuccess(.preconditionGenerator)
    }
    
    
    
    func testPreconditionGeneratorMessageEvalOnceOnFailure() throws
    {
        testMessageEvalOnceOnFailure(.preconditionGenerator)
    }
    
    
    
    func testPreconditionGeneratorMessageEvalOnceOnExhaustion() throws
    {
        testMessageEvalOnceOnExhaustion(useGenerator: true)
    }
}



// MARK: - Extensions

extension ForAllMessageTests
{
    /// The kind of property evaluator.
    private enum ForAllKind
    {
        /// ``XCTKForAll(_:file:line:options:_:)``
        case arbitrary
        
        /// ``XCTKForAll(using:message:file:line:options:_:)``
        case generator
        
        /// ``XCTKForAll(where:message:file:line:options:_:)``
        case precondition
        
        /// ``XCTKForAll(using:where:message:file:line:options:_:)``
        case preconditionGenerator
    }
    
    
    
    /// Asserts that the message of the specified property evaluator is not
    /// evaluated when the evaluator succeeds.
    /// - Parameter kind: The property evaluator to test.
    private func testMessageNotEvalOnSuccess(
        _ kind: ForAllKind
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let propertyOptions = PropertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let options = TestOptions(propertyOptions: propertyOptions)
        
        switch kind
        {
            case .arbitrary:
                
                XCTKForAll(
                    message(),
                    options: options
                )
                {
                    (_: Int) in
                }
                
            case .generator:
                
                XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) in
                }
                
            case .precondition:
                
                XCTKForAll(
                    where:      { (_: Int) in true },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) in
                }
                
            case .preconditionGenerator:
                
                XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    where:      { (_: Int) in true },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) in
                }
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    /// Asserts that the message of the specified property evaluator is
    /// evaluated only once when the evaluator fails.
    /// - Parameter kind: The property evaluator to test.
    private func testMessageEvalOnceOnFailure(
        _ kind: ForAllKind
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let propertyOptions = PropertyOptions(
            iterations:     1,
            seed:           50
        )
        
        let options = TestOptions(propertyOptions: propertyOptions)
        
        withOneExpectedFailure
        {
            switch kind
            {
                case .arbitrary:
                    
                    XCTKForAll(
                        message(),
                        options: options
                    )
                    {
                        (_: Int) in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .generator:
                    
                    XCTKForAll(
                        using:      Generator<Int>.arbitrary(),
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .precondition:
                    
                    XCTKForAll(
                        where:      { (_: Int) in true },
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .preconditionGenerator:
                    
                    XCTKForAll(
                        using:      Generator<Int>.arbitrary(),
                        where:      { (_: Int) in true },
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) in
                        
                        XCTKAssertTrue(false)
                    }
            }
        }
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    /// Asserts that the message of the specified property evaluator is
    /// evaluated only once when the evaluator fails due to exhaustion.
    /// - Parameter useGenerator: Whether to use a generator evaluator.
    private func testMessageEvalOnceOnExhaustion(
        useGenerator: Bool
    )
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let propertyOptions = PropertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               50
        )
        
        let options = TestOptions(propertyOptions: propertyOptions)
        
        withOneExpectedFailure
        {
            if useGenerator
            {
                XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    where:      { (_: Int) in false },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) in
                }
            }
            else
            {
                XCTKForAll(
                    where:      { (_: Int) in false },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) in
                }
            }
        }
        
        XCTAssertEqual(count, 1)
    }
}
