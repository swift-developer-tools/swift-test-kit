//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The entry point for computing diffs between various data types.
internal struct Comparator
{
    /// The context for tracking state across recursive comparison calls.
    private let context: ComparatorContext
    
    
    
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
        let context     = ComparatorContext(options: options)
        let comparator  = Comparator(context: context)
        
        
        
        if let expectedID: ObjectIdentifier
            = getClassObjectIdentifier(of: expected)
        {
            context.visitedExpected.insert(expectedID)
        }
        
        if let actualID: ObjectIdentifier
            = getClassObjectIdentifier(of: actual)
        {
            context.visitedActual.insert(actualID)
        }
        
        
        
        
        let kind: DiffNodeKind = comparator.compareEquatable(
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
        
        
        
        /// Check for cycles in reference types.
        let expectedID: ObjectIdentifier?
            = Self.getClassObjectIdentifier(of: expected)
        
        let actualID: ObjectIdentifier?
            = Self.getClassObjectIdentifier(of: actual)
        
        
        
        let expectedCycle: Bool = expectedID.map
        {
            context.visitedExpected.contains($0)
        } ?? false
        
        let actualCycle: Bool = actualID.map
        {
            context.visitedActual.contains($0)
        } ?? false
        
        if
            expectedCycle
            || actualCycle
        {
            let location: CycleLocation
            
            if
                expectedCycle,
                actualCycle
            {
                location = .both
            }
            else if expectedCycle
            {
                location = .expected
            }
            else
            {
                location = .actual
            }
            
            return .cycle(
                expected:   expected,
                actual:     actual,
                location:   location
            )
        }
        
        
        
        if let expectedID
        {
            context.visitedExpected.insert(expectedID)
        }
        
        if let actualID
        {
            context.visitedActual.insert(actualID)
        }
        
        /// Remove from visited sets when returning. This ensures that
        /// shared references are not incorrectly reported as cycles.
        ///
        /// A true cycle is when the same object appears again on the current
        /// traversal path (for example, ancestor -> descendant -> ancestor).
        ///
        /// A shared reference is when thet same object appears in different
        /// branches.
        defer
        {
            if let expectedID
            {
                context.visitedExpected.remove(expectedID)
            }
            
            if let actualID
            {
                context.visitedActual.remove(actualID)
            }
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
        
        
        
        /// Determine whether this value might contain reference types. If so,
        /// skip the equality comparison and proceed to structural comparison.
        ///
        /// ``areAnyValuesEqual(_:_:)`` falls back to `String(describing:)`
        /// comparison when the values are not hashable. For types that contain
        /// reference types (for example, `Optional<Node>`), the string
        /// comparison can report equality even when the wrapped references
        /// are difference instances that are being tracked for cycle
        /// detection. Structural comparison correctly handles these cases.
        ///
        /// For plain value types (for example, structs and enums), the
        /// equality comparison is reliable.
        let expectedMirror = Mirror(reflecting: expected)
        
        let mightContainTrackedReferences: Bool =
            Self.getClassObjectIdentifier(of: expected) != nil
            || expectedMirror.displayStyle == .collection
            || expectedMirror.displayStyle == .dictionary
            || expectedMirror.displayStyle == .optional
            || expectedMirror.displayStyle == .set
        
        if !mightContainTrackedReferences
        {
            let areEqual: Bool = Self.areAnyValuesEqual(
                expected,
                actual
            )
            
            guard !areEqual
            else
            {
                return .same(expected: expected)
            }
        }
        
        return compareStructurally(
            expected:           expected,
            actual:             actual,
            expectedMirror:     expectedMirror,
            depth:              depth
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
    ///   - expMirror: The `Mirror` of the expected value.
    ///   - actMirror: The `Mirror` of the actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareStructurally(
        expected                    : Any,
        actual                      : Any,
        expectedMirror expMirror    : Mirror? = nil,
        actualMirror   actMirror    : Mirror? = nil,
        depth                       : Int
    ) -> DiffNodeKind
    {
        let expectedMirror  = expMirror ?? Mirror(reflecting: expected)
        let actualMirror    = actMirror ?? Mirror(reflecting: actual)
        
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
                    let expectedDict    = expected  as? [AnyHashable : Any],
                    let actualDict      = actual    as? [AnyHashable : Any]
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
                
                
                
            case .enum:
                
                return compareEnums(
                    expected:           expected,
                    actual:             actual,
                    expectedMirror:     expectedMirror,
                    actualMirror:       actualMirror,
                    depth:              depth
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
                
                
                
            case
                .class,
                .foreignReference,
                .struct,
                .tuple,
                .none,
                .some:
                
                break
        }
        
        
        
        if
            let expectedString  = expected  as? String,
            let actualString    = actual    as? String
        {
            return StringComparator.compare(
                expected:   expectedString,
                actual:     actualString,
                options:    context.options
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
    /// - Returns: The diff tree.
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
    /// - Returns: The diff tree.
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
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(allOffsets.count)
        
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
                continue
            }
            
            
            
            let node = DiffNode(
                label:  .index(offset),
                kind:   kind
            )
            
            tree.append(node)
        }
        
        
        
        return tree
    }
    
    
    
    /// Compares given arrays by index.
    /// - Parameters:
    ///   - expected: The expected array.
    ///   - actual: The actual array.
    ///   - depth: The recursion depth.
    /// - Returns: The diff tree.
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
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(maxCount)
        
        
        
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
            
            tree.append(node)
        }
        
        
        
        return tree
    }
    
    
    
    /// Compares the given dictionaries by key.
    /// - Parameters:
    ///   - expected: The expected dictionary.
    ///   - actual: The actual dictionary.
    ///   - depth: The recursion depth.
    /// - Returns: The diff tree.
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
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(
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
            
            tree.append(node)
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
            
            tree.append(node)
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
            
            tree.append(node)
        }
        
        
        
        return Self.sortTree(tree)
    }
    
    
    
    /// Compares the given sets, reporting the members unique to each set.
    /// - Parameters:
    ///   - expected: The expected set.
    ///   - actual: The actual set.
    ///   - depth: The recursion depth.
    /// - Returns: The diff tree.
    private func compareSets<T: Hashable>(
        expected    : Set<T>,
        actual      : Set<T>,
        depth       : Int
    ) -> [DiffNode]
    {
        let missingElements     : Set<T>    = expected.subtracting(actual)
        let unexpectedElements  : Set<T>    = actual.subtracting(expected)
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(
            missingElements.count
            + unexpectedElements.count
        )
        
        
        
        for element in missingElements
        {
            let node = DiffNode(
                label:  .member,
                kind:   .missingElement(expected: element)
            )
            
            tree.append(node)
        }
        
        
        
        for element in unexpectedElements
        {
            let node = DiffNode(
                label:  .member,
                kind:   .unexpectedElement(actual: element)
            )
            
            tree.append(node)
        }
        
        
        
        return Self.sortSetTree(tree)
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
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(maxCount)

        
        
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
            
            tree.append(node)
        }
        
        
        
        return .different(
            expected:   expected,
            actual:     actual,
            tree:       tree
        )
    }
    
    
    
    /// Compares the given enum values.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - expectedMirror: The `Mirror` of the expected value.
    ///   - actualMirror: The `Mirror` of the actual value.
    ///   - depth: The recursion depth.
    /// - Returns: The diff node kind.
    private func compareEnums(
        expected        : Any,
        actual          : Any,
        expectedMirror  : Mirror,
        actualMirror    : Mirror,
        depth           : Int
    ) -> DiffNodeKind
    {
        let expectedCaseName: String
            = Self.getEnumCaseName(from: expected)
        
        let actualCaseName: String
            = Self.getEnumCaseName(from: actual)
        
        guard expectedCaseName == actualCaseName
        else
        {
            return .different(
                expected:   expected,
                actual:     actual,
                tree:       []
            )
        }
        
        
        
        /// Bypass the case-name wrapper that `Mirror` produces.
        /// `typealias Mirror.Child = (label: String?, value: Any)`
        guard
            let expectedAssoc   : Any   = expectedMirror.children.first?.value,
            let actualAssoc     : Any   = actualMirror.children.first?.value
        else
        {
            return .same(expected: expected)
        }
        
        
        
        let expectedAssocMirror     = Mirror(reflecting: expectedAssoc)
        let actualAssocMirror       = Mirror(reflecting: actualAssoc)
        
        /// Check if this is a single primitive associated value.
        /// `Mirror` represents multi-value associates values as tuples with
        /// children, but single primitive associated values have no children.
        if expectedAssocMirror.children.isEmpty
        {
            let innerKind: DiffNodeKind = compareAny(
                expected:       expectedAssoc,
                actual:         actualAssoc,
                parentDepth:    depth
            )
            
            if case .same = innerKind
            {
                return .same(expected: expected)
            }
            
            return .different(
                expected:   expected,
                actual:     actual,
                tree:
                [
                    DiffNode(
                        label:  .index(0),
                        kind:   innerKind
                    )
                ]
            )
        }
        
        
        
        let assocKind: DiffNodeKind = compareMirrorChildren(
            expected:           expectedAssoc,
            actual:             actualAssoc,
            expectedMirror:     expectedAssocMirror,
            actualMirror:       actualAssocMirror,
            depth:              depth
        )
        
        if case .same = assocKind
        {
            return .same(expected: expected)
        }
        
        guard case let .different(_, _, assocTree) = assocKind
        else
        {
            return .different(
                expected:   expected,
                actual:     actual,
                tree:       []
            )
        }
        
        return .different(
            expected:   expected,
            actual:     actual,
            tree:       assocTree
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
        guard let maxRecursionDepth: Int = context.options.maxRecursionDepth
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
    
    
    
    /// Gets the enum case name from the given enum value.
    ///
    /// For example, `SomeEnum.someCase(value: 0)` returns `someCase`.
    ///
    /// - Parameter value: The enum value from which to get the case name.
    /// - Returns: The enum case name.
    private static func getEnumCaseName(
        from value: Any
    ) -> String
    {
        let description = String(describing: value)
        
        guard let parenIndex: String.Index = description.firstIndex(of: "(")
        else
        {
            /// No associated values.
            return description
        }
        
        return String(description[..<parenIndex])
    }
    
    
    
    /// Gets the object identifier of the given value, if it is a reference
    /// type.
    /// - Parameter value: The value to check.
    /// - Returns: The object identifier of the given value, or `nil` if it is
    /// not a reference type.
    private static func getClassObjectIdentifier(
        of value: Any
    ) -> ObjectIdentifier?
    {
        guard type(of: value) is AnyClass
        else
        {
            return nil
        }
        
        return ObjectIdentifier(value as AnyObject)
    }
    
    
    
    /// Sort the given tree by the node labels.
    ///
    /// This is used to sort the keys of dictionaries and the elements of
    /// sets when computing diffs. Although these data structures are
    /// inherently unordered, their keys and elements must be sorted when
    /// computing a diff. Otherwise, running the same test with the same input
    /// may produce a diff that has the same content, but in a different order.
    ///
    /// For example, consider the following:
    ///
    /// ```swift
    /// let expected    : [String : Int]    = ["a": 1, "b": 2, "c": 3]
    /// let actual      : [String : Int]    = ["a": 1, "b": 4, "c": 6]
    ///
    /// // Run 1 diff output:
    /// // [key "b"]: 2 -> 4
    /// // [key "c"]: 3 -> 6
    ///
    /// // Run 2 diff output:
    /// // [key "c"]: 3 -> 6
    /// // [key "b"]: 2 -> 4
    /// ```
    ///
    /// Although the content of the diff is the same, the order is different,
    /// which may create ambiguity as to whether this is the same error.
    ///
    /// This adds overhead based on the number of keys or elements being
    /// sorted, but is acceptable since it happens only when the values are
    /// different, and because clarity and determinism are important for diff
    /// output.
    ///
    /// - Note: Use ``sortSetTree(_:)`` to sort the tree of a set.
    ///
    /// - Parameter tree: The tree to sort.
    /// - Returns: The sorted tree.
    private static func sortTree(
        _ tree: [DiffNode]
    ) -> [DiffNode]
    {
        return tree.sorted
        {
            $0.label.sortKey < $1.label.sortKey
        }
    }
    
    
    
    /// Sort the given tree by the node labels.
    ///
    /// - Note: See ``sortTree(_:)`` for more information on sorting diff
    /// values.
    ///
    /// - Parameter tree: The tree to sort.
    /// - Returns: The sorted tree.
    private static func sortSetTree(
        _ tree: [DiffNode]
    ) -> [DiffNode]
    {
        return tree.sorted
        {
            let lhs : String
            let rhs : String
            
            switch $0.kind
            {
                case let .missingElement(exp):
                    
                    lhs = String(describing: exp)
                    
                case let .unexpectedElement(act):
                    
                    lhs = String(describing: act)
                    
                default:
                    
                    lhs = ""
            }
            
            switch $1.kind
            {
                case let .missingElement(exp):
                    
                    rhs = String(describing: exp)
                    
                case let .unexpectedElement(act):
                    
                    rhs = String(describing: act)
                    
                default:
                    
                    rhs = ""
            }
            
            return lhs < rhs
        }
    }
}
