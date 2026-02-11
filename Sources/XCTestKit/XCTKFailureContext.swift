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



/// The XCTestKit assertion failure context.
internal let failureContext = FailureContext(
    framework: .xctk,
    emit:
    {
        message, file, line in
        
        if let interceptor = PropertyInterceptor.current
        {
            interceptor.record(
                message:    message,
                file:       file,
                line:       line
            )
        }
        else
        {
            XCTFail(
                message,
                file:   file,
                line:   line
            )
        }
    }
)
