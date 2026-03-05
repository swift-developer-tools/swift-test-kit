//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@Reasync
package func TKAtomic(
    _ message   : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    _ body      : () async throws -> Void,
    context     : FailureContext
) async
{
    let result: AtomicResult = await AtomicRunner.run(body: body)
    
    result.emit(
        functionName:   "\(context.framework.rawValue)Atomic",
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column
    )
}
