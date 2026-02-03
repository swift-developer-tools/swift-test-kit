//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitMacros
import SwiftCompilerPlugin
import SwiftSyntaxMacros



@main
struct XCTestKitMacroPlugin: CompilerPlugin
{
    let providingMacros: [any Macro.Type] =
    [
        AssertMacro.self,
        AssertTrueMacro.self,
        AssertFalseMacro.self,
        
        AssertNilMacro.self,
        AssertNotNilMacro.self,
        UnwrapMacro.self,
        
        AssertEqualMacro.self,
        AssertNotEqualMacro.self,
        AssertIdenticalMacro.self,
        AssertNotIdenticalMacro.self,
        AssertEqualWithAccuracyMacro.self,
        AssertNotEqualWithAccuracyMacro.self,
        
        AssertGreaterThanMacro.self,
        AssertGreaterThanOrEqualMacro.self,
        AssertLessThanOrEqualMacro.self,
        AssertLessThanMacro.self,
        
        AssertThrowsErrorMacro.self,
        AssertNoThrowMacro.self,
        
        FailMacro.self,
        
        AssertSatisfyAllMacro.self,
        AssertSatisfyAnyMacro.self,
        AssertSatisfyNoneMacro.self,
        AssertSatisfyAtLeastMacro.self,
        AssertSatisfyAtMostMacro.self,
        AssertSatisfyRangeMacro.self,
        AssertExactlyMacro.self,
        AssertExactlyOneMacro.self,
        AssertSortedMacro.self,
        AssertUniqueMacro.self,
        AssertUniqueByKeyMacro.self
    ]
}
