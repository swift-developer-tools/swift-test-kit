//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Produces a synchronous overload of an asynchronous function by removing all
/// `async` specifiers and all `await` expressions.
///
/// This rewrites expressions, declarations, and statements as follows:
///
/// - Function signatures: `func run() async -> T` → `func run() -> T`
/// - Closure parameters: `(T) async throws -> Void` → `(T) throws -> Void`
/// - `await` expressions: `await expr` → `expr`
/// - `async let` declarations: `async let` → `let`
/// - `for await` statements: `for await x in y` → `for x in y`
///
/// - Important: This is a purely syntactic transformation. The generated peer
/// function declaration must be valid in a synchronous context.
@attached(peer, names: overloaded)
package macro Reasync() = #externalMacro(
    module:     "ReasyncMacro",
    type:       "ReasyncMacro"
)
