//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Synchronization



/// The global configuration.
public enum TestConfiguration
{
    private static let _global = Mutex<TestOptions>(.init())
    
    /// The global options.
    public static var global: TestOptions
    {
        get { _global.withLock { $0 } }
        set { _global.withLock { $0 = newValue } }
    }
}
