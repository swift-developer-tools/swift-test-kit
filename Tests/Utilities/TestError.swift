//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// An error used to test assertions that accept a throwing expression.
struct TestError: Error
{
    /// Throws a ``TestError``.
    static func throwError<T>() throws -> T
    {
        throw TestError()
    }
}
