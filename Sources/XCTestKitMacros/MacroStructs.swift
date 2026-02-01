//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore



// MARK: - Boolean

internal struct AssertMacro: SingleExprMacro
{
    static let kind: AssertionKind = .assert
}

internal struct AssertTrueMacro: SingleExprMacro
{
    static let kind: AssertionKind = .true
}

internal struct AssertFalseMacro: SingleExprMacro
{
    static let kind: AssertionKind = .false
}



// MARK: - Nil and non-nil

internal struct AssertNilMacro: SingleExprMacro
{
    static let kind: AssertionKind = .nil
}

internal struct AssertNotNilMacro: SingleExprMacro
{
    static let kind: AssertionKind = .notNil
}

internal struct UnwrapMacro: SingleExprMacro
{
    static let kind: AssertionKind = .unwrap
}



// MARK: - Equality and inequality

internal struct AssertEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .equal
}

internal struct AssertNotEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notEqual
}

internal struct AssertIdenticalMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .identical
}

internal struct AssertNotIdenticalMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notIdentical
}

internal struct AssertEqualWithAccuracyMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .equalWithAccuracy
}

internal struct AssertNotEqualWithAccuracyMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notEqualWithAccuracy
}



// MARK: - Comparable

internal struct AssertGreaterThanMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .greaterThan
}

internal struct AssertGreaterThanOrEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .greaterThanOrEqual
}

internal struct AssertLessThanOrEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .lessThanOrEqual
}

internal struct AssertLessThanMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .lessThan
}



// MARK: - Error

internal struct AssertThrowsErrorMacro: SingleExprMacro
{
    static let kind: AssertionKind = .throwsError
}

internal struct AssertNoThrowMacro: SingleExprMacro
{
    static let kind: AssertionKind = .noThrow
}



// MARK: - Fail

internal struct FailMacro: NoExprMacro
{
    static let kind: AssertionKind = .fail
}



// MARK: - Predicate

internal struct AssertSatisfyAllMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyAll
}

internal struct AssertSatisfyAnyMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyAny
}

internal struct AssertSatisfyNoneMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyNone
}

internal struct AssertSatisfyAtLeastMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyAtLeast
}

internal struct AssertSatisfyAtMostMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyAtMost
}

internal struct AssertSatisfyRangeMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .satisfyRange
}

internal struct AssertExactlyMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .exactly
}

internal struct AssertExactlyOneMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .exactlyOne
}

internal struct AssertSortedMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .sorted
}

internal struct AssertUniqueMacro: SingleExprMacro
{
    static let kind: AssertionKind = .unique
}

internal struct AssertUniqueByKeyMacro: DoubleExprPredicateMacro
{
    static let kind: AssertionKind = .uniqueByKey
}
