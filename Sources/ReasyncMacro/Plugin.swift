//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import ReasyncMacroCore
import SwiftCompilerPlugin
import SwiftSyntaxMacros



@main
struct ReasyncMacroPlugin: CompilerPlugin
{
    let providingMacros: [any Macro.Type] =
    [
        ReasyncMacro.self
    ]
}
