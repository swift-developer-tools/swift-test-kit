//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// TODO: ComparatorContext?
/// Currently, the recursion depth is passed as a parameter to comparison
/// methods. It could have also been a private property, but the methods would
/// then have had to be mutating. If additional context is necessary, it would
/// be best to extract the mutable state to a `ComparatorContext` object.

/// The entry point for computing diffs between various data types.
internal struct Comparator
{
    /// The options for computing diffs.
    let options: XCTKDiffOptions
    
    
    
    /// Computes the diff between the given values.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - options: The diff options to use. The default value is a default-
    ///   initialized ``XCTKDiffOptions`` instance.
    /// - Returns: The diff node.
    static func computeDiff<T: Equatable>(
        expected    : T,
        actual      : T,
        options     : XCTKDiffOptions   = .init()
    ) -> DiffNode
    {
        let engine = Comparator(options: options)
        
        let kind: DiffNodeKind = engine.compareEquatable(
            expected:   expected,
            actual:     actual,
            depth:      0
        )
        
        return DiffNode(
            label:  .root,
            kind:   kind
        )
    }
    
    
    
    // MARK: - Core comparison
    
    /// Compares the given `Equatable` values.
    ///
    /// - Note: If the given values are not equal, this delegates to
    /// structural comparison.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareEquatable<T: Equatable>(
        expected    : T,
        actual      : T,
        depth       : Int
    ) -> DiffNodeKind
    {
        guard expected != actual
        else
        {
            return .same(expected: expected)
        }
        
        return compareStructurally(
            expected:   expected,
            actual:     actual,
            depth:      depth
        )
    }
    
    
    
    /// Compares the given type-erased values.
    ///
    /// This is used when recursing through `Mirror` children where the
    /// static type is lost.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - parentDepth: The recursion depth of the parent node.
    /// - Returns: The diff node kind.
    private func compareAny(
        expected    : Any,
        actual      : Any,
        parentDepth : Int
    ) -> DiffNodeKind
    {
        let depth: Int = parentDepth + 1
        
        guard !isAtDepthLimit(depth)
        else
        {
            guard String(describing: expected) == String(describing: actual)
            else
            {
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:       []
                )
            }
            
            return .same(expected: expected)
        }
        
        
        
        guard type(of: expected) == type(of: actual)
        else
        {
            /// When the types are different, structural comparison is not
            /// meaningful.
            return .different(
                expected:   expected,
                actual:     actual,
                tree:       []
            )
        }
        
        
        
        let areEqual: Bool = Self.areAnyValuesEqual(
            expected,
            actual
        )
        
        guard !areEqual
        else
        {
            return .same(expected: expected)
        }
        
        return compareStructurally(
            expected:   expected,
            actual:     actual,
            depth:      depth
        )
    }
    
    
    
    // MARK: - Structural comparison
    
    /// Compares the given values structurally, using `Mirror` reflection.
    ///
    /// This is used when two values are known to be unequal and are not
    /// leaf nodes (for example, they are not primitive values). This finds
    /// where the difference is located within the data structures.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareStructurally(
        expected    : Any,
        actual      : Any,
        depth       : Int
    ) -> DiffNodeKind
    {
        let expectedMirror  = Mirror(reflecting: expected)
        let actualMirror    = Mirror(reflecting: actual)
        
        /// The display style can be trusted since the type check in
        /// ``compareAny(expected:actual:depth:)`` used `type(of:)`, which
        /// ensures both values are of the same type.
        switch expectedMirror.displayStyle
        {
            case .collection:
                
                let expectedElements: [Any]
                    = expectedMirror.children.map { $0.value }
                
                let actualElements: [Any]
                    = actualMirror.children.map { $0.value }
                
                let children: [DiffNode] = compareArrays(
                    expected:   expectedElements,
                    actual:     actualElements,
                    depth:      depth
                )
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:       children
                )
                
                
                
            case .dictionary:
                
                guard
                    let expectedDict    = expected as? [AnyHashable : Any],
                    let actualDict      = actual as? [AnyHashable : Any]
                else
                {
                    break
                }

                let children: [DiffNode] = compareDictionaries(
                    expected:   expectedDict,
                    actual:     actualDict,
                    depth:      depth
                )
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:       children
                )
                
                
                
            case .optional:
                
                return compareOptionals(
                    expected:           expected,
                    actual:             actual,
                    expectedMirror:     expectedMirror,
                    actualMirror:       actualMirror,
                    depth:              depth
                )
                
                
                
            case .set:
                
                guard
                    let expectedSet     = expected as? Set<AnyHashable>,
                    let actualSet       = actual as? Set<AnyHashable>
                else
                {
                    break
                }
                
                let children: [DiffNode] = compareSets(
                    expected:   expectedSet,
                    actual:     actualSet,
                    depth:      depth
                )
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:       children
                )
                
                
                
            default:
                
                break
        }
        
        
        
        if
            let expectedString  = expected  as? String,
            let actualString    = actual    as? String
        {
            return StringComparator.compare(
                expected:   expectedString,
                actual:     actualString,
                options:    options
            )
        }
        
        
        
        return compareMirrorChildren(
            expected:           expected,
            actual:             actual,
            expectedMirror:     expectedMirror,
            actualMirror:       actualMirror,
            depth:              depth
        )
    }
    
    
    
    // MARK: - Collection comparison
    
    /// Compares the given arrays by element.
    /// - Parameters:
    ///   - expected: The expected array.
    ///   - actual: The actual array.
    ///   - depth: The recursion depth.
    /// - Returns: The diff nodes.
    private func compareArrays(
        expected    : [Any],
        actual      : [Any],
        depth       : Int
    ) -> [DiffNode]
    {
        guard
            let expectedHashable    : [AnyHashable]     = expected.hashable,
            let actualHashable      : [AnyHashable]     = actual.hashable
        else
        {
            return compareArraysByIndex(
                expected:   expected,
                actual:     actual,
                depth:      depth
            )
        }
        
        return compareArraysWithDifference(
            expected:           expected,
            actual:             actual,
            expectedHashable:   expectedHashable,
            actualHashable:     actualHashable,
            depth:              depth
        )
    }
    
    
    
    /// Compares the given arrays using `CollectionDifference`.
    /// - Parameters:
    ///   - expected: The expected array.
    ///   - actual: The actual array.
    ///   - expectedHashable: The hashable expected array.
    ///   - actualHashable: The hashable actual array.
    ///   - depth: The recursion depth.
    /// - Returns: The diff nodes.
    private func compareArraysWithDifference(
        expected            : [Any],
        actual              : [Any],
        expectedHashable    : [AnyHashable],
        actualHashable      : [AnyHashable],
        depth               : Int
    ) -> [DiffNode]
    {
        let diff: CollectionDifference
            = actualHashable.difference(from: expectedHashable)
        
        /// Collect removals and insertions by offset.
        /// `removals` maps expected offsets to the element.
        /// `insertions` maps actual offsets to the element.
        ///
        /// For example, consider the following comparisons:
        /// - `[A, B, C]` vs `[A, X, C]`
        ///     - Yields: `remove(1)` + `insert(1)`
        ///     - Meaning: Modification at index 1.
        ///
        /// - `[A, B, C]` vs `[A, B, C, D]`
        ///     - Yields: `insert(3)`
        ///     - Meaning: Unexpected element at index 3.
        ///
        /// - `[A, B, C]` vs `[A, C]`
        ///     - Yields: `remove(1)`
        ///     - Meaning: Missing element at index 1.
        var removals    : [Int : Any]   = [:]
        var insertions  : [Int : Any]   = [:]
        
        for change in diff
        {
            switch change
            {
                case let .remove(offset, _, _):
                    
                    removals[offset] = expected[offset]
                    
                case let .insert(offset, _, _):
                    
                    insertions[offset] = actual[offset]
            }
        }
        
        
        
        let allOffsets: [Int] = Set(removals.keys)
            .union(insertions.keys)
            .sorted()
        
        var nodes: [DiffNode] = []
        
        nodes.reserveCapacity(allOffsets.count)
        
        for offset in allOffsets
        {
            let kind: DiffNodeKind
            
            let removal     : Any?  = removals[offset]
            let insertion   : Any?  = insertions[offset]
            
            if
                let removal,
                let insertion
            {
                /// Modified element.
                kind = compareAny(
                    expected:       removal,
                    actual:         insertion,
                    parentDepth:    depth
                )
                
                if case .same = kind
                {
                    continue
                }
            }
            else if let removal
            {
                kind = .missingElement(expected: removal)
            }
            else if let insertion
            {
                kind = .unexpectedElement(actual: insertion)
            }
            else
            {
                continue;
            }
            
            
            
            let node = DiffNode(
                label:  .index(offset),
                kind:   kind
            )
            
            nodes.append(node)
        }
        
        
        
        return nodes
    }
    
    
    
    /// Compares given arrays by index.
    /// - Parameters:
    ///   - expected: The expected array.
    ///   - actual: The actual array.
    ///   - depth: The recursion depth.
    /// - Returns: The diff nodes.
    private func compareArraysByIndex(
        expected    : [Any],
        actual      : [Any],
        depth       : Int
    ) -> [DiffNode]
    {
        let maxCount: Int = max(
            expected.count,
            actual.count
        )
        
        var nodes: [DiffNode] = []
        
        nodes.reserveCapacity(maxCount)
        
        
        
        for i in 0..<maxCount
        {
            let kind: DiffNodeKind
            
            if
                i < expected.count,
                i < actual.count
            {
                /// Both arrays have this element.
                kind = compareAny(
                    expected:       expected[i],
                    actual:         actual[i],
                    parentDepth:    depth
                )
            }
            else if i < expected.count
            {
                /// Only the expected array has this element.
                kind = .missingElement(expected: expected[i])
            }
            else
            {
                /// Only the actual array has this element.
                kind = .unexpectedElement(actual: actual[i])
            }
            
            
            
            if case .same = kind
            {
                continue
            }
            
            let node = DiffNode(
                label:  .index(i),
                kind:   kind
            )
            
            nodes.append(node)
        }
        
        
        
        return nodes
    }
    
    
    
    /// Compares the given dictionaries by key.
    /// - Parameters:
    ///   - expected: The expected dictionary.
    ///   - actual: The actual dictionary.
    ///   - depth: The recursion depth.
    /// - Returns: The diff nodes.
    private func compareDictionaries<K: Hashable, V>(
        expected    : [K : V],
        actual      : [K : V],
        depth       : Int
    ) -> [DiffNode]
    {
        let expectedKeys    : Set<K>    = Set(expected.keys)
        let actualKeys      : Set<K>    = Set(actual.keys)
        let sharedKeys      : Set<K>    = expectedKeys.intersection(actualKeys)
        let missingKeys     : Set<K>    = expectedKeys.subtracting(actualKeys)
        let unexpectedKeys  : Set<K>    = actualKeys.subtracting(expectedKeys)
        
        var nodes: [DiffNode] = []
        
        nodes.reserveCapacity(
            sharedKeys.count
            + missingKeys.count
            + unexpectedKeys.count
        )
        
        
        for key in sharedKeys
        {
            guard
                let expectedValue   : V     = expected[key],
                let actualValue     : V     = actual[key]
            else
            {
                continue
            }
            
            let kind: DiffNodeKind = compareAny(
                expected:       expectedValue,
                actual:         actualValue,
                parentDepth:    depth
            )
            
            if case .same = kind
            {
                continue
            }
            
            let node = DiffNode(
                label:  .makeKey(key),
                kind:   kind
            )
            
            nodes.append(node)
        }
        
        
        
        for key in missingKeys
        {
            guard let expectedValue: V = expected[key]
            else
            {
                continue
            }
            
            let node = DiffNode(
                label:  .makeKey(key),
                kind:   .missingElement(expected: expectedValue)
            )
            
            nodes.append(node)
        }
        
        
        
        for key in unexpectedKeys
        {
            guard let actualValue: V = actual[key]
            else
            {
                continue
            }
            
            let node = DiffNode(
                label:  .makeKey(key),
                kind:   .unexpectedElement(actual: actualValue)
            )
            
            nodes.append(node)
        }
        
        
        
        return nodes
    }
    
    
    
    /// Compares the given sets, reporting the members unique to each set.
    /// - Parameters:
    ///   - expected: The expected set.
    ///   - actual: The actual set.
    ///   - depth: The recursion depth.
    /// - Returns: The diff nodes.
    private func compareSets<T: Hashable>(
        expected    : Set<T>,
        actual      : Set<T>,
        depth       : Int
    ) -> [DiffNode]
    {
        let missingElements     : Set<T>    = expected.subtracting(actual)
        let unexpectedElements  : Set<T>    = actual.subtracting(expected)
        
        var nodes: [DiffNode] = []
        
        nodes.reserveCapacity(
            missingElements.count
            + unexpectedElements.count
        )
        
        
        
        for element in missingElements
        {
            let node = DiffNode(
                label:  .member,
                kind:   .missingElement(expected: element)
            )
            
            nodes.append(node)
        }
        
        
        
        for element in unexpectedElements
        {
            let node = DiffNode(
                label:  .member,
                kind:   .unexpectedElement(actual: element)
            )
            
            nodes.append(node)
        }
        
        
        
        return nodes
    }
    
    
    
    // MARK: - Other comparison
    
    /// Compares the given `Mirror` children.
    ///
    /// This is used when two values are known to be unequal and are not
    /// leaf nodes (for example, they are not primitive values). This finds
    /// where the difference is located within the data structures.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - expectedMirror: The `Mirror` of the expected value.
    ///   - actualMirror: The `Mirror` of the actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareMirrorChildren(
        expected        : Any,
        actual          : Any,
        expectedMirror  : Mirror,
        actualMirror    : Mirror,
        depth           : Int
    ) -> DiffNodeKind
    {
        let expectedChildren: [Mirror.Child] = Array(expectedMirror.children)
        let actualChildren: [Mirror.Child] = Array(actualMirror.children)
        
        let maxCount: Int = max(
            expectedChildren.count,
            actualChildren.count
        )
        
        var nodes: [DiffNode] = []
        
        nodes.reserveCapacity(maxCount)

        
        
        for i in 0..<maxCount
        {
            let label   : DiffNodeLabel
            let kind    : DiffNodeKind
            
            if
                i < expectedChildren.count,
                i < actualChildren.count
            {
                /// Both values have this child.
                let expectedChild   : Mirror.Child  = expectedChildren[i]
                let actualChild     : Mirror.Child  = actualChildren[i]
                
                label = Self.makeMirrorLabel(
                    from:   expectedChild.label,
                    index:  i
                )
                
                kind = compareAny(
                    expected:       expectedChild.value,
                    actual:         actualChild.value,
                    parentDepth:    depth
                )
            }
            else if i < expectedChildren.count
            {
                /// Only the expected value has this child.
                let expectedChild: Mirror.Child = expectedChildren[i]
                
                label = Self.makeMirrorLabel(
                    from:   expectedChild.label,
                    index:  i
                )
                
                kind = .missingElement(expected: expectedChild.value)
            }
            else
            {
                /// Only the actual value has this child.
                let actualChild: Mirror.Child = actualChildren[i]
                
                label = Self.makeMirrorLabel(
                    from:   actualChild.label,
                    index:  i
                )
                
                kind = .unexpectedElement(actual: actualChild.value)
            }
            
            
            
            if case .same = kind
            {
                continue
            }
            
            let node = DiffNode(
                label:  label,
                kind:   kind
            )
            
            nodes.append(node)
        }
        
        
        
        return .different(
            expected:   expected,
            actual:     actual,
            tree:       nodes
        )
    }
    
    
    
    /// Compares the given optional values.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - expectedMirror: The `Mirror` of the expected value.
    ///   - actualMirror: The `Mirror` of the actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareOptionals(
        expected        : Any,
        actual          : Any,
        expectedMirror  : Mirror,
        actualMirror    : Mirror,
        depth           : Int
    ) -> DiffNodeKind
    {
        let expectedChild   : Mirror.Child?     = expectedMirror.children.first
        let actualChild     : Mirror.Child?     = actualMirror.children.first
        
        switch (expectedChild, actualChild)
        {
            case (.none, .none):
                
                return .same(expected: expected)
                
            case let (.some(exp), .some(act)):
                
                let childKind: DiffNodeKind = compareAny(
                    expected:       exp.value,
                    actual:         act.value,
                    parentDepth:    depth
                )
                
                if case .same = childKind
                {
                    return .same(expected: expected)
                }
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:
                    [
                        DiffNode(
                            label:  .property(name: "some"),
                            kind:   childKind
                        )
                    ]
                )
                
            case let (.some(exp), .none):
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:
                    [
                        DiffNode(
                            label:  .property(name: "some"),
                            kind:   .missingElement(expected: exp.value)
                        )
                    ]
                )
                
            case let (.none, .some(act)):
                
                return .different(
                    expected:   expected,
                    actual:     actual,
                    tree:
                    [
                        DiffNode(
                            label:  .property(name: "some"),
                            kind:   .unexpectedElement(actual: act.value)
                        )
                    ]
                )
        }
    }
    
    
    
    // MARK: - Support
    
    /// Checks whether the given recursion depth is at or beyond the maximum
    /// recursion limit.
    /// - Parameter depth: The current recursion depth.
    /// - Returns: Whether the given depth is at or beyond the maximum
    /// recursion limit.
    private func isAtDepthLimit(
        _ depth: Int
    ) -> Bool
    {
        guard let maxRecursionDepth: Int = options.maxRecursionDepth
        else
        {
            return false
        }
        
        return depth >= maxRecursionDepth
    }
    
    
    
    /// Checks whether the given type-erased values are equal.
    ///
    /// This attempts comparison using `AnyHashable`, then falls back to string
    /// comparison using `String(describing:)`. Based on the string description,
    /// it is possible that semantically-equivalent types will be
    /// considered unequal.
    ///
    /// This is acceptable since without `Equatable` or `Hashable` conformance,
    /// it is not possible to reliably know if two values are equal, and it is
    /// preferrable to flag potential differences rather than silently miss
    /// real differences.
    ///
    /// The practical risk is low since most types in tests are either value
    /// types or are `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side value.
    ///   - rhs: The right-hand side value.
    /// - Returns: Whether the given type-erased values are equal.
    private static func areAnyValuesEqual(
        _ lhs: Any,
        _ rhs: Any
    ) -> Bool
    {
        guard
            let lhsHashable = lhs as? AnyHashable,
            let rhsHashable = rhs as? AnyHashable
        else
        {
            return String(describing: lhs) == String(describing: rhs)
        }
        
        return lhsHashable == rhsHashable
    }
    
    
    
    /// Creates a diff node label from the given values.
    /// - Parameters:
    ///   - mirrorLabel: The `Mirror` label to use.
    ///   - index: The index to use.
    /// - Returns: A property label if `mirrorLabel` is not `nil`, and an
    /// index label otherwise.
    private static func makeMirrorLabel(
        from mirrorLabel: String?,
        index: Int
    ) -> DiffNodeLabel
    {
        guard let mirrorLabel
        else
        {
            return .index(index)
        }
        
        return .property(name: mirrorLabel)
    }
}
