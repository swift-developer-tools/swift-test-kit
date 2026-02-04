//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Framework kinds.
public enum FrameworkKind: String, Equatable, Sendable
{
    /// XCTestKit.
    case xctk   = "XCTK"
    
    /// SwiftTestKit.
    case stk    = "STK"
}
