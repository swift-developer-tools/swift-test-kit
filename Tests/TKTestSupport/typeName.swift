//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Gets the string description of the dynamic type of the given value.
/// - Parameter value: The value to convert.
/// - Returns: The string description of the dynamic type of the given value.
public func typeName<T>(
    of value: borrowing T
) -> String where T : ~Copyable, T : ~Escapable
{
    return String(describing: type(of: value))
}
