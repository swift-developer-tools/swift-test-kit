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



internal final class FunctionAssertionOutputTests: TestKitCase
{
    private typealias AK = AssertionKind
    
    private static let message: String = "hello world"
    
    
    
    // MARK: - Boolean
    
    func testAssertFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssert(
                false,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.assert.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertTrueFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertTrue(
                false,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.true.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertFalseFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertFalse(
                true,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.false.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nil and non-nil
    
    func testAssertNilFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNil(
                10,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.nil.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotNilFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNotNil(
                Optional<Int>(nil),
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.notNil.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnwrapFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            _ = try TKUnwrap(
                Optional<Int>(nil),
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.unwrap.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Equality and inequality
    
    func testAssertEqualFailureMessage()
    {
        struct User: Equatable
        {
            let name: String
        }
        
        let exp : User  = .init(name: "a")
        let act : User  = .init(name: "b")
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertEqual(
                exp,
                act,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.equal.name) failed - \(Self.message)

        \(typeName(of: exp)) differs at:

            .name, character 1
                Expected:   \(quote(exp.name))
                Actual:     \(quote(act.name))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testNotEqualFailureMessage()
    {
        let expr: Int = 10
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNotEqual(
                expr,
                expr,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr)))"
        
        let expected: String =
        """
        \(AK.notEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testIdenticalFailureMessage()
    {
        let expr1   : NSObject  = .init()
        let expr2   : NSObject  = .init()
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertIdentical(
                expr1,
                expr2,
                Self.message
            )
        }
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains("\(AK.identical.name) failed:"))
        XCTAssertTrue(actual!.contains(" is not identical to"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
    }
    
    
    
    func testNotIdenticalFailureMessage()
    {
        let expr: NSObject = .init()
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNotIdentical(
                expr,
                expr,
                Self.message
            )
        }
        
        /// The failure reason includes memory addresses which vary, so this
        /// test only checks the structure instead of the exact output.
        XCTAssertNotNil(actual)
        XCTAssertTrue(actual!.contains("\(AK.notIdentical.name) failed:"))
        XCTAssertTrue(actual!.contains(" both values are identical"))
        XCTAssertTrue(actual!.contains(" - \(Self.message)"))
    }
    
    
    
    func testAssertEqualFloatAccuracyFailureMessage()
    {
        let expr1       : Double    = 1.0
        let expr2       : Double    = 2.0
        let accuracy    : Double    = 0.5
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertEqualIntAccuracyFailureMessage()
    {
        let expr1       : Int   = 0
        let expr2       : Int   = 2
        let accuracy    : Int   = 1
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not equal to"
            + " (\(quote(expr2))) +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.equalWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualFloatAccuracyFailureMessage()
    {
        let expr1       : Double    = 0.0
        let expr2       : Double    = 1.0
        let accuracy    : Double    = 1.0
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNotEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNotEqualIntAccuracyFailureMessage()
    {
        let expr1       : Int   = 0
        let expr2       : Int   = 1
        let accuracy    : Int   = 1
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNotEqual(
                expr1,
                expr2,
                accuracy: accuracy,
                Self.message
            )
        }
        
        let reason: String = "both values equal (\(quote(expr1)))"
            + " +/- (\(quote(accuracy)))"
        
        let expected: String =
        """
        \(AK.notEqualWithAccuracy.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Comparable
    
    func testAssertGreaterThanFailureMessage()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertGreaterThan(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than"
            + " (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.greaterThan.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertGreaterThanOrEqualFailureMessage()
    {
        let expr1   : Int   = 0
        let expr2   : Int   = 1
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertGreaterThanOrEqual(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not greater than or equal"
            + " to (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.greaterThanOrEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanOrEqualFailureMessage()
    {
        let expr1   : Int   = 1
        let expr2   : Int   = 0
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertLessThanOrEqual(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than or equal"
            + " to (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.lessThanOrEqual.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertLessThanFailureMessage()
    {
        let expr1   : Int   = 1
        let expr2   : Int   = 0
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertLessThan(
                expr1,
                expr2,
                Self.message
            )
        }
        
        let reason: String = "(\(quote(expr1))) is not less than"
            + " (\(quote(expr2)))"
        
        let expected: String =
        """
        \(AK.lessThan.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Error
    
    func testAssertThrowsErrorFailureMessage()
    {
        let expr: () throws -> Int = { return 0 }
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertThrowsError(
                expr,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.throwsError.name) failed - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNoThrowFailureMessage()
    {
        let error   : TestError         = .init()
        let expr    : () throws -> Int  = { throw error }
        
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNoThrow(
                try expr(),
                Self.message
            )
        }
        
        let reason: String = "threw error \(quote(error))"
        
        let expected: String =
        """
        \(AK.noThrow.name) failed: \(reason) - \(Self.message)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Fail
    
    func testFailFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKFail(
                Self.message,
                file: #filePath,
                line: #line
            )
        }
        
        XCTAssertEqual(Self.message, actual)
    }
    
    
    
    // MARK: - Predicate
    
    func testAssertAllSatisfyFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertAllSatisfy(
                [2, 3, 6],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAll.name) failed - \(Self.message)
        
        Collection count: 3
        
        Failed: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertAnySatisfyFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertAnySatisfy(
                [1, 3, 5],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAny.name) failed - \(Self.message)
        
        Collection count: 3
        
        Expected: at least 1 match
        Actual:   0 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertNoneSatisfyFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertNoneSatisfy(
                [1, 2, 3],
                { $0 % 2 == 0 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyNone.name) failed - \(Self.message)
        
        Collection count: 3
        
        Matched: 1 of 3
        
            [1]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyAtLeastFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertSatisfy(
                [1, 2, 3, 4],
                atLeast: 3,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAtLeast.name) failed - \(Self.message)
        
        Collection count: 4
        
        Expected: at least 3 matches
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyAtMostFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertSatisfy(
                [1, 2, 3, 4],
                atMost: 1,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyAtMost.name) failed - \(Self.message)
        
        Collection count: 4
        
        Expected: up to 1 match
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSatisfyRangeFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertSatisfy(
                [3, 2, 1, 4, 5],
                range: 0...1,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.satisfyRange.name) failed - \(Self.message)
        
        Collection count: 5
        
        Expected: 0-1 matches
        Actual:   3 matched
        
            Matched: [0], [3-4]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertExactlyFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertExactly(
                [1, 2, 3, 4],
                count: 3,
                { $0 > 2 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.exactly.name) failed - \(Self.message)
        
        Collection count: 4
        
        Expected: exactly 3 matches
        Actual:   2 matched
        
            Matched: [2-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertExactlyOneFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertExactlyOne(
                [1, 2, 3],
                { $0 > 1 },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.exactlyOne.name) failed - \(Self.message)
        
        Collection count: 3
        
        Expected: exactly 1 match
        Actual:   2 matched
        
            Matched: [1-2]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertSortedFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertSorted(
                [1, 3, 2, 4],
                by: <,
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.sorted.name) failed - \(Self.message)
        
        Collection count: 4
        
        Not sorted at:
        
            [1]: 3
            [2]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertUniqueFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertUnique(
                [1, 2, 3, 2],
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.unique.name) failed - \(Self.message)
        
        Collection count: 4
        
        Duplicates: 1 value
        
            2: [1], [3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertUniqueByKeyFailureMessage()
    {
        let actual: String? = withOneExpectedFailure
        {
            TKAssertUnique(
                ["a", "b", "cc"],
                by: { $0.count },
                Self.message
            )
        }
        
        let expected: String =
        """
        \(AK.uniqueByKey.name) failed - \(Self.message)
        
        Collection count: 3
        
        Duplicates: 1 key
        
            Key 1:
                [0]: \(quote("a"))
                [1]: \(quote("b"))
        """
        
        XCTAssertEqual(expected, actual)
    }
}
