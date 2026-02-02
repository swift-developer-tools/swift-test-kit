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

import XCTestKitCore



// MARK: - Evaluate expressions

/// Evaluates the given expression.
///
/// - Important: This fails the assertion if the given expression throws an
/// error when called. This does not apply to ``AssertionKind/throwsErrow``.
/// In this single case, `.failure` indicates that the expresion threw an
/// error as expected, and the assertion passed. For all other cases,
/// `.failure`indicates that the expression unexpectedly threw an error, and
/// the assertion failed.
///
/// - Parameters:
///   - expr: The expression to evaluate.
///   - assertion: The assertion kind.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing.
///   - errorHandler: An optional handler for errors thrown by `expr`.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given expression.
internal func evaluateExpr<T>(
    _ expr          : () throws -> T,
    assertion       : AssertionKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?,
    errorHandler    : (any Error) -> Void   = { _ in }
) -> Result<T, Error>
{
    do
    {
        return .success(try expr())
    }
    catch
    {
        if assertion == .throwsError
        {
            errorHandler(error)
        }
        else
        {
            failAssertion(
                kind:       assertion,
                reason:     "threw error \(quote(error))",
                message:    message,
                file:       file,
                line:       line,
                options:    options
            )
        }
        
        return .failure(error)
    }
}



// MARK: - Evaluate collections

/// Evaluates the given collection.
///
/// - Important: This fails the assertion if the given collection expression
/// throws an error when called.
///
/// - Parameters:
///   - collection: The collection to evaluate.
///   - assertion: The assertion kind.
///   - message: The description of a failure.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - options: The options for testing.
/// - Returns: A `Result` containing the value or error produced by evaluating
/// the given collection expression.
internal func evaluateCollection<C>(
    _ collection    : () throws -> C,
    assertion       : AssertionKind,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
) -> Result<C, Error> where C : Collection
{
    do
    {
        return .success(try collection())
    }
    catch
    {
        failAssertion(
            kind:       assertion,
            reason:     "threw error \(quote(error))",
            message:    message,
            file:       file,
            line:       line,
            options:    options
        )
        
        return .failure(error)
    }
}



/// Iterates the given predicate over the given collection.
/// - Parameters:
///   - predicate: The predicate to call with each element of the collection.
///   - collection: The collection over which to iterate.
/// - Returns: Information about the iteration of the given predicate over the
/// given collection.
internal func iteratePredicate<C>(
    _       predicate   : (C.Element) throws -> Bool,
    over    collection  : C
) -> PredicateIterationResult where C : Collection
{
    var matchedElements : [ElementResult]   = []
    var failedElements  : [ElementResult]   = []
    var errorElements   : [ElementResult]   = []
    
    for (index, element) in collection.enumerated()
    {
        do
        {
            let success: Bool = try predicate(element)
            
            let result = ElementResult(
                index:  index,
                value:  DiffValue(element),
                error:  nil
            )
            
            if success
            {
                matchedElements.append(result)
            }
            else
            {
                failedElements.append(result)
            }
        }
        catch
        {
            let result = ElementResult(
                index:  index,
                value:  DiffValue(element),
                error:  error.localizedDescription
            )
            
            errorElements.append(result)
        }
    }
    
    return PredicateIterationResult(
        matchedElements:    matchedElements,
        failedElements:     failedElements,
        errorElements:      errorElements
    )
}



// MARK: - Fail function assertions

@_documentation(visibility: internal)
/// Reports a function assertion failure.
///
/// - Note: This is public since it is used in boolean macro expansions.
///
/// - Parameters:
///   - kindName: The assertion kind name.
///   - reason: The optional failure reason.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
public func failAssertion(
    kindName    : String,
    reason      : String?,
    message     : String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kindName) failed"
    
    if let reason
    {
        text += ": \(reason)"
    }
    
    if
        let message,
        !message.isEmpty
    {
        text += " - \(message)"
    }
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a function assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - reason: The optional failure reason.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind    : AssertionKind,
    reason  : String?,
    message : () -> String?,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
)
{
    var text: String = "\(kind.name) failed"
    
    if let reason
    {
        text += ": \(reason)"
    }
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a function assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - diff: The computed diff.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind    : AssertionKind,
    diff    : DiffNode,
    message : () -> String?,
    file    : StaticString,
    line    : UInt,
    options : XCTKOptions?
)
{
    let diffOutput: String = Formatter.formatDiff(
        diff,
        options: options?.formatOptions
    )
    
    var fullOutput: String = "\(kind.name) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        fullOutput += " - \(msg)"
    }
    
    fullOutput += "\n\n\(diffOutput)"
    
    XCTKFail(
        fullOutput,
        file:   file,
        line:   line
    )
}



// MARK: - Fail macro assertions

/// Reports a macro assertion failure for boolean assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - exprText: The expression source text.
///   - evaluated: The evaluated boolean expressions.
///   - notEvaluated: The number of unevaluated boolean expressions.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind            : AssertionKind,
    exprText        : String,
    evaluated       : [XCTKBooleanExpr],
    notEvaluated    : Int,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
)
{
    let output: String = Formatter.formatBooleanExpr(
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        expectedValue:  kind == .false ? false : true,
        options:        options?.formatOptions
    )
    
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\n\(output)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for single-expression assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - exprText: The expression source text.
///   - actual: The string representation of the actual value, or `nil` to omit.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind        : AssertionKind,
    exprText    : String,
    actual      : String?,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpression: \(exprText)"
    
    if let actual
    {
        text += kind == .noThrow
            ? "\nThrew:      \(actual)"
            : "\nActual:     \(actual)"
    }
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for double-expression assertions.
/// - Parameters:
///   - kind: The assertion kind.
///   - expr1Text: The source text of the first expression.
///   - expr2Text: The source text of the second expression.
///   - reason: The failure reason describing the comparison result.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind        : AssertionKind,
    expr1Text   : String,
    expr2Text   : String,
    reason      : String,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    var text: String = "\(kind.macroDisplayName) failed: \(reason)"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpression 1: \(expr1Text)"
    text += "\nExpression 2: \(expr2Text)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro assertion failure for double-expression equality assertions
/// with diff output.
/// - Parameters:
///   - kind: The assertion kind.
///   - expectedText: The source text of the expected expression.
///   - actualText: The source text of the actual expression.
///   - diff: The computed diff.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failAssertion(
    kind            : AssertionKind,
    expectedText    : String,
    actualText      : String,
    diff            : DiffNode,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
)
{
    let diffOutput: String = Formatter.formatDiff(
        diff,
        options: options?.formatOptions
    )
    
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\nExpected: \(expectedText)"
    text += "\nActual:   \(actualText)"
    text += "\n\n\(diffOutput)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



// MARK: - Fail predicate assertions

/// Reports a predicate assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - captureKind: The kind of captured assertion expression.
///   - failure: Information about the failed predicate.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
internal func failPredicateAssertion(
    kind        : AssertionKind,
    captureKind : ExprCaptureKind,
    failure     : PredicateFailure,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    switch captureKind
    {
        case .none:
            
            failPredicateAssertion(
                kind:       kind,
                failure:    failure,
                message:    message,
                file:       file,
                line:       line,
                options:    options
            )
            
        case let .single(collectionText):
            
            failPredicateAssertion(
                kind:               kind,
                collectionText:     collectionText,
                predicateText:      nil,
                failure:            failure,
                message:            message,
                file:               file,
                line:               line,
                options:            options
            )
            
        case let .double(collectionText, predicateText):
            
            failPredicateAssertion(
                kind:               kind,
                collectionText:     collectionText,
                predicateText:      predicateText,
                failure:            failure,
                message:            message,
                file:               file,
                line:               line,
                options:            options
            )
    }
}



/// Reports a function predicate assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - failure: Information about the failed predicate.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
private func failPredicateAssertion(
    kind        : AssertionKind,
    failure     : PredicateFailure,
    message     : () -> String?,
    file        : StaticString,
    line        : UInt,
    options     : XCTKOptions?
)
{
    let output: String = Formatter.formatPredicate(
        failure,
        options: options?.formatOptions
    )
    
    var text: String = "\(kind.name) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\n\(output)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



/// Reports a macro predicate assertion failure.
/// - Parameters:
///   - kind: The assertion kind.
///   - failure: Information about the failed predicate.
///   - message: The description of a failure.
///   - file: The file where the failure occurs.
///   - line: The line where the failure occurs.
///   - options: The options for testing.
private func failPredicateAssertion(
    kind            : AssertionKind,
    collectionText  : String?,
    predicateText   : String?,
    failure         : PredicateFailure,
    message         : () -> String?,
    file            : StaticString,
    line            : UInt,
    options         : XCTKOptions?
)
{
    let output: String = Formatter.formatPredicate(
        failure,
        collectionText:     collectionText,
        predicateText:      predicateText,
        options:            options?.formatOptions
    )
    
    var text: String = "\(kind.macroDisplayName) failed"
    
    if
        let msg: String = message(),
        !msg.isEmpty
    {
        text += " - \(msg)"
    }
    
    text += "\n\n\(output)"
    
    XCTKFail(
        text,
        file:   file,
        line:   line
    )
}



// MARK: - XCTKUnwrapError

/// The error thrown by ``XCTKUnwrap(_:_:file:line:options:)-func`` or
/// ``XCTKUnwrap(_:_:file:line:options:)-macro``when the unwrapped value
/// is `nil`.
public struct XCTKUnwrapError: Error, CustomStringConvertible
{
    /// The error description.
    public var description: String
    {
        return "XCTKUnwrap unwrapped a nil value"
    }
}



// MARK: - XCTKBooleanExpr

@_documentation(visibility: internal)
/// A boolean expression evaluated during macro expression decomposition.
public struct XCTKBooleanExpr: Equatable, Sendable
{
    /// The source text of the expression.
    public let text     : String
    
    /// The evaluated boolean value.
    public let value    : Bool
}



// MARK: - Numeric equality

internal func areEqual<T>(
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



// MARK: - Predicate assertions

/// Information about a failed predicate.
internal struct PredicateFailure: Equatable
{
    /// The number of elements in the collection.
    let collectionCount : Int
    
    /// The kind of predicate failure.
    let kind            : PredicateFailureKind
    
    /// Whether the collection has meaningful indices.
    let isOrdered       : Bool
}



/// The kind of predicate failure.
internal enum PredicateFailureKind: Equatable
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



/// Information about an element evaluated by a predicate.
internal struct ElementResult: Equatable
{
    /// The index of the element in the collection.
    let index   : Int
    
    /// The element value.
    let value   : DiffValue
    
    /// The error description, if the predicate threw an error.
    let error   : String?
}



/// Information about the iteration of a predicate over a collectiion.
internal struct PredicateIterationResult
{
    /// The elements that matched the predicate.
    let matchedElements : [ElementResult]
    
    /// The elements that failed the predicate.
    let failedElements  : [ElementResult]
    
    /// The elements for which the predicate threw an error.
    let errorElements   : [ElementResult]
    
    
    
    /// The indices of the elements that matched the predicate.
    var matchedIndices: [Int]
    {
        return matchedElements.map { $0.index }
    }
    
    
    
    /// The elements that matched the predicate or threw an error.
    var allFailed: [ElementResult]
    {
        return failedElements + errorElements
    }
    
    
    
    /// The number of elements that failed the predicate or threw an error.
    var allFailedCount: Int
    {
        return allFailed.count
    }
    
    
    
    /// The number of matched elements.
    var matchedCount: Int
    {
        return matchedElements.count
    }
    
    
    
    /// The number of failed elements.
    var failedCount: Int
    {
        return failedElements.count
    }
    
    
    
    /// The number of elements for which the predicate threw an error.
    var errorCount: Int
    {
        return errorElements.count
    }
}



/// The expected count for a predicate.
internal enum CountExpectationKind: Equatable, Sendable
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



/// Information about a count mismatch failure.
internal struct CountMismatch: Equatable
{
    /// The expected count.
    let expected        : CountExpectationKind
    
    /// The indices of elements that matched the predicate.
    let matchedIndices  : [Int]
    
    /// Elements where the predicate threw an error.
    let errorElements   : [ElementResult]
}



/// Information about an ordering violation in a sorted assertion.
internal struct OrderingViolation: Equatable
{
    /// The index of the first element in the violating pair.
    let index   : Int
    
    /// The first element in the violating pair.
    let first   : DiffValue
    
    /// The second element in the violating pair.
    let second  : DiffValue
    
    /// The error description, if the predicate threw an error.
    let error   : String?
}



/// Information about a group of duplicate elements.
internal struct DuplicateGroup: Equatable
{
    /// The duplicate value.
    let value   : DiffValue
    
    /// The indices where the duplicate value appears.
    var indices : [Int]
}



/// Information about a group of elements with duplicate keys.
internal struct DuplicateKeyGroup: Equatable
{
    /// The duplicate key.
    let key         : DiffValue
    
    /// The elements with the duplicate key, along with their indices.
    let elements    : [IndexedElement]
}



/// An element with its index in a collection.
internal struct IndexedElement: Equatable
{
    /// The index of the element in a collection.
    let index   : Int
    
    /// The element value.
    let value   : DiffValue
}
