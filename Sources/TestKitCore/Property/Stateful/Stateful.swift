//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Stateful

/// A type that defines commands for stateful property-based testing.
///
/// Types used with stateful property-based evaluators must conform to this
/// protocol.
///
/// Stateful testing validates a system under test by comparing its behavior
/// against a simplified model. Tests generate random sequences of commands,
/// execute them against both the model and system, and verify that the system
/// behaves consistently with the model.
///
/// ## Conformance
///
/// A stateful type must define:
///
/// 1. The ``System`` under test and a simplified ``Model`` of its behavior.
/// 2. An ``arbitrary(using:model:)`` method to generate random commands.
/// 3. A ``run(model:system:)`` method to execute the command on both the
/// model and system.
/// 4. An ``advance(model:)`` method to advance the model without side effects.
///
/// A stateful type may optionally define:
///
/// 1. A ``precondition(model:)`` method to determine whether a command is
/// valid for the model state. The default implementation always returns `true`.
/// 2. A ``postcondition(model:system:)`` method to determine whether the
/// system state is consistent with the model state after executing a command.
/// The default implementation always returns `true`.
/// 3. A ``shrink()`` method to enable model-independent argument shrinking.
/// The default implementation returns an empty array to indicate that no
/// shrinking should occur.
/// 4. A ``shrink(model:)`` method to enable model-dependent argument shrinking.
/// The default implementation delegates to the model-independent method.
///
/// Below is an example of adding ``Stateful`` conformance to a custom type.
///
/// ```swift
/// enum CounterCommand: Stateful, CaseIterable
/// {
///     case increment
///     case decrement
///     case reset
///
///     typealias System    = Counter
///     typealias Model     = Int
///
///     static func arbitrary(
///         using context   : GenerationContext,
///         model           : Model
///     ) -> CounterCommand
///     {
///         return context.randomElement(of: allCases)!
///     }
///
///     func run(
///         model   : inout Model,
///         system  : inout System
///     ) async throws
///     {
///         switch self
///         {
///             case .increment:
///
///                 model += 1
///                 system.increment()
///
///             case .decrement:
///
///                 model -= 1
///                 system.decrement()
///
///             case .reset:
///
///                 model = 0
///                 system.reset()
///         }
///
///         // Use SwiftTestKit or XCTestKit assertions as needed.
///     }
///
///     func advance(
///         model: inout Model
///     )
///     {
///         switch self
///         {
///             case .increment : model += 1
///             case .decrement : model -= 1
///             case .reset     : model = 0
///         }
///     }
/// }
/// ```
///
/// ## Shrinking
///
/// When a failing command sequence is found, it is automatically shrunk in
/// two phases:
///
/// 1. Removal shrinking: Chunks of commands are removed from the sequence.
/// This step is always performed.
/// 2. Argument shrinking: Individual commands are replaced by smaller
/// alternatives. This step is performed only if the type overrides ``shrink()``
/// or ``shrink(model:)``, and returns a non-empty array of candidates.
///
/// ## Assertions
///
/// ``run(model:system:)`` is the only ``Stateful`` method in which
/// SwiftTestKit or XCTestKit assertions are intercepted. Assertions used in
/// other methods bypass shrinking and produce immediate test failures.
public protocol Stateful: Sendable
{
    /// The system under test.
    associatedtype System
    
    /// The model used to test the system.
    associatedtype Model: Equatable
    
    
    
    /// Generates a random command using the given model state.
    /// - Parameters:
    ///   - context: The generation context.
    ///   - model: The model state.
    /// - Returns: A randomly-generated command.
    static func arbitrary(
        using context   : GenerationContext,
        model           : Model
    ) -> Self
    
    
    
    /// Whether this command is valid under the given model state.
    ///
    /// The default implementation returns `true`. Override this method to
    /// provide specific preconditions.
    ///
    /// This is used during sequence generation to filter invalid commands
    /// and during shrinking to ensure that candidate sequences remain valid
    /// after commands are removed.
    ///
    /// - Parameter model: The model state.
    /// - Returns: Whether this command is valid under the given model state.
    func precondition(
        model: Model
    ) -> Bool
    
    
    
    /// Whether the given system state is consistent with the given model
    /// after executing this command.
    ///
    /// The default implementation returns `true`. Override this method to
    /// provide specific postconditions.
    ///
    /// This is used after each command is executed and during shrinking.
    /// Returning `false` records a failure identical to an assertion failure.
    ///
    /// - Parameters:
    ///   - model: The model state.
    ///   - system: The system state.
    /// - Returns: Whether the given system state is consistent with the given
    /// model after executing this command.
    func postcondition(
        model   : Model,
        system  : System
    ) -> Bool
    
    
    
    /// Executes the command on both the given model and system.
    ///
    /// - Important: This must advance the model identically to
    /// ``advance(model:)``.
    ///
    /// - Parameters:
    ///   - model: The model state.
    ///   - system: The system state.
    func run(
        model   : inout Model,
        system  : inout System
    ) async throws
    
    
    
    /// Advances the model to the next state without executing against the
    /// system.
    ///
    /// - Important: This must advance the model identically to
    /// ``run(model:system:)``.
    ///
    /// - Parameter model: The model state.
    func advance(
        model: inout Model
    )
    
    
    
    /// Generates model-independent candidate commands that are smaller than
    /// the receiver.
    ///
    /// The default implementation returns an empty array (no shrinking).
    /// Override this method to provide shrink candidates for a conforming
    /// type.
    ///
    /// - Returns: An array of smaller candidate commands, or an empty array
    /// to indicate that no shrinking should occur.
    func shrink() -> [Self]
    
    
    
    /// Generates model-dependent candidate commands that are smaller than
    /// the receiver.
    ///
    /// Use this to generate shrink candidates that are valid for the given
    /// model state, reducing wasted shrink attempts in which candidates are
    /// filtered out by preconditions.
    ///
    /// The default implementation delegates to ``shrink()``.
    ///
    /// - Parameter model: The model state.
    /// - Returns: An array of smaller candidate commands, or an empty array
    /// to indicate that no shrinking should occur.
    func shrink(
        model: Model
    ) -> [Self]
}



// MARK: - Extensions

extension Stateful
{
    /// Whether this command is valid under the given model state.
    ///
    /// This is the default implementation. Override this method to provide
    /// specific preconditions.
    ///
    /// - Parameter model: The model state.
    /// - Returns: Always `true`.
    public func precondition(
        model: Model
    ) -> Bool
    {
        return true
    }
    
    
    
    /// Whether the given system state is consistent with the given model state
    /// after executing this command.
    ///
    /// This is the default implementation. Override this method to provide
    /// specific postconditions.
    ///
    /// - Parameters:
    ///   - model: The model state.
    ///   - system: The system state.
    /// - Returns: Always `true`.
    public func postcondition(
        model   : Model,
        system  : System
    ) -> Bool
    {
        return true
    }
    
    
    
    /// Returns an empty array to indicate that no shrinking should occur.
    ///
    /// This is the default implementation. Override this method to provide
    /// shrink candidates.
    ///
    /// - Returns: Always an empty array.
    public func shrink() -> [Self]
    {
        return []
    }
    
    
    
    /// Delegates to ``shrink()``.
    ///
    /// This is the default implementation. Override this method to provide
    /// model-dependent shrink candidates.
    ///
    /// - Parameter model: The model state.
    /// - Returns: The shrink candidates.
    public func shrink(
        model: Model
    ) -> [Self]
    {
        return shrink()
    }
}
