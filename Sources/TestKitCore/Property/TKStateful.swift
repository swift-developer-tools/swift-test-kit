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
    model       : () -> C.Model,
    system      : () -> C.System,
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
    let result: PropertyCheckResult<[C]> = await StatefulRunner.run(
        command:    command,
        model:      model,
        system:     system,
        invariant:  invariant,
        options:    options
    )
    
    result.emit(
        functionName:   "\(context.framework.rawValue)Stateful",
        context:        context,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column
    )
}
