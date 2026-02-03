//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Converts the given value to its string representation, wrapped in double
/// quotes.
/// - Parameter value: The value to convert.
/// - Returns: The string representation of the given value, wrapped in double
/// quotes.
public func quote<T>(
    _ value: T
) -> String
{
    return "\"\(String(describing: value))\""
}
