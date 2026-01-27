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

public struct AssertMacro: SingleExprMacro
{
    static let kind: AssertionKind = .assert
}

public struct AssertTrueMacro: SingleExprMacro
{
    static let kind: AssertionKind = .`true`
}

public struct AssertFalseMacro: SingleExprMacro
{
    static let kind: AssertionKind = .`false`
}



// MARK: - Nil and non-nil

public struct AssertNilMacro: SingleExprMacro
{
    static let kind: AssertionKind = .`nil`
}

public struct AssertNotNilMacro: SingleExprMacro
{
    static let kind: AssertionKind = .notNil
}

public struct UnwrapMacro: SingleExprMacro
{
    static let kind: AssertionKind = .unwrap
}



// MARK: - Equality and inequality

public struct AssertEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .equal
}

public struct AssertNotEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notEqual
}

public struct AssertIdenticalMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .identical
}

public struct AssertNotIdenticalMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notIdentical
}

public struct AssertEqualWithAccuracyMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .equalWithAccuracy
}

public struct AssertNotEqualWithAccuracyMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .notEqualWithAccuracy
}



// MARK: - Comparable

public struct AssertGreaterThanMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .greaterThan
}

public struct AssertGreaterThanOrEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .greaterThanOrEqual
}

public struct AssertLessThanOrEqualMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .lessThanOrEqual
}

public struct AssertLessThanMacro: DoubleExprMacro
{
    static let kind: AssertionKind = .lessThan
}



// MARK: - Error

public struct AssertThrowsErrorMacro: SingleExprMacro
{
    static let kind: AssertionKind = .throwsError
}

public struct AssertNoThrowMacro: SingleExprMacro
{
    static let kind: AssertionKind = .noThrow
}



// MARK: - Fail

public struct FailMacro: NoExprMacro
{
    static let kind: AssertionKind = .fail
}
