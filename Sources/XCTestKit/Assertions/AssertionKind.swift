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

/// The kind of an assertion.
internal enum AssertionKind
{
    case assert
    case equal
    case equalWithAccuracy
    case identical
    case notIdentical
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case notEqual
    case notEqualWithAccuracy
    case `nil`
    case notNil
    case unwrap
    case `true`
    case `false`
    case fail
    case throwsError
    case noThrow
    
    
    
    /// The assertion name.
    var name: String
    {
        switch self
        {
            case .assert                : return "XCTKAssert"
            case .equal                 : return "XCTKAssertEqual"
            case .equalWithAccuracy     : return "XCTKAssertEqual"
            case .identical             : return "XCTKAssertIdentical"
            case .notIdentical          : return "XCTKAssertNotIdentical"
            case .greaterThan           : return "XCTKAssertGreaterThan"
            case .greaterThanOrEqual    : return "XCTKAssertGreaterThanOrEqual"
            case .lessThan              : return "XCTKAssertLessThan"
            case .lessThanOrEqual       : return "XCTKAssertLessThanOrEqual"
            case .notEqual              : return "XCTKAssertNotEqual"
            case .notEqualWithAccuracy  : return "XCTKAssertNotEqual"
            case .`nil`                 : return "XCTKAssertNil"
            case .notNil                : return "XCTKAssertNotNil"
            case .unwrap                : return "XCTKUnwrap"
            case .`true`                : return "XCTKAssertTrue"
            case .`false`               : return "XCTKAssertFalse"
            case .throwsError           : return "XCTKAssertThrowsError"
            case .noThrow               : return "XCTKAssertNoThrow"
            case .fail                  : return "XCTKAssertion"
        }
    }
}
