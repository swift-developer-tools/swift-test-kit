//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import Synchronization



/// The global configuration for XCTestKit.
///
/// Use this to customize the default behavior of all XCTestKit assertions.
public enum XCTKConfig
{
    private static let _global = Mutex<TKOptions>(.init())
    
    /// The global default options used by all XCTestKit assertions.
    public static var global: TKOptions
    {
        get { _global.withLock { $0 } }
        set { _global.withLock { $0 = newValue } }
    }
}
