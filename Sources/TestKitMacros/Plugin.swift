//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitMacroCore
import SwiftCompilerPlugin
import SwiftSyntaxMacros



@main
struct TestKitMacroPlugin: CompilerPlugin
{
    let providingMacros: [any Macro.Type] =
    [
        XCTKAssertMacro.self,
        XCTKAssertTrueMacro.self,
        XCTKAssertFalseMacro.self,
        
        XCTKAssertNilMacro.self,
        XCTKAssertNotNilMacro.self,
        XCTKUnwrapMacro.self,
        
        XCTKAssertEqualMacro.self,
        XCTKAssertNotEqualMacro.self,
        XCTKAssertIdenticalMacro.self,
        XCTKAssertNotIdenticalMacro.self,
        XCTKAssertEqualWithAccuracyMacro.self,
        XCTKAssertNotEqualWithAccuracyMacro.self,
        
        XCTKAssertGreaterThanMacro.self,
        XCTKAssertGreaterThanOrEqualMacro.self,
        XCTKAssertLessThanOrEqualMacro.self,
        XCTKAssertLessThanMacro.self,
        
        XCTKAssertThrowsErrorMacro.self,
        XCTKAssertNoThrowMacro.self,
        
        XCTKFailMacro.self,
        
        XCTKAssertSatisfyAllMacro.self,
        XCTKAssertSatisfyAnyMacro.self,
        XCTKAssertSatisfyNoneMacro.self,
        XCTKAssertSatisfyAtLeastMacro.self,
        XCTKAssertSatisfyAtMostMacro.self,
        XCTKAssertSatisfyRangeMacro.self,
        XCTKAssertExactlyMacro.self,
        XCTKAssertExactlyOneMacro.self,
        XCTKAssertSortedMacro.self,
        XCTKAssertUniqueMacro.self,
        XCTKAssertUniqueByKeyMacro.self
    ]
}
