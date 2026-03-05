//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A test error..
internal struct TestError: Error { }



/// An identifiable test error.
internal struct IdentifiableTestError: Error
{
    let id: Int
}
