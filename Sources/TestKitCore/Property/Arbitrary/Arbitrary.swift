//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Arbitrary

/// A type that can generate random values.
///
/// Types used with property-based evaluators must conform to this protocol.
/// Built-in conformance is provided for many standard library types.
///
/// ## Conformance
///
/// An arbitrary type must define an ``arbitrary(using:)`` method to generate
/// random values.
///
/// An arbitrary type may optionally define a ``shrink()`` method to
/// generate candidate values that are smaller than the receiver value. The
/// default implementation returns an empty array to indicate that no shrinking
/// should occur.
///
/// An arbitrary type may also optionally define a ``mutate(using:)`` method
/// to produce a value that is a small perturbation of the receiver value.
/// The default implementation falls back to ``arbitrary(using:)``, generating
/// a value with no relation to the receiver. Override the default
/// implementation to improve convergence speed for targeted property-based
/// testing.
///
/// Below is an example of adding ``Arbitrary`` conformance to a custom type.
///
/// ```swift
/// struct User: Equatable
/// {
///     let name    : String
///     let age     : Int
/// }
///
/// extension User: Arbitrary
/// {
///     static func arbitrary(
///         using context: GenerationContext
///     ) -> User
///     {
///         return User(
///             name:   String.arbitrary(using: context),
///             age:    context.random(in: 0...120)
///         )
///     }
///
///     func shrink() -> [User]
///     {
///         var results: [User] = []
///
///         for name in name.shrink()
///         {
///             results.append(User(name: name, age: age))
///         }
///
///         for age in age.shrink()
///         {
///             results.append(User(name: name, age: age))
///         }
///
///         return results
///     }
///
///     func mutate(
///         using context: GenerationContext
///     ) -> User
///     {
///         switch context.random(in: 0..<2)
///         {
///             case 0:
///
///                 return User(
///                     name:   name.mutate(using: context),
///                     age:    age
///                 )
///
///             case 1:
///
///                 return User(
///                     name:   name,
///                     age:    age.mutate(using: context)
///                 )
///         }
///     }
/// }
/// ```
public protocol Arbitrary
{
    /// Generates a random value using the given generation context.
    ///
    /// Use ``GenerationContext/size`` to scale the generated value. Small
    /// sizes should produce small values (for example, zero, empty arrays,
    /// and short strings), while large sizes should produce large values.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: A randomly-generated value.
    static func arbitrary(
        using context: GenerationContext
    ) -> Self
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// The default implementation returns an empty array to indicate that
    /// no shrinking should occur. Override this method to provide shrink
    /// candidates.
    ///
    /// The shrinking process tries each candidate value and keeps the
    /// smallest value that still fails the property (the minimal
    /// counterexample).
    ///
    /// - Important: For best results, return candidate values in order from
    /// smallest to largest.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    func shrink() -> [Self]
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    ///
    /// The default implementation falls back to ``arbitrary(using:)``,
    /// generating a value with no relation to the receiver. Override this
    /// method to improve convergence speed by providing type-appropriate
    /// mutation.
    ///
    /// - Note: An effective mutation implementation changes one aspect of the
    /// value while holding the other aspects constant.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: A mutated value.
    func mutate(
        using context: GenerationContext
    ) -> Self
}



// MARK: - Extensions

extension Arbitrary
{
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
    
    
    
    /// Falls back to ``arbitrary(using:)``, generating a value with no
    /// relation to the receiver.
    ///
    /// This is the default implementation. Override this method to improve
    /// convergence speed by providing type-appropriate mutation.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: A mutated value.
    public func mutate(
        using context: GenerationContext
    ) -> Self
    {
        return Self.arbitrary(using: context)
    }
}
