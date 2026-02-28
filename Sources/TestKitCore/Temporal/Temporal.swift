//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

package func TKAlways(
    timeout     : () -> Duration?,
    interval    : () -> Duration?,
    _ message   : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    _ body      : () async throws -> Void,
    context     : FailureContext
) async
{
    let kind: TemporalRunner.Kind = .always
    
    let timeout     : Duration  = timeout()  ?? options.temporalOptions.timeout
    let interval    : Duration  = interval() ?? options.temporalOptions.interval
    
    let result: TemporalResult = await TemporalRunner.run(
        kind:       kind,
        timeout:    timeout,
        interval:   interval,
        body:       body
    )
    
    result.emit(
        kind:           kind,
        timeout:        timeout,
        functionName:   "\(context.framework.rawValue)\(kind.description)",
        options:        options,
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column
    )
}



package func TKEventually(
    timeout     : () -> Duration?,
    interval    : () -> Duration?,
    _ message   : () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    _ body      : () async throws -> Void,
    context     : FailureContext
) async
{
    let kind: TemporalRunner.Kind = .eventually
    
    let timeout     : Duration  = timeout()  ?? options.temporalOptions.timeout
    let interval    : Duration  = interval() ?? options.temporalOptions.interval
    
    let result: TemporalResult = await TemporalRunner.run(
        kind:       kind,
        timeout:    timeout,
        interval:   interval,
        body:       body
    )
    
    result.emit(
        kind:           kind,
        timeout:        timeout,
        functionName:   "\(context.framework.rawValue)\(kind.description)",
        options:        options,
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column
    )
}
