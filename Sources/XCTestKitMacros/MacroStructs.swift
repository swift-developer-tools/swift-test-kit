//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import TestKitMacros



// MARK: - XCTKMacro

internal protocol XCTKMacro: AssertionMacro { }

internal extension XCTKMacro
{
    static var framework: FrameworkKind { .xctk }
}



// MARK: - Boolean

internal struct AssertMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .assert
}

internal struct AssertTrueMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .true
}

internal struct AssertFalseMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .false
}



// MARK: - Nil and non-nil

internal struct AssertNilMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .nil
}

internal struct AssertNotNilMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notNil
}

internal struct UnwrapMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .unwrap
}



// MARK: - Equality and inequality

internal struct AssertEqualMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .equal
}

internal struct AssertNotEqualMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notEqual
}

internal struct AssertIdenticalMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .identical
}

internal struct AssertNotIdenticalMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notIdentical
}

internal struct AssertEqualWithAccuracyMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .equalWithAccuracy
}

internal struct AssertNotEqualWithAccuracyMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .notEqualWithAccuracy
}



// MARK: - Comparable

internal struct AssertGreaterThanMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .greaterThan
}

internal struct AssertGreaterThanOrEqualMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .greaterThanOrEqual
}

internal struct AssertLessThanOrEqualMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .lessThanOrEqual
}

internal struct AssertLessThanMacro: DoubleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .lessThan
}



// MARK: - Error

internal struct AssertThrowsErrorMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .throwsError
}

internal struct AssertNoThrowMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .noThrow
}



// MARK: - Fail

internal struct FailMacro: NoExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .fail
}



// MARK: - Predicate

internal struct AssertSatisfyAllMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAll
}

internal struct AssertSatisfyAnyMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAny
}

internal struct AssertSatisfyNoneMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyNone
}

internal struct AssertSatisfyAtLeastMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAtLeast
}

internal struct AssertSatisfyAtMostMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyAtMost
}

internal struct AssertSatisfyRangeMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .satisfyRange
}

internal struct AssertExactlyMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .exactly
}

internal struct AssertExactlyOneMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .exactlyOne
}

internal struct AssertSortedMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .sorted
}

internal struct AssertUniqueMacro: SingleExprMacro, XCTKMacro
{
    static let kind: AssertionKind = .unique
}

internal struct AssertUniqueByKeyMacro: DoubleExprPredicateMacro, XCTKMacro
{
    static let kind: AssertionKind = .uniqueByKey
}
