//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
// Parts of this file are adapted from the Swift.org open source project.
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors.
// Licensed under the Apache License, Version 2.0, with Runtime Library
// Exception.
//
// See https://swift.org/LICENSE.txt for license information.
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors.
//
//===----------------------------------------------------------------------===//

/// The kind of assertion.
public enum AssertionKind: String, Equatable, Sendable
{
    case assert
    case equal
    case notEqual
    case equalWithAccuracy
    case notEqualWithAccuracy
    case identical
    case notIdentical
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case `nil`
    case notNil
    case unwrap
    case `true`
    case `false`
    case fail
    case throwsError
    case noThrow
    case satisfyAll
    case satisfyAny
    case satisfyNone
    case satisfyAtLeast
    case satisfyAtMost
    case satisfyRange
    case exactly
    case exactlyOne
    case sorted
    case unique
    case uniqueByKey
    
    
    
    /// The assertion name.
    public var name: String
    {
        switch self
        {
            case .assert                : return "XCTKAssert"
            case .equal                 : return "XCTKAssertEqual"
            case .notEqual              : return "XCTKAssertNotEqual"
            case .equalWithAccuracy     : return "XCTKAssertEqual"
            case .notEqualWithAccuracy  : return "XCTKAssertNotEqual"
            case .identical             : return "XCTKAssertIdentical"
            case .notIdentical          : return "XCTKAssertNotIdentical"
            case .greaterThan           : return "XCTKAssertGreaterThan"
            case .greaterThanOrEqual    : return "XCTKAssertGreaterThanOrEqual"
            case .lessThan              : return "XCTKAssertLessThan"
            case .lessThanOrEqual       : return "XCTKAssertLessThanOrEqual"
            case .nil                   : return "XCTKAssertNil"
            case .notNil                : return "XCTKAssertNotNil"
            case .unwrap                : return "XCTKUnwrap"
            case .true                  : return "XCTKAssertTrue"
            case .false                 : return "XCTKAssertFalse"
            case .throwsError           : return "XCTKAssertThrowsError"
            case .noThrow               : return "XCTKAssertNoThrow"
            case .fail                  : return "XCTKFail"
            case .satisfyAll            : return "XCTKAssertAllSatisfy"
            case .satisfyAny            : return "XCTKAssertAnySatisfy"
            case .satisfyNone           : return "XCTKAssertNoneSatisfy"
            case .satisfyAtLeast        : return "XCTKAssertSatisfy"
            case .satisfyAtMost         : return "XCTKAssertSatisfy"
            case .satisfyRange          : return "XCTKAssertSatisfy"
            case .exactly               : return "XCTKAssertExactly"
            case .exactlyOne            : return "XCTKAssertExactlyOne"
            case .sorted                : return "XCTKAssertSorted"
            case .unique                : return "XCTKAssertUnique"
            case .uniqueByKey           : return "XCTKAssertUnique"
        }
    }
    
    
    
    /// The internal macro name.
    public var macroInternalName: String
    {
        return "_\(name)Macro"
    }
    
    
    
    /// The macro display name.
    public var macroDisplayName: String
    {
        return "#\(name)"
    }
    
    
    
    /// The Swift source expression.
    ///
    /// This is used for code generation in macro expansions.
    public var sourceExpr: String
    {
        return "AssertionKind.\(rawValue)"
    }
}
