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
    cpuTimeLimit    : () -> Duration?,
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
    let opts: PerformanceOptions = options.performanceOptions
    
    let runs            : Int           = runs()          ?? opts.runs
    let warmupRuns      : Int           = warmupRuns()    ?? opts.warmupRuns
    let wallTimeLimit   : Duration?     = wallTimeLimit() ?? opts.wallTimeLimit
    let cpuTimeLimit    : Duration?     = cpuTimeLimit()  ?? opts.cpuTimeLimit
    let memoryLimit     : ByteCount?    = memoryLimit()   ?? opts.memoryLimit
    
    let result: PerformanceResult = await PerformanceRunner.run(
        runs:           runs,
        warmupRuns:     warmupRuns,
        wallTimeLimit:  wallTimeLimit,
        cpuTimeLimit:   cpuTimeLimit,
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
