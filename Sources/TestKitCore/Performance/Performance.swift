//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

package func TKPerformance(
    runs            : () -> Int?,
    warmupRuns      : () -> Int?,
    wallTimeLimit   : () -> Duration?,
    memoryLimit     : () -> ByteCount?,
    _ message       : () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions,
    _ body          : () async throws -> Void,
    context         : FailureContext
) async
{
    let perfOptions: PerformanceOptions = options.performanceOptions
    
    let runs          : Int        = runs()          ?? perfOptions.runs
    let warmupRuns    : Int        = warmupRuns()    ?? perfOptions.warmupRuns
    let wallTimeLimit : Duration?  = wallTimeLimit() ?? perfOptions.wallTimeLimit
    let memoryLimit   : ByteCount? = memoryLimit()   ?? perfOptions.memoryLimit
    
    let result: PerformanceResult = await PerformanceRunner.run(
        runs:           runs,
        warmupRuns:     warmupRuns,
        wallTimeLimit:  wallTimeLimit,
        memoryLimit:    memoryLimit,
        body:           body
    )
    
    result.emit(
        runs:           runs,
        warmupRuns:     warmupRuns,
        functionName:   "\(context.framework.rawValue)Performance",
        options:        options,
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column
    )
}
