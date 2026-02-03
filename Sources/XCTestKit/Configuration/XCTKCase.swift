//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore
import XCTest



/// The primary class for defining XCTestKit test cases.
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
