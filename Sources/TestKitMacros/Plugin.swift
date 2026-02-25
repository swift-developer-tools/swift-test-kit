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
        // MARK: - Property-based testing
        
        ArbitraryMacro.self,
        StatefulMacro.self,
        WeightMacro.self,
        
        
        
        // MARK: - STK assertions
        
        STKAssertMacro.self,
        STKAssertTrueMacro.self,
        STKAssertFalseMacro.self,
        
        STKAssertNilMacro.self,
        STKAssertNotNilMacro.self,
        STKUnwrapMacro.self,
        
        STKAssertEqualMacro.self,
        STKAssertNotEqualMacro.self,
        STKAssertIdenticalMacro.self,
        STKAssertNotIdenticalMacro.self,
        STKAssertEqualWithAccuracyMacro.self,
        STKAssertNotEqualWithAccuracyMacro.self,
        
        STKAssertGreaterThanMacro.self,
        STKAssertGreaterThanOrEqualMacro.self,
        STKAssertLessThanOrEqualMacro.self,
        STKAssertLessThanMacro.self,
        
        STKAssertThrowsErrorMacro.self,
        STKAssertNoThrowMacro.self,
        
        STKFailMacro.self,
        
        STKAssertSatisfyAllMacro.self,
        STKAssertSatisfyAnyMacro.self,
        STKAssertSatisfyNoneMacro.self,
        STKAssertSatisfyAtLeastMacro.self,
        STKAssertSatisfyAtMostMacro.self,
        STKAssertSatisfyRangeMacro.self,
        STKAssertExactlyMacro.self,
        STKAssertExactlyOneMacro.self,
        STKAssertSortedMacro.self,
        STKAssertUniqueMacro.self,
        STKAssertUniqueByKeyMacro.self,
        
        
        
        // MARK: - XCTK assertions
        
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
