//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

package func TKStateful<C>(
    _ message   : () -> String,
    model       : () async -> C.Model,
    system      : () async -> C.System,
    command     : C.Type,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions,
    invariant   : ((C.Model, C.System) async throws -> Void)?,
    context     : FailureContext
) async where C : Stateful
{
    let result: StatefulResult = await StatefulRunner.run(
        command:    command,
        model:      model,
        system:     system,
        invariant:  invariant,
        options:    options
    )
    
    result.property.emit(
        functionName:   "\(context.framework.rawValue)Stateful",
        statistics:     result.statistics,
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options
    )
}
