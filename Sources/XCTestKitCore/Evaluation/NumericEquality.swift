//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
// Parts of this file are adapted from the Swift.org open source project.
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors.
// Licensed under the Apache License, Version 2.0, with Runtime Library
// Exception.
//
// See https://swift.org/LICENSE.txt for license information.
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors.
//
//===----------------------------------------------------------------------===//

/// Checks whether the given numeric expressions are equal, within the given
/// accuracy.
/// - Parameters:
///   - expr1: The first numeric expression.
///   - expr2: The second numeric expression.
///   - accuracy: The accuracy.
/// - Returns: Whether the given numeric expressions are equal, within the
/// given accuracy.
public func areEqual<T>(
    _ expr1     : T,
    _ expr2     : T,
    accuracy    : T
) -> Bool where T : Numeric
{
    if expr1 == expr2
    {
        return true
    }
    
    /// `NaN` values are handled implicitly, since the `<=` operator returns
    /// `false` when comparing any value to `NaN`.
    let difference: T = expr1.magnitude > expr2.magnitude
        ? expr1 - expr2
        : expr2 - expr1
    
    return difference.magnitude <= accuracy.magnitude
}
