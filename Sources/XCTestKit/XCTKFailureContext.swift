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
        message, fileID, file, line, column in
        
        if let interceptor = PropertyInterceptor.current
        {
            interceptor.recordFailure(
                message:    message,
                fileID:     fileID,
                file:       file,
                line:       line,
                column:     column
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
