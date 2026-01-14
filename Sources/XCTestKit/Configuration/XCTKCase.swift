//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Synchronization
import XCTest



// MARK: - XCTKConfig

/// The global configuration for XCTestKit.
///
/// Use this to customize the default behavior of all XCTestKit assertions.
public enum XCTKConfig
{
    private static let _global = Mutex<XCTKOptions>(.init())
    
    /// The global default options used by all XCTestKit assertions.
    ///
    /// Assertions use these options unless they are overridden at the class
    /// level (using ``XCTKCase/options``) or at the assertion level.
    public static var global: XCTKOptions
    {
        get { _global.withLock { $0 } }
        set { _global.withLock { $0 = newValue } }
    }
}



// MARK: - XCTKCase

/// The primary class for defining XCTestKit test cases.
open class XCTKCase: XCTestCase
{
    /// The class-level testing options.
    ///
    /// All assertions in the class use these options unless they are
    /// overridden at the assertion level.
    open var options: XCTKOptions
    {
        XCTKConfig.global
    }
}
