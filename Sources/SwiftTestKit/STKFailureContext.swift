//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import Testing



/// The SwiftTestKit assertion failure context.
internal let failureContext = FailureContext(
    framework: .stk,
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
            let sourceLocation = SourceLocation(
                fileID:     fileID.description,
                filePath:   file.description,
                line:       Int(clamping: line),
                column:     Int(clamping: column)
            )
            
            // TODO: Swift 6.3 uncomment severity.
            Issue.record(
                Comment(rawValue: message),
                //severity:           .error,
                sourceLocation:     sourceLocation
            )
        }
    }
)
