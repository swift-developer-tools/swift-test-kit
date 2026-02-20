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



extension TestKitCase
{
    // MARK: - Functions

    /// Asserts that specified assertion behaves differently based on the
    /// given options.
    ///
    /// - Note: This tests only assertions with output that would be affected
    /// by the options. Other assertions will fail. The options code path is
    /// validated for all assertions as part of the error-throwing tests.
    ///
    /// - Parameter kind: The assertion to test.
    internal func assertFuncAssertionOptionsBehavior(
        _ kind: AssertionKind
    )
    {
        let body1   : () -> Void
        let body2   : () -> Void
        
        switch kind
        {
            case .equal:
                
                let options1    = TestOptions(diffEnabled: true)
                let options2    = TestOptions(diffEnabled: false)
                
                body1 =
                {
                    TKAssertEqual(
                        1,
                        2,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertEqual(
                        1,
                        2,
                        options: options2
                    )
                }
                
            case .satisfyAll:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection  : [Int]             = [1, 2, 3, 4, 5]
                let predicate   : (Int) -> Bool     = { $0 > 10 }
                
                body1 =
                {
                    TKAssertAllSatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertAllSatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAny:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertAnySatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertAnySatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyNone:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection  : [Int]             = [1, 2, 3, 4, 5]
                let predicate   : (Int) -> Bool     = { $0 < 10 }
                
                body1 =
                {
                    TKAssertNoneSatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertNoneSatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAtLeast:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertSatisfy(
                        collection,
                        atLeast: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertSatisfy(
                        collection,
                        atLeast: 2,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAtMost:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertSatisfy(
                        collection,
                        atMost: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertSatisfy(
                        collection,
                        atMost: 2,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyRange:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertSatisfy(
                        collection,
                        range: 1...3,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertSatisfy(
                        collection,
                        range: 1...3,
                        predicate,
                        options: options2
                    )
                }
                
            case .exactly:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertExactly(
                        collection,
                        count: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertExactly(
                        collection,
                        count: 5,
                        predicate,
                        options: options2
                    )
                }
                
            case .exactlyOne:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    TKAssertExactlyOne(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertExactlyOne(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .unique:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 1, 2, 2, 3, 3]
                
                body1 =
                {
                    TKAssertUnique(
                        collection,
                        options: options1
                    )
                }
                
                body2 =
                {
                    TKAssertUnique(
                        collection,
                        options: options2
                    )
                }
                
            case .uniqueByKey:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [String] = ["a", "ab", "b", "bc", "c", "cd"]
                
                let predicate: (String) -> String.Element? = { $0.first }
                
                body1 =
                {
                    TKAssertUnique(
                        collection,
                        by:         predicate,
                        options:    options1
                    )
                }
                
                body2 =
                {
                    TKAssertUnique(
                        collection,
                        by:         predicate,
                        options:    options2
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
                .noThrow,
                .sorted:
                
                XCTFail("Invalid assertion: \(kind.name)")
                return
                
        }
        
        let output1 : String?   = withOneExpectedFailure { body1() }
        let output2 : String?   = withOneExpectedFailure { body2() }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertNotEqual(output1, output2)
    }



    // MARK: - Macros

    /// Asserts that specified assertion behaves differently based on the
    /// given options.
    ///
    /// - Note: This tests only assertions with output that would be affected
    /// by the options. Other assertions will fail. The options code path is
    /// validated for all assertions as part of the error-throwing tests.
    ///
    /// - Parameter kind: The assertion to test.
    internal func assertMacroAssertionOptionsBehavior(
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
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
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
                
                let options1    = TestOptions(diffEnabled: true)
                let options2    = TestOptions(diffEnabled: false)
                
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
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
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
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
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
                
            case .satisfyAll:
                            
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection  : [Int]             = [1, 2, 3, 4, 5]
                let predicate   : (Int) -> Bool     = { $0 > 10 }
                
                body1 =
                {
                    #XCTKAssertAllSatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertAllSatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAny:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertAnySatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertAnySatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyNone:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection  : [Int]             = [1, 2, 3, 4, 5]
                let predicate   : (Int) -> Bool     = { $0 < 10 }
                
                body1 =
                {
                    #XCTKAssertNoneSatisfy(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertNoneSatisfy(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAtLeast:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        atLeast: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        atLeast: 2,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyAtMost:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        atMost: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        atMost: 2,
                        predicate,
                        options: options2
                    )
                }
                
            case .satisfyRange:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        range: 1...3,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertSatisfy(
                        collection,
                        range: 1...3,
                        predicate,
                        options: options2
                    )
                }
                
            case .exactly:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertExactly(
                        collection,
                        count: 2,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertExactly(
                        collection,
                        count: 5,
                        predicate,
                        options: options2
                    )
                }
                
            case .exactlyOne:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 2, 3, 4, 5]
                
                let predicate: (Int) throws -> Bool
                    = { _ in throw TestError() }
                
                body1 =
                {
                    #XCTKAssertExactlyOne(
                        collection,
                        predicate,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertExactlyOne(
                        collection,
                        predicate,
                        options: options2
                    )
                }
                
            case .unique:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [Int] = [1, 1, 2, 2, 3, 3]
                
                body1 =
                {
                    #XCTKAssertUnique(
                        collection,
                        options: options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertUnique(
                        collection,
                        options: options2
                    )
                }
                
            case .uniqueByKey:
                
                var options1    = TestOptions()
                var options2    = TestOptions()
                
                options1.formatOptions.maxDiffs     = nil
                options2.formatOptions.maxDiffs     = 1
                
                let collection: [String] = ["a", "ab", "b", "bc", "c", "cd"]
                
                let predicate: (String) -> String.Element? = { $0.first }
                
                body1 =
                {
                    #XCTKAssertUnique(
                        collection,
                        by:         predicate,
                        options:    options1
                    )
                }
                
                body2 =
                {
                    #XCTKAssertUnique(
                        collection,
                        by:         predicate,
                        options:    options2
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
                .noThrow,
                .sorted:
                
                XCTFail("Invalid assertion: \(kind.macroDisplayName)")
                return
                
        }
        
        let output1 : String?   = withOneExpectedFailure { body1() }
        let output2 : String?   = withOneExpectedFailure { body2() }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertNotEqual(output1, output2)
    }
}
