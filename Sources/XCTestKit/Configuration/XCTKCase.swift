//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



/// The primary class for defining XCTestKit test cases.
///
/// - Note: See [`XCTestCase`](https://developer.apple.com/documentation/xctest/xctestcase)
/// documentation for the complete API reference.
open class XCTKCase: XCTestCase
{
    /// The class-level testing options.
    ///
    /// To define reusable options for a test class, override this property
    /// and pass it to any assertion that should not use global options.
    open var options: TKOptions
    {
        XCTKConfig.global
    }
}
