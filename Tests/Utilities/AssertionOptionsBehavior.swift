//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
@testable import XCTestKit



extension XCTestKitCase
{
    // MARK: - Functions

    /// Asserts that specified assertion behaves differently based on the
    /// provided options.
    ///
    /// - Note: This does nothing other than for the diff-based equality
    /// assertion. The remaining assertions do not have diffs or output that
    /// would be affected by the options. The options code path is validated
    /// for all assertions as part of the error-throwing tests.
    ///
    /// - Parameter kind: The assertion to use.
    internal func testFunctionAssertionOptionsBehavior(
        _ kind: AssertionKind
    )
    {
        let body1   : () -> Void
        let body2   : () -> Void
        
        switch kind
        {
            case .equal:
                
                let options1    : XCTKOptions   = .init(diffEnabled: true)
                let options2    : XCTKOptions   = .init(diffEnabled: false)
                
                body1 =
                {
                    XCTKAssertEqual(
                        1,
                        2,
                        options: options1
                    )
                }
                
                body2 =
                {
                    XCTKAssertEqual(
                        1,
                        2,
                        options: options2
                    )
                }
                
            case
                .assert,
                .notEqual,
                .equalWithAccuracy,
                .notEqualWithAccuracy,
                .identical,
                .notIdentical,
                .greaterThan,
                .greaterThanOrEqual,
                .lessThan,
                .lessThanOrEqual,
                .nil,
                .notNil,
                .unwrap,
                .true,
                .false,
                .fail,
                .throwsError,
                .noThrow:
                
                return
                
        }
        
        let output1 : String?   = withOneExpectedFailure { body1() }
        let output2 : String?   = withOneExpectedFailure { body2() }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertNotEqual(output1, output2)
    }



    // MARK: - Macros

    /// Asserts that specified macro assertion behaves differently based on the
    /// given options.
    ///
    /// - Note: This does nothing other than for boolean assertions and the
    /// diff-based equality assertion. The remaining assertions do not have
    /// diffs or decomposed expressions to output that would be affected by
    /// the options. The options code path is validated for all assertions as
    /// part of the error-throwing tests.
    ///
    /// - Parameter kind: The assertion to use.
    internal func testMacroAssertionOptionsBehavior(
        _ kind: AssertionKind
    )
    {
        let body1   : () -> Void
        let body2   : () -> Void
        
        switch kind
        {
            case .assert:
                
                let a   : Bool  = true
                let b   : Bool  = false
                
                var options1    : XCTKOptions   = .init()
                var options2    : XCTKOptions   = .init()
                
                options1.formatOptions.showAllEvaluated     = true
                options2.formatOptions.showAllEvaluated     = false
                
                body1 =
                {
                    #XCTKAssert(
                        a && b,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssert(
                        a && b,
                        options: options2
                    )
                }
                
            case .equal:
                
                let options1    : XCTKOptions   = .init(diffEnabled: true)
                let options2    : XCTKOptions   = .init(diffEnabled: false)
                
                body1 =
                {
                    #XCTKAssertEqual(
                        1,
                        2,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertEqual(
                        1,
                        2,
                        options: options2
                    )
                }
                
            case .true:
                
                let a   : Bool  = true
                let b   : Bool  = false
                
                var options1    : XCTKOptions   = .init()
                var options2    : XCTKOptions   = .init()
                
                options1.formatOptions.showAllEvaluated     = true
                options2.formatOptions.showAllEvaluated     = false
                
                body1 =
                {
                    #XCTKAssertTrue(
                        a && b,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertTrue(
                        a && b,
                        options: options2
                    )
                }
                
            case .false:
                
                let a   : Bool  = true
                let b   : Bool  = false
                
                var options1    : XCTKOptions   = .init()
                var options2    : XCTKOptions   = .init()
                
                options1.formatOptions.showNotEvaluatedCount    = true
                options2.formatOptions.showNotEvaluatedCount    = false
                
                body1 =
                {
                    #XCTKAssertFalse(
                        a || b,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertFalse(
                        a || b,
                        options: options2
                    )
                }
                
            case
                .notEqual,
                .equalWithAccuracy,
                .notEqualWithAccuracy,
                .identical,
                .notIdentical,
                .greaterThan,
                .greaterThanOrEqual,
                .lessThan,
                .lessThanOrEqual,
                .nil,
                .notNil,
                .unwrap,
                .fail,
                .throwsError,
                .noThrow:
                
                return
                
        }
        
        let output1 : String?   = withOneExpectedFailure { body1() }
        let output2 : String?   = withOneExpectedFailure { body2() }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertNotEqual(output1, output2)
    }
}
