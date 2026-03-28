//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A sentinel error thrown to discard the current iteration.
///
/// ``PropertyRunner`` catches this error and treats it as a discard rather
/// than a failure.
internal struct DiscardError: Error { }
