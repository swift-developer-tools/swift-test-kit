//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - PredicateFailure

/// Information about a failed predicate.
public struct PredicateFailure: Equatable
{
    /// The number of elements in the collection.
    public let collectionCount  : Int
    
    /// The kind of predicate failure.
    public let kind             : PredicateFailureKind
    
    /// Whether the collection has meaningful indices.
    public let isOrdered        : Bool
    
    
    
    /// Initializes a ``PredicateFailure`` instance from the given values.
    public init(
        collectionCount : Int,
        kind            : PredicateFailureKind,
        isOrdered       : Bool
    )
    {
        self.collectionCount    = collectionCount
        self.kind               = kind
        self.isOrdered          = isOrdered
    }
}



// MARK: - PredicateFailure

/// The kind of predicate failure.
public enum PredicateFailureKind: Equatable
{
    /// Elements that failed the predicate.
    ///
    /// This is used for `satisfyAll` assertions.
    ///
    /// - Parameter elements: The elements for which the predicate returned
    /// `false` or threw an error.
    case elementsFailed(
        _ elements: [ElementResult]
    )
    
    /// Elements that unexpectedly matched the predicate.
    ///
    /// This is used for `satisfyNone` assertions.
    ///
    /// - Parameter elements: The elements for which the predicate unexpectedly
    /// returned `true`.
    case elementsMatched(
        _ elements: [ElementResult]
    )
    
    /// The count of matching elements that did not meet the expectation.
    ///
    /// This is used for `satisfyAny`, `satisfyAtLeast`, `satisfyAtMost`,
    /// `satisfyRange`, `exactly`, and `exactlyOne` assertions.
    ///
    /// - Parameter mismatch: Information about the count mismatch failure.
    case countMismatch(
        _ mismatch: CountMismatch
    )
    
    /// The collection is not sorted according to the predicate.
    ///
    /// This is used for `sorted` assertions.
    ///
    /// - Parameter violation: Information about the ordering violation.
    case orderingViolation(
        _ violation: OrderingViolation
    )
    
    /// Duplicate elements were found in the collection.
    ///
    /// This is used for `unique` assertions.
    ///
    /// - Parameter groups: Information about the groups of duplicate elements.
    case duplicates(
        _ groups: [DuplicateGroup]
    )
    
    /// Duplicate element keys were found in the collection.
    ///
    /// This is used for `uniqueByKey` assertions.
    ///
    /// - Parameter groups: Information about the groups of elements with
    /// duplicate keys.
    case duplicateKeys(
        _ groups: [DuplicateKeyGroup]
    )
}



// MARK: - ElementResult

/// Information about an element evaluated by a predicate.
public struct ElementResult: Equatable
{
    /// The index of the element in the collection.
    public let index    : Int
    
    /// The element value.
    public let value    : DiffValue
    
    /// The error description, if the predicate threw an error.
    public let error    : String?
    
    
    
    /// Initializes an ``ElementResult`` instance from the given values.
    public init(
        index   : Int,
        value   : DiffValue,
        error   : String?
    )
    {
        self.index  = index
        self.value  = value
        self.error  = error
    }
}



// MARK: - PredicateIterationResult

/// Information about the iteration of a predicate over a collectiion.
public struct PredicateIterationResult
{
    /// The elements that matched the predicate.
    public let matchedElements  : [ElementResult]
    
    /// The elements that failed the predicate.
    public let failedElements   : [ElementResult]
    
    /// The elements for which the predicate threw an error.
    public let errorElements    : [ElementResult]
    
    
    
    /// Initializes a ``PredicateIterationResult`` instance from the given
    /// values.
    public init(
        matchedElements : [ElementResult],
        failedElements  : [ElementResult],
        errorElements   : [ElementResult]
    )
    {
        self.matchedElements    = matchedElements
        self.failedElements     = failedElements
        self.errorElements      = errorElements
    }
    
    
    
    /// The indices of the elements that matched the predicate.
    public var matchedIndices: [Int]
    {
        return matchedElements.map { $0.index }
    }
    
    
    
    /// The elements that matched the predicate or threw an error.
    public var allFailed: [ElementResult]
    {
        return failedElements + errorElements
    }
    
    
    
    /// The number of elements that failed the predicate or threw an error.
    public var allFailedCount: Int
    {
        return allFailed.count
    }
    
    
    
    /// The number of matched elements.
    public var matchedCount: Int
    {
        return matchedElements.count
    }
    
    
    
    /// The number of failed elements.
    public var failedCount: Int
    {
        return failedElements.count
    }
    
    
    
    /// The number of elements for which the predicate threw an error.
    public var errorCount: Int
    {
        return errorElements.count
    }
}



// MARK: - CountExpectationKind

/// The expected count for a predicate.
public enum CountExpectationKind: Equatable, Sendable
{
    /// Expected at least one element to match.
    case any
    
    /// Expected at least the specified number of elements to match.
    /// - Parameter count: The minimum number of matching elements.
    case atLeast(
        _ count: Int
    )
    
    /// Expected up to the specified number of elements to match.
    /// - Parameter count: The maximum number of matching elements.
    case atMost(
        _ count: Int
    )
    
    /// Expected the number of matching elements to be within the specified
    /// range.
    /// - Parameter range: The acceptable range of matching elements.
    case range(
        _ range: ClosedRange<Int>
    )
    
    /// Expected exactly the specified number of elements to match.
    /// - Parameter count: The exact number of matching elements.
    case exactly(
        _ count: Int
    )
}



// MARK: - CountMismatch

/// Information about a count mismatch failure.
public struct CountMismatch: Equatable
{
    /// The expected count.
    public let expected         : CountExpectationKind
    
    /// The indices of elements that matched the predicate.
    public let matchedIndices   : [Int]
    
    /// Elements where the predicate threw an error.
    public let errorElements    : [ElementResult]
    
    
    
    /// Initializes a ``CountMismatch`` instance from the given values.
    public init(
        expected        : CountExpectationKind,
        matchedIndices  : [Int],
        errorElements   : [ElementResult]
    )
    {
        self.expected           = expected
        self.matchedIndices     = matchedIndices
        self.errorElements      = errorElements
    }
}



// MARK: - OrderingViolation

/// Information about an ordering violation in a sorted assertion.
public struct OrderingViolation: Equatable
{
    /// The index of the first element in the violating pair.
    public let index    : Int
    
    /// The first element in the violating pair.
    public let first    : DiffValue
    
    /// The second element in the violating pair.
    public let second   : DiffValue
    
    /// The error description, if the predicate threw an error.
    public let error    : String?
    
    
    
    /// Initializes an ``OrderingViolation`` instance from the given values.
    public init(
        index   : Int,
        first   : DiffValue,
        second  : DiffValue,
        error   : String?
    )
    {
        self.index      = index
        self.first      = first
        self.second     = second
        self.error      = error
    }
}



// MARK: - DuplicateGroup

/// Information about a group of duplicate elements.
public struct DuplicateGroup: Equatable
{
    /// The duplicate value.
    public let value    : DiffValue
    
    /// The indices where the duplicate value appears.
    public var indices  : [Int]
    
    
    
    /// Initializes a ``DuplicateGroup`` instance from the given values.
    public init(
        value   : DiffValue,
        indices : [Int]
    )
    {
        self.value      = value
        self.indices    = indices
    }
}



// MARK: - DuplicateKeyGroup

/// Information about a group of elements with duplicate keys.
public struct DuplicateKeyGroup: Equatable
{
    /// The duplicate key.
    public let key      : DiffValue
    
    /// The elements with the duplicate key, along with their indices.
    public let elements : [IndexedElement]
    
    
    
    /// Initializes a ``DuplicateKeyGroup`` instance from the given values.
    public init(
        key         : DiffValue,
        elements    : [IndexedElement]
    )
    {
        self.key        = key
        self.elements   = elements
    }
}



// MARK: - IndexedElement

/// An element with its index in a collection.
public struct IndexedElement: Equatable
{
    /// The index of the element in a collection.
    public let index    : Int
    
    /// The element value.
    public let value    : DiffValue
    
    
    
    /// Initializes an ``IndexedElement`` instance from the given values.
    public init(
        index   : Int,
        value   : DiffValue
    )
    {
        self.index  = index
        self.value  = value
    }
}
