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



// MARK: - STKMacro

internal protocol STKMacro: AssertionMacro { }

extension STKMacro
{
    internal static var framework: FrameworkKind { .xctk }
}



// MARK: - Boolean

internal struct STKAssertMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .assert
}

internal struct STKAssertTrueMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .true
}

internal struct STKAssertFalseMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .false
}



// MARK: - Nil and non-nil

internal struct STKAssertNilMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .nil
}

internal struct STKAssertNotNilMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .notNil
}

internal struct STKUnwrapMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .unwrap
}



// MARK: - Equality and inequality

internal struct STKAssertEqualMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .equal
}

internal struct STKAssertNotEqualMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .notEqual
}

internal struct STKAssertIdenticalMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .identical
}

internal struct STKAssertNotIdenticalMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .notIdentical
}

internal struct STKAssertEqualWithAccuracyMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .equalWithAccuracy
}

internal struct STKAssertNotEqualWithAccuracyMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .notEqualWithAccuracy
}



// MARK: - Comparable

internal struct STKAssertGreaterThanMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .greaterThan
}

internal struct STKAssertGreaterThanOrEqualMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .greaterThanOrEqual
}

internal struct STKAssertLessThanOrEqualMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .lessThanOrEqual
}

internal struct STKAssertLessThanMacro
    : DoubleExprMacro, STKMacro
{
    static let kind: AssertionKind = .lessThan
}



// MARK: - Error

internal struct STKAssertThrowsErrorMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .throwsError
}

internal struct STKAssertNoThrowMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .noThrow
}



// MARK: - Fail

internal struct STKFailMacro
    : NoExprMacro, STKMacro
{
    static let kind: AssertionKind = .fail
}



// MARK: - Predicate

internal struct STKAssertSatisfyAllMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyAll
}

internal struct STKAssertSatisfyAnyMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyAny
}

internal struct STKAssertSatisfyNoneMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyNone
}

internal struct STKAssertSatisfyAtLeastMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyAtLeast
}

internal struct STKAssertSatisfyAtMostMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyAtMost
}

internal struct STKAssertSatisfyRangeMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .satisfyRange
}

internal struct STKAssertExactlyMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .exactly
}

internal struct STKAssertExactlyOneMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .exactlyOne
}

internal struct STKAssertSortedMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .sorted
}

internal struct STKAssertUniqueMacro
    : SingleExprMacro, STKMacro
{
    static let kind: AssertionKind = .unique
}

internal struct STKAssertUniqueByKeyMacro
    : DoubleExprPredicateMacro, STKMacro
{
    static let kind: AssertionKind = .uniqueByKey
}
