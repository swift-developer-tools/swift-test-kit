//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Produces a synchronous overload of an asynchronous function.
///
/// - Important: This is a purely syntactic transformation. The generated peer
/// function declaration must be valid in a synchronous context.
@attached(peer, names: overloaded)
package macro Reasync() = #externalMacro(
    module:     "ReasyncMacro",
    type:       "ReasyncPeerMacro"
)



/// Produces synchronous overloads of any asynchronous functions declared in
/// the type to which the macro is attached.
///
/// - Important: This is a purely syntactic transformation. The generated peer
/// function declarations must be valid in a synchronous context.
@attached(member, names: arbitrary)
package macro ReasyncMembers() = #externalMacro(
    module:     "ReasyncMacro",
    type:       "ReasyncMemberMacro"
)
