//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The kind of assertion.
package enum AssertionKind: String, Equatable, Sendable
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
    private var baseName: String
    {
        switch self
        {
            case .assert                : return "Assert"
            case .equal                 : return "AssertEqual"
            case .notEqual              : return "AssertNotEqual"
            case .equalWithAccuracy     : return "AssertEqual"
            case .notEqualWithAccuracy  : return "AssertNotEqual"
            case .identical             : return "AssertIdentical"
            case .notIdentical          : return "AssertNotIdentical"
            case .greaterThan           : return "AssertGreaterThan"
            case .greaterThanOrEqual    : return "AssertGreaterThanOrEqual"
            case .lessThan              : return "AssertLessThan"
            case .lessThanOrEqual       : return "AssertLessThanOrEqual"
            case .nil                   : return "AssertNil"
            case .notNil                : return "AssertNotNil"
            case .unwrap                : return "Unwrap"
            case .true                  : return "AssertTrue"
            case .false                 : return "AssertFalse"
            case .throwsError           : return "AssertThrowsError"
            case .noThrow               : return "AssertNoThrow"
            case .fail                  : return "Fail"
            case .satisfyAll            : return "AssertAllSatisfy"
            case .satisfyAny            : return "AssertAnySatisfy"
            case .satisfyNone           : return "AssertNoneSatisfy"
            case .satisfyAtLeast        : return "AssertSatisfy"
            case .satisfyAtMost         : return "AssertSatisfy"
            case .satisfyRange          : return "AssertSatisfy"
            case .exactly               : return "AssertExactly"
            case .exactlyOne            : return "AssertExactlyOne"
            case .sorted                : return "AssertSorted"
            case .unique                : return "AssertUnique"
            case .uniqueByKey           : return "AssertUnique"
        }
    }
    
    
    
    /// Gets the framework-specific assertion name.
    /// - Parameter framework: The framework kind.
    /// - Returns: The framework-specific assertion name.
    package func name(
        for framework: FrameworkKind
    ) -> String
    {
        return "\(framework.rawValue)\(baseName)"
    }
    
    
    
    /// Gets the framework-specific internal macro assertion name.
    /// - Parameter framework: The framework kind.
    /// - Returns: The framework-specific internal macro assertion name.
    package func macroInternalName(
        for framework: FrameworkKind
    ) -> String
    {
        return "_\(name(for: framework))Macro"
    }
    
    
    
    /// Gets the framework-specific display macro assertion name.
    /// - Parameter framework: The framework kind.
    /// - Returns: The framework-specific display macro assertion name.
    package func macroDisplayName(
        for framework: FrameworkKind
    ) -> String
    {
        return "#\(name(for: framework))"
    }
    
    
    
    /// The Swift source expression.
    ///
    /// This is used for code generation in macro expansions.
    package var sourceExpr: String
    {
        return "AssertionKind.\(rawValue)"
    }
}
