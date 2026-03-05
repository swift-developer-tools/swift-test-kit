//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The result of a stateful property check.
internal struct StatefulResult<C> where C : Stateful
{
    /// The stateful property check result.
    let property    : PropertyResult<[C]>
    
    /// The command statistics report.
    let statistics  : String?
}
