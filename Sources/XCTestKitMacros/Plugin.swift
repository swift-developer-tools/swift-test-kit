//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

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
        
        FailMacro.self
    ]
}
