//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TestKitMacroCore



// MARK: - XCTKMacro

internal protocol XCTKMacro: AssertionMacro { }

extension XCTKMacro
{
    internal static var framework: FrameworkKind { .xctk }
}



// MARK: - Boolean

internal struct XCTKAssertMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .assert
}

internal struct XCTKAssertTrueMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .true
}

internal struct XCTKAssertFalseMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .false
}



// MARK: - Nil and non-nil

internal struct XCTKAssertNilMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .nil
}

internal struct XCTKAssertNotNilMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notNil
}

internal struct XCTKUnwrapMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .unwrap
}



// MARK: - Equality and inequality

internal struct XCTKAssertEqualMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .equal
}

internal struct XCTKAssertNotEqualMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notEqual
}

internal struct XCTKAssertIdenticalMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .identical
}

internal struct XCTKAssertNotIdenticalMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notIdentical
}

internal struct XCTKAssertEqualWithAccuracyMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .equalWithAccuracy
}

internal struct XCTKAssertNotEqualWithAccuracyMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notEqualWithAccuracy
}



// MARK: - Comparable

internal struct XCTKAssertGreaterThanMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .greaterThan
}

internal struct XCTKAssertGreaterThanOrEqualMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .greaterThanOrEqual
}

internal struct XCTKAssertLessThanOrEqualMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .lessThanOrEqual
}

internal struct XCTKAssertLessThanMacro
    : DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .lessThan
}



// MARK: - Error

internal struct XCTKAssertThrowsErrorMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .throwsError
}

internal struct XCTKAssertNoThrowMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .noThrow
}



// MARK: - Fail

internal struct XCTKFailMacro
    : NoExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .fail
}



// MARK: - Predicate

internal struct XCTKAssertSatisfyAllMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAll
}

internal struct XCTKAssertSatisfyAnyMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAny
}

internal struct XCTKAssertSatisfyNoneMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyNone
}

internal struct XCTKAssertSatisfyAtLeastMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAtLeast
}

internal struct XCTKAssertSatisfyAtMostMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAtMost
}

internal struct XCTKAssertSatisfyRangeMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyRange
}

internal struct XCTKAssertExactlyMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .exactly
}

internal struct XCTKAssertExactlyOneMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .exactlyOne
}

internal struct XCTKAssertSortedMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .sorted
}

internal struct XCTKAssertUniqueMacro
    : SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .unique
}

internal struct XCTKAssertUniqueByKeyMacro
    : DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .uniqueByKey
}
