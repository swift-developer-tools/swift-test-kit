//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TKTestSupport
import XCTest



internal final class FormatterPredicateTests: XCTestCaseStopOnFail
{
    private typealias PFK = PredicateFailureKind
    
    
    
    // MARK: - Elements failed
    
    func testSingleFailedElement() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 1, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Failed: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleFailedElements() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 2, value: 3),
            ElementResult(index: 4, value: 5)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Failed: 3 of 5
        
            [0]: 1
            [2]: 3
            [4]: 5
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMacroCaptureShowsCollectionAndPredicate() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 1, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let collectionText  : String =  "[2, 3, 6]"
        let predicateText   : String =  "{ $0 % 2 == 0 }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: \(collectionText)
        Predicate:  \(predicateText)
        
        Failed: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testFailedElementWithError() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 2, value: 3, error: "error1")
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Failed: 2 of 3
        
            [0]: 1
            [2]: 3 (threw error \(quote("error1")))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUnorderedCollectionOmitsIndices() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 2, value: 5)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Failed: 2 of 3
        
            1
            5
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testFailedStringElementsAreQuoted() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 1, value: "a")
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Failed: 1 of 3
        
            [1]: \(quote("a"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAllElementsFailed() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 1, value: 2),
            ElementResult(index: 2, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Failed: 3 of 3
        
            [0]: 1
            [1]: 2
            [2]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsTruncatesElements() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 1, value: 3),
            ElementResult(index: 2, value: 5),
            ElementResult(index: 3, value: 7)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Failed: 4 of 5
        
            [0]: 1
            [1]: 3
        
            ... and more elements (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxDiffsWithCountDiffs() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 1, value: 3),
            ElementResult(index: 2, value: 5),
            ElementResult(index: 3, value: 7)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Failed: 4 of 5
        
            [0]: 1
            [1]: 3
        
            ... and 2 more elements
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testElementsFailedCollectionTextWithoutPredicateText() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 1, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     "[1, 2, 3]",
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: [1, 2, 3]
        
        Failed: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testElementsFailedMaxDiffsAtExactBoundar() throws
    {
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 1, value: 3),
            ElementResult(index: 2, value: 5)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 3)
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Failed: 3 of 5
        
            [0]: 1
            [1]: 3
            [2]: 5
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Elements matched
    
    func testSingleMatchedElement() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 1, value: 2)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Matched: 1 of 3
        
            [1]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleMatchedElements() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 2),
            ElementResult(index: 2, value: 4),
            ElementResult(index: 3, value: 6)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Matched: 3 of 4
        
            [0]: 2
            [2]: 4
            [3]: 6
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedElementWithError() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 2, value: 3, error: "error1")
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Matched: 2 of 3
        
            [0]: 1
            [2]: 3 (threw error \(quote("error1")))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedElementsUnorderedOmitsIndices() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 2),
            ElementResult(index: 1, value: 4)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Matched: 2 of 3
        
            2
            4
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedElementsMacroCapture() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 1, value: 2)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let collectionText  : String =  "[1, 2, 3]"
        let predicateText   : String =  "{ $0 % 2 == 0 }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: \(collectionText)
        Predicate:  \(predicateText)
        
        Matched: 1 of 3
        
            [1]: 2
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedElementsMaxDiffsTruncation() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 2),
            ElementResult(index: 1, value: 4),
            ElementResult(index: 2, value: 6),
            ElementResult(index: 3, value: 8)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Matched: 4 of 5
        
            [0]: 2
            [1]: 4
        
            ... and more elements (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedElementsMaxDiffsWithCountDiffs() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 2),
            ElementResult(index: 1, value: 4),
            ElementResult(index: 2, value: 6),
            ElementResult(index: 3, value: 8)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               kind,
            isOrdered:          true
        )
        
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Matched: 4 of 5
        
            [0]: 2
            [1]: 4
        
            ... and 2 more elements
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMatchedStringElementsAreQuoted() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 1, value: "a")
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Matched: 1 of 3
        
            [1]: \(quote("a"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAllElementsMatched() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 0, value: 1),
            ElementResult(index: 1, value: 2),
            ElementResult(index: 2, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Matched: 3 of 3
        
            [0]: 1
            [1]: 2
            [2]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testElementsMatchedCollectionTextWithoutPredicateText() throws
    {
        let kind = PFK.elementsMatched([
            ElementResult(index: 1, value: 3)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     "[1, 2, 3]",
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: [1, 2, 3]
        
        Matched: 1 of 3
        
            [1]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Count mismatch
    
    func testCountMismatchAtLeastWithNoMatches() throws
    {
        let mismatch = CountMismatch(
            expected:           .atLeast(3),
            matchedIndices:     []
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Expected: at least 3 matches
        Actual:   0 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchAtMostWithCoalescedIndices() throws
    {
        let mismatch = CountMismatch(
            expected:           .atMost(2),
            matchedIndices:     [0, 1, 2, 5, 6, 9]
        )
        
        let failure = PredicateFailure(
            collectionCount:    10,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 10
        
        Expected: up to 2 matches
        Actual:   6 matched
        
            Matched: [0-2], [5-6], [9]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchExactlySingularForm() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(1),
            matchedIndices:     [0, 2]
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Expected: exactly 1 match
        Actual:   2 matched
        
            Matched: [0], [2]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchAtLeastSingularForm() throws
    {
        let mismatch = CountMismatch(
            expected:           .atLeast(1),
            matchedIndices:     []
        )
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Expected: at least 1 match
        Actual:   0 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchAtMostSingularForm() throws
    {
        let mismatch = CountMismatch(
            expected:           .atMost(1),
            matchedIndices:     [0, 2, 4]
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Expected: up to 1 match
        Actual:   3 matched
        
            Matched: [0], [2], [4]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchRangeExpectation() throws
    {
        let mismatch = CountMismatch(
            expected:           .range(2...4),
            matchedIndices:     [0]
        )
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Expected: 2-4 matches
        Actual:   1 matched
        
            Matched: [0]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchAnyExpectation() throws
    {
        let mismatch = CountMismatch(
            expected:           .any,
            matchedIndices:     []
        )
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Expected: at least 1 match
        Actual:   0 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchUnorderedOmitsMatchedIndices() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(1),
            matchedIndices:     [0, 1, 2]
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .countMismatch(mismatch),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Expected: exactly 1 match
        Actual:   3 matched
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchWithErrors() throws
    {
        let mismatch = CountMismatch(
            expected:           .atLeast(3),
            matchedIndices:     [0],
            errorElements:
            [
                ElementResult(index: 2, value: "a", error: "error1"),
                ElementResult(index: 4, value: "b", error: "error2")
            ]
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Expected: at least 3 matches
        Actual:   1 matched, 2 threw errors
        
            Matched: [0]
        
            Threw errors:
                [2]: \(quote("a")) (threw error \(quote("error1")))
                [4]: \(quote("b")) (threw error \(quote("error2")))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchUnorderedWithErrors() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(2),
            matchedIndices:     [],
            errorElements:
            [
                ElementResult(index: 0, value: 10, error: "error1")
            ]
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .countMismatch(mismatch),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Expected: exactly 2 matches
        Actual:   0 matched, 1 threw errors
        
            Threw errors:
                10 (threw error \(quote("error1")))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchMacroCaptureOfLongCollectionText() throws
    {
        let mismatch = CountMismatch(
            expected:           .atLeast(5),
            matchedIndices:     [0, 1]
        )
        
        let failure = PredicateFailure(
            collectionCount:    20,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let collectionText: String = "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10,"
            + "11, 12, 13, 14, 15, 16, 17, 18, 19, 20]"
        
        let predicateText: String =  "{ $0 < 3 }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init(maxLineLength: 60)
        )
        
        /// 60 - 12 (label) = 48
        /// Truncated t0 48 characters: 45 collection characters + 3 (ellipsis)
        let truncatedCollectionText = String(collectionText.prefix(45)) + "..."
        
        let expected: String =
        """
        Collection count: 20
        
        Collection: \(truncatedCollectionText)
        Predicate:  \(predicateText)
        
        Expected: at least 5 matches
        Actual:   2 matched
        
            Matched: [0-1]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchWithErrorsMaxDiffsTruncation() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(0),
            matchedIndices:     [],
            errorElements:
            [
                ElementResult(index: 0, value: "a", error: "error1"),
                ElementResult(index: 1, value: "b", error: "error2"),
                ElementResult(index: 2, value: "c", error: "error3")
            ]
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Expected: exactly 0 matches
        Actual:   0 matched, 3 threw errors
        
            Threw errors:
                [0]: \(quote("a")) (threw error \(quote("error1")))
                [1]: \(quote("b")) (threw error \(quote("error2")))
        
            ... and 1 more element
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchErrorsMaxDiffsWithoutCountDiffs() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(0),
            matchedIndices:     [],
            errorElements:
            [
                ElementResult(index: 0, value: "a", error: "error1"),
                ElementResult(index: 1, value: "b", error: "error2"),
                ElementResult(index: 2, value: "c", error: "error3")
            ]
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Expected: exactly 0 matches
        Actual:   0 matched, 3 threw errors
        
            Threw errors:
                [0]: \(quote("a")) (threw error \(quote("error1")))
                [1]: \(quote("b")) (threw error \(quote("error2")))
        
            ... and more elements (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchSingleContiguousRange() throws
    {
        let mismatch = CountMismatch(
            expected:           .atMost(2),
            matchedIndices:     [0, 1, 2, 3]
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Expected: up to 2 matches
        Actual:   4 matched
        
            Matched: [0-3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchMacroCapture() throws
    {
        let mismatch = CountMismatch(
            expected:           .exactly(2),
            matchedIndices:     [0, 1, 3]
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let collectionText  : String =  "[10, 20, 30, 40, 50]"
        let predicateText   : String =  "{ $0 > 25 }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Collection: \(collectionText)
        Predicate:  \(predicateText)
        
        Expected: exactly 2 matches
        Actual:   3 matched
        
            Matched: [0-1], [3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCountMismatchWithMatchedIndicesAndErrorsTruncated() throws
    {
        let mismatch = CountMismatch(
            expected:           .atLeast(4),
            matchedIndices:     [0, 1],
            errorElements:
            [
                ElementResult(index: 2, value: "a", error: "error1"),
                ElementResult(index: 3, value: "b", error: "error2"),
                ElementResult(index: 4, value: "c", error: "error3")
            ]
        )
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .countMismatch(mismatch),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Expected: at least 4 matches
        Actual:   2 matched, 3 threw errors
        
            Matched: [0-1]
        
            Threw errors:
                [2]: \(quote("a")) (threw error \(quote("error1")))
                [3]: \(quote("b")) (threw error \(quote("error2")))
        
            ... and 1 more element
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Ordering violation
    
    func testOrderingViolationBasic() throws
    {
        let violation = OrderingViolation(
            index:      1,
            first:      5,
            second:     3
        )
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Not sorted at:
        
            [1]: 5
            [2]: 3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationError() throws
    {
        let violation = OrderingViolation(
            index:      0,
            first:      1,
            second:     2,
            error:      "error1"
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Threw error at:
        
            [0]: 1
            [1]: 2
            Error: \(quote("error1"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationMacroCapture() throws
    {
        let violation = OrderingViolation(
            index:      2,
            first:      10,
            second:     7
        )
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let collectionText  : String =  "[1, 3, 10, 7, 9]"
        let predicateText   : String =  "{ $0 < $1 }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Collection: \(collectionText)
        Predicate:  \(predicateText)
        
        Not sorted at:
        
            [2]: 10
            [3]: 7
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationStringsValuesAreQuoted() throws
    {
        let violation = OrderingViolation(
            index:      0,
            first:      "a",
            second:     "b"
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Not sorted at:
        
            [0]: \(quote("a"))
            [1]: \(quote("b"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationAtHighIndex() throws
    {
        let violation = OrderingViolation(
            index:      8,
            first:      100,
            second:     50
        )
        
        let failure = PredicateFailure(
            collectionCount:    10,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 10
        
        Not sorted at:
        
            [8]: 100
            [9]: 50
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationWithStringValues() throws
    {
        let violation = OrderingViolation(
            index:      1,
            first:      "b",
            second:     "a",
            error:      "error1"
        )
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Threw error at:
        
            [1]: \(quote("b"))
            [2]: \(quote("a"))
            Error: \(quote("error1"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Duplicates
    
    func testDuplicatesSingleGroup() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 5, indices: [1, 3])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Duplicates: 1 value
        
            5: [1], [3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesMultipleGroupsWithCoalescedIndices() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 1, indices: [0, 1, 2, 5]),
            .init(value: 9, indices: [3, 4])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    7,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 7
        
        Duplicates: 2 values
        
            1: [0-2], [5]
            9: [3-4]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesUnorderedMultipleGroups() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 1, indices: [0, 1]),
            .init(value: 2, indices: [2, 3, 4])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .duplicates(groups),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Duplicates: 2 values
        
            1: 2 occurrences
            2: 3 occurrences
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesUnorderedShowsOccurrenceCount() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: true, indices: [0, 1, 2])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .duplicates(groups),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Duplicates: 1 value
        
            true: 3 occurrences
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateStringsValuesAreQuoted() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: "a", indices: [0, 2]),
            .init(value: "b", indices: [1, 3])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Duplicates: 2 values
        
            \(quote("a")): [0], [2]
            \(quote("b")): [1], [3]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesMaxDiffsTruncation() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 1, indices: [0, 3]),
            .init(value: 2, indices: [1, 4]),
            .init(value: 3, indices: [2, 5])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Duplicates: 3 values
        
            1: [0], [3]
            2: [1], [4]
        
            ... and more elements (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesMaxDiffsWithCountDiffs() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 1, indices: [0, 3]),
            .init(value: 2, indices: [1, 4]),
            .init(value: 3, indices: [2, 5])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 1, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Duplicates: 3 values
        
            1: [0], [3]
        
            ... and 2 more elements
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesCollectionTextWithoutPredicateText() throws
    {
        let groups: [DuplicateGroup] =
        [
            .init(value: 5, indices: [0, 2, 4])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let collectionText: String = "[5, 3, 5, 7, 5]"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Collection: \(collectionText)
        
        Duplicates: 1 value
        
            5: [0], [2], [4]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Duplicate keys
    
    func testDuplicatesKeysSingleGroup() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: "a",
                elements:
                [
                    IndexedElement(0, "abc"),
                    IndexedElement(2, "aaa")
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Duplicates: 1 key
        
            Key \(quote("a")):
                [0]: \(quote("abc"))
                [2]: \(quote("aaa"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesKeysMultipleGroups() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: 1,
                elements:
                [
                    IndexedElement(0, 10),
                    IndexedElement(3, 30)
                ]
            ),
            
            .init(
                key: 2,
                elements:
                [
                    IndexedElement(1, 20),
                    IndexedElement(2, 25),
                    IndexedElement(4, 40)
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    5,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 5
        
        Duplicates: 2 keys
        
            Key 1:
                [0]: 10
                [3]: 30
        
            Key 2:
                [1]: 20
                [2]: 25
                [4]: 40
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesKeysUnorderedShowsElementCount() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: "a",
                elements:
                [
                    IndexedElement(0, 1),
                    IndexedElement(1, 2),
                    IndexedElement(2, 3)
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    4,
            kind:               .duplicateKeys(groups),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 4
        
        Duplicates: 1 key
        
            Key \(quote("a")):
                3 elements
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateKeysUnorderedSingularElementCount() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key:        "a",
                elements:   [IndexedElement(0, 10)]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .duplicateKeys(groups),
            isOrdered:          false
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Duplicates: 1 key
        
            Key \(quote("a")):
                1 element
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateKeysMacroCapture() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: "a",
                elements:
                [
                    IndexedElement(0, "abc"),
                    IndexedElement(2, "aaa")
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let collectionText  : String    = #"["abc", "xyz", "aaa"]"#
        let predicateText   : String    = "{ $0.first! }"
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            predicateText:      predicateText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: \(collectionText)
        Predicate:  \(predicateText)
        
        Duplicates: 1 key
        
            Key \(quote("a")):
                [0]: \(quote("abc"))
                [2]: \(quote("aaa"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateKeysMaxDiffsTruncation() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: 1,
                elements:
                [
                    IndexedElement(0, 10),
                    IndexedElement(3, 30)
                ]
            ),
            
            .init(
                key: 2,
                elements:
                [
                    IndexedElement(1, 20),
                    IndexedElement(4, 40)
                ]
            ),
        
            .init(
                key: 3,
                elements:
                [
                    IndexedElement(2, 25),
                    IndexedElement(5, 50)
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2)
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Duplicates: 3 keys
        
            Key 1:
                [0]: 10
                [3]: 30
        
            Key 2:
                [1]: 20
                [4]: 40
        
            ... and more elements (limit: 2)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateKeysMaxDiffsWithCountDiffs() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: 1,
                elements:
                [
                    IndexedElement(0, 10),
                    IndexedElement(3, 30)
                ]
            ),
            
            .init(
                key: 2,
                elements:
                [
                    IndexedElement(1, 20),
                    IndexedElement(4, 40)
                ]
            ),
        
            .init(
                key: 3,
                elements:
                [
                    IndexedElement(2, 25),
                    IndexedElement(5, 50)
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    6,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init(maxDiffs: 2, countDiffs: true)
        )
        
        let expected: String =
        """
        Collection count: 6
        
        Duplicates: 3 keys
        
            Key 1:
                [0]: 10
                [3]: 30
        
            Key 2:
                [1]: 20
                [4]: 40
        
            ... and 1 more element
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicateKeysCollectionTextWithoutPredicateText() throws
    {
        let groups: [DuplicateKeyGroup] =
        [
            .init(
                key: "a",
                elements:
                [
                    IndexedElement(0, "abc"),
                    IndexedElement(2, "aaa")
                ]
            )
        ]
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .duplicateKeys(groups),
            isOrdered:          true
        )
        
        let collectionText: String = #"["abc", "xyz", "aaa"]"#
        
        let actual: String = Formatter.formatPredicate(
            failure,
            collectionText:     collectionText,
            options:            .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Collection: \(collectionText)
        
        Duplicates: 1 key
        
            Key \(quote("a")):
                [0]: \(quote("abc"))
                [2]: \(quote("aaa"))
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Multi-line values
    
    func testFailedElementWithMultiLineValues() throws
    {
        let element = MultiLineValue("a", 1)
        
        let kind = PFK.elementsFailed([
            ElementResult(index: 0, value: element)
        ])
        
        let failure = PredicateFailure(
            collectionCount:    2,
            kind:               kind,
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 2
        
        Failed: 1 of 2
        
            [0]: MultiLineValue:     name: a     value: 1
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDuplicatesWithMultiLineValues() throws
    {
        let element = MultiLineValue("a", 1)
        
        let groups: [DuplicateGroup] =
        [
            .init(value: element, indices: [0, 2])
        ]
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .duplicates(groups),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Duplicates: 1 value
        
            MultiLineValue:     name: a     value: 1: [0], [2]
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testOrderingViolationWithMultiLineValues() throws
    {
        let element1 = MultiLineValue("b", 2)
        let element2 = MultiLineValue("a", 1)
        
        let violation = OrderingViolation(
            index:  0,
            first:  element1,
            second:     element2
        )
        
        let failure = PredicateFailure(
            collectionCount:    3,
            kind:               .orderingViolation(violation),
            isOrdered:          true
        )
        
        let actual: String = Formatter.formatPredicate(
            failure,
            options: .init()
        )
        
        let expected: String =
        """
        Collection count: 3
        
        Not sorted at:
        
            [0]: MultiLineValue:     name: b     value: 2
            [1]: MultiLineValue:     name: a     value: 1
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Extensions

extension FormatterPredicateTests
{
    /// A type with a multi-line `CustomStringConvertible` description for
    /// testing newline collapsing in ``RenderedValue``.
    private struct MultiLineValue: CustomStringConvertible, Hashable
    {
        let name    : String
        let value   : Int
        
        init(
            _ name  : String,
            _ value : Int
        )
        {
            self.name   = name
            self.value  = value
        }
        
        var description: String
        {
            return """
            MultiLineValue:
                name: \(name)
                value: \(value)
            """
        }
    }
}
