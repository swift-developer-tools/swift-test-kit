//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class ForAllMessageTests: XCTestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    @Reasync
    func testArbitraryMessageNotEvalOnSuccess() async
    {
        await assertMessageNotEvalOnSuccess(.arbitrary)
    }
    
    
    
    @Reasync
    func testArbitraryMessageEvalOnceOnFailure() async
    {
        await assertMessageEvalOnceOnFailure(.arbitrary)
    }
    
    
    
    @Reasync
    func testGeneratorMessageNotEvalOnSuccess() async
    {
        await assertMessageNotEvalOnSuccess(.generator)
    }
    
    
    
    @Reasync
    func testGeneratorMessageEvalOnceOnFailure() async
    {
        await assertMessageEvalOnceOnFailure(.generator)
    }
    
    
    
    @Reasync
    func testPreconditionMessageNotEvalOnSuccess() async
    {
        await assertMessageNotEvalOnSuccess(.precondition)
    }
    
    
    
    @Reasync
    func testPreconditionMessageEvalOnceOnFailure() async
    {
        await assertMessageEvalOnceOnFailure(.precondition)
    }
    
    
    
    @Reasync
    func testPreconditionMessageEvalOnceOnExhaustion() async
    {
        await assertMessageEvalOnceOnExhaustion(useGenerator: false)
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorMessageNotEvalOnSuccess() async
    {
        await assertMessageNotEvalOnSuccess(.preconditionGenerator)
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorMessageEvalOnceOnFailure() async
    {
        await assertMessageEvalOnceOnFailure(.preconditionGenerator)
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorMessageEvalOnceOnExhaustion() async
    {
        await assertMessageEvalOnceOnExhaustion(useGenerator: true)
    }
}



// MARK: - Support

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
    @Reasync
    private func assertMessageNotEvalOnSuccess(
        _ kind: ForAllKind
    ) async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        switch kind
        {
            case .arbitrary:
                
                await XCTKForAll(
                    message(),
                    options: options
                )
                {
                    (_: Int) async in
                }
                
            case .generator:
                
                await XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) async in
                }
                
            case .precondition:
                
                await XCTKForAll(
                    where:      { (_: Int) in true },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) async in
                }
                
            case .preconditionGenerator:
                
                await XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    where:      { (_: Int) in true },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) async in
                }
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    /// Asserts that the message of the specified property evaluator is
    /// evaluated only once when the evaluator fails.
    /// - Parameter kind: The property evaluator to test.
    @Reasync
    private func assertMessageEvalOnceOnFailure(
        _ kind: ForAllKind
    ) async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           50
        )
        
        await withOneExpectedFailure
        {
            switch kind
            {
                case .arbitrary:
                    
                    await XCTKForAll(
                        message(),
                        options: options
                    )
                    {
                        (_: Int) async in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .generator:
                    
                    await XCTKForAll(
                        using:      Generator<Int>.arbitrary(),
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) async in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .precondition:
                    
                    await XCTKForAll(
                        where:      { (_: Int) in true },
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) async in
                        
                        XCTKAssertTrue(false)
                    }
                    
                case .preconditionGenerator:
                    
                    await XCTKForAll(
                        using:      Generator<Int>.arbitrary(),
                        where:      { (_: Int) in true },
                        message:    message(),
                        options:    options
                    )
                    {
                        (_: Int) async in
                        
                        XCTKAssertTrue(false)
                    }
            }
        }
        
        XCTAssertEqual(count, 1)
    }
    
    
    
    /// Asserts that the message of the specified property evaluator is
    /// evaluated only once when the evaluator fails due to exhaustion.
    /// - Parameter useGenerator: Whether to use a generator evaluator.
    @Reasync
    private func assertMessageEvalOnceOnExhaustion(
        useGenerator: Bool
    ) async
    {
        var count   : Int           = 0
        let message : () -> String  = { count += 1; return "msg" }
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               50
        )
        
        await withOneExpectedFailure
        {
            if useGenerator
            {
                await XCTKForAll(
                    using:      Generator<Int>.arbitrary(),
                    where:      { (_: Int) in false },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) async in
                }
            }
            else
            {
                await XCTKForAll(
                    where:      { (_: Int) in false },
                    message:    message(),
                    options:    options
                )
                {
                    (_: Int) async in
                }
            }
        }
        
        XCTAssertEqual(count, 1)
    }
}
