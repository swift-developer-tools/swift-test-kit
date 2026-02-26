//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Controls the case selection of a ``Stateful`` enum during command
/// generation.
///
/// Apply the `@Weight` macro to enum cases inside an enum attributed with the
/// ``Stateful()`` macro to control how often each case is selected during
/// command generation. Any case without an explicit weight defaults to a
/// weight of `1`.
///
/// ```swift
/// @Stateful
/// enum CacheCommand
/// {
///     typealias System    = Cache<String, Int>
///     typealias Model     = Int
///
///     // insert is selected 5 times more often than delete or clear.
///     // lookup is selected 3 times more often than delete or clear.
///     @Weight(5) case insert(key: String, value: Int)
///     @Weight(3) case lookup(key: String)
///     @Weight(1) case delete(key: String)
///     case clear
/// }
/// ```
///
/// - Note: This macro has no effect unless used within an enum attributed
/// with the ``Stateful()`` macro.
///
/// - Parameter weight: The relative weight of the enum case. This must be
/// a positive integer literal.
@attached(peer)
public macro Weight(
    _ weight: Int
) = #externalMacro(
    module:     "TestKitMacros",
    type:       "WeightMacro"
)
