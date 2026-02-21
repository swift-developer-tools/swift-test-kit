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
/// ## Conforming Custom Types
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
/// }
/// ```
///
/// Properties that may have natural bounds (like `age`) can use a fixed range.
/// Properties without a natural  bound (like `name`) should delegate to
/// the type's ``arbitrary(using:)`` method, which automatically scales with
/// ``GenerationContext/size``.
///
/// The ``shrink()-7wd72`` method returns candidates by shrinking one property
/// at a time, while holding the other properties constant.
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
    /// The default implementation returns an empty array (no shrinking).
    /// Override this method to provide shrink candidates.
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
}
