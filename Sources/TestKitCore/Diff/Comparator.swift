//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The entry point for computing diffs between various data types.
package struct Comparator
{
    /// The context for tracking state across recursive comparison calls.
    private let context: ComparatorContext
    
    
    
    /// Computes the diff between the given values.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - options: The options for testing.
    /// - Returns: The diff node.
    package static func computeDiff<T>(
        expected    : T,
        actual      : T,
        options     : DiffOptions
    ) -> DiffNode where T : Equatable
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
            label:  .root(typeName: String(describing: type(of: expected))),
            kind:   kind
        )
    }
    
    
    
    // MARK: - Core
    
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
    private func compareEquatable<T>(
        expected    : T,
        actual      : T,
        depth       : Int
    ) -> DiffNodeKind where T : Equatable
    {
        guard expected != actual
        else
        {
            return .same
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
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:       []
                )
            }
            
            return .same
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
                expected:   DiffValue(expected),
                actual:     DiffValue(actual),
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
                expected:   DiffValue(expected),
                actual:     DiffValue(actual),
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
                return .same
            }
        }
        
        return compareStructurally(
            expected:           expected,
            actual:             actual,
            expectedMirror:     expectedMirror,
            depth:              depth
        )
    }
    
    
    
    // MARK: - Structural
    
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
                
                let tree: [DiffNode] = compareArrays(
                    expected:   expectedElements,
                    actual:     actualElements,
                    depth:      depth
                )
                
                guard !tree.isEmpty
                else
                {
                    return .same
                }
                
                return .different(
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:       tree
                )
                
                
                
            case .dictionary:
                
                guard
                    let expectedDict    = expected  as? [AnyHashable : Any],
                    let actualDict      = actual    as? [AnyHashable : Any]
                else
                {
                    break
                }

                let tree: [DiffNode] = compareDictionaries(
                    expected:   expectedDict,
                    actual:     actualDict,
                    depth:      depth
                )
                
                guard !tree.isEmpty
                else
                {
                    return .same
                }
                
                return .different(
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:       tree
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
                    let expectedSet     = expected  as? Set<AnyHashable>,
                    let actualSet       = actual    as? Set<AnyHashable>
                else
                {
                    break
                }
                
                let tree: [DiffNode] = compareSets(
                    expected:   expectedSet,
                    actual:     actualSet,
                    depth:      depth
                )
                
                guard !tree.isEmpty
                else
                {
                    return .same
                }
                
                return .different(
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:       tree
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
    
    
    
    // MARK: - Collections
    
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
                
                if kind.isSame
                {
                    continue
                }
            }
            else if let removal
            {
                kind = .missing(DiffValue(removal))
            }
            else if let insertion
            {
                kind = .unexpected(DiffValue(insertion))
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
                kind = compareAny(
                    expected:       expected[i],
                    actual:         actual[i],
                    parentDepth:    depth
                )
            }
            else if i < expected.count
            {
                kind = .missing(DiffValue(expected[i]))
            }
            else
            {
                kind = .unexpected(DiffValue(actual[i]))
            }
            
            
            
            if kind.isSame
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
    private func compareDictionaries<K, V>(
        expected    : [K : V],
        actual      : [K : V],
        depth       : Int
    ) -> [DiffNode] where K : Hashable
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
            
            if kind.isSame
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
                kind:   .missing(DiffValue(expectedValue))
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
                kind:   .unexpected(DiffValue(actualValue))
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
    private func compareSets<T>(
        expected    : Set<T>,
        actual      : Set<T>,
        depth       : Int
    ) -> [DiffNode] where T : Hashable
    {
        let missing     : Set<T>    = expected.subtracting(actual)
        let unexpected  : Set<T>    = actual.subtracting(expected)
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(
            missing.count
            + unexpected.count
        )
        
        
        
        for element in missing
        {
            let node = DiffNode(
                label:  .member,
                kind:   .missing(DiffValue(element))
            )
            
            tree.append(node)
        }
        
        
        
        for element in unexpected
        {
            let node = DiffNode(
                label:  .member,
                kind:   .unexpected(DiffValue(element))
            )
            
            tree.append(node)
        }
        
        
        
        return Self.sortSetTree(tree)
    }
    
    
    
    // MARK: - Other
    
    /// Compares the given `Mirror` children.
    ///
    /// This is used when two values are known to be unequal and are not
    /// leaf nodes (for example, they are not primitive values). This finds
    /// where the difference is located within the data structures.
    ///
    /// The returned tree may be empty if the difference could not be found
    /// within the children of the given values. This can occur when a type's
    /// `Equatable` implementation considers state not visible to
    /// `Mirror`, or when the type has no useful `Mirror` children.
    ///
    /// For example, a class may use identity-based equality (`===`), but the
    /// given instances have identical property values. The `Equatable`
    /// implementation produces a not-equal result, but all `Mirror` children
    /// are the same.
    ///
    /// Regardless, this method always returns a different node kind, since
    /// the given values are already known to be unequal.
    ///
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - expectedMirror: The `Mirror` of the expected value.
    ///   - actualMirror: The `Mirror` of the actual value.
    ///   - depth: The recursion depth.
    /// - Returns: Always ``DiffNodeKind/different(expected:actual:tree)``.
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
                
                label = Self.makeDiffNodeLabel(
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
                
                label = Self.makeDiffNodeLabel(
                    from:   expectedChild.label,
                    index:  i
                )
                
                kind = .missing(DiffValue(expectedChild.value))
            }
            else
            {
                /// Only the actual value has this child.
                let actualChild: Mirror.Child = actualChildren[i]
                
                label = Self.makeDiffNodeLabel(
                    from:   actualChild.label,
                    index:  i
                )
                
                kind = .unexpected(DiffValue(actualChild.value))
            }
            
            
            
            if kind.isSame
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
            expected:   DiffValue(expected),
            actual:     DiffValue(actual),
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
                expected:   DiffValue(expected),
                actual:     DiffValue(actual),
                tree:       []
            )
        }
        
        
        
        /// `Mirror` represents an enum case with associated values as a single
        /// child, where `label` is the case name and `value` contains all the
        /// associated values, if any (directly for single values, or as a
        /// tuple for multiple values).
        ///
        /// `typealias Mirror.Child = (label: String?, value: Any)`
        ///
        /// | Enum Case              | `Mirror.children`                     |
        /// |------------------------|---------------------------------------|
        /// | `case noAssocValue`    | None                                  |
        /// | `case one(T)`          | `(label: "one", value: T) `           |
        /// | `case two(a: T, b: T)` | `(label: "two", value: (a: T, b: T))` |
        ///
        /// Therefore, checking only `Mirror.children.first` is appropriate.
        guard
            let expectedAssoc   : Any   = expectedMirror.children.first?.value,
            let actualAssoc     : Any   = actualMirror.children.first?.value
        else
        {
            return .same
        }
        
        
        
        let expectedAssocMirror     = Mirror(reflecting: expectedAssoc)
        let actualAssocMirror       = Mirror(reflecting: actualAssoc)
        
        if expectedAssocMirror.children.isEmpty
        {
            /// This is a single unlabeled primitive value (`case v(T)`).
            let innerKind: DiffNodeKind = compareAny(
                expected:       expectedAssoc,
                actual:         actualAssoc,
                parentDepth:    depth
            )
            
            if innerKind.isSame
            {
                return .same
            }
            
            return .different(
                expected:   DiffValue(expected),
                actual:     DiffValue(actual),
                tree:
                [
                    DiffNode(
                        label:  .index(0),
                        kind:   innerKind
                    )
                ]
            )
        }
        
        
        
        /// This is a labeled value (`case v(data: T)`), or there are multiple
        /// associated values (`case v(T, T)`), or it is a struct/class with
        /// properties.
        let assocKind: DiffNodeKind = compareMirrorChildren(
            expected:           expectedAssoc,
            actual:             actualAssoc,
            expectedMirror:     expectedAssocMirror,
            actualMirror:       actualAssocMirror,
            depth:              depth
        )
        
        if assocKind.isSame
        {
            return .same
        }
        
        guard case let .different(_, _, assocTree) = assocKind
        else
        {
            return .different(
                expected:   DiffValue(expected),
                actual:     DiffValue(actual),
                tree:       []
            )
        }
        
        return .different(
            expected:   DiffValue(expected),
            actual:     DiffValue(actual),
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
                
                return .same
                
            case let (.some(exp), .some(act)):
                
                let childKind: DiffNodeKind = compareAny(
                    expected:       exp.value,
                    actual:         act.value,
                    parentDepth:    depth
                )
                
                if childKind.isSame
                {
                    return .same
                }
                
                return .different(
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
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
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:
                    [
                        DiffNode(
                            label:  .property(name: "some"),
                            kind:   .missing(DiffValue(exp.value))
                        )
                    ]
                )
                
            case let (.none, .some(act)):
                
                return .different(
                    expected:   DiffValue(expected),
                    actual:     DiffValue(actual),
                    tree:
                    [
                        DiffNode(
                            label:  .property(name: "some"),
                            kind:   .unexpected(DiffValue(act.value))
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
    private static func makeDiffNodeLabel(
        from mirrorLabel    : String?,
        index               : Int
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
    /// computing a diff. Otherwise, running the same test with the same value
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
                case let .missing(exp)      : lhs = String(describing: exp)
                case let .unexpected(act)   : lhs = String(describing: act)
                default                     : lhs = ""
            }
            
            switch $1.kind
            {
                case let .missing(exp)      : rhs = String(describing: exp)
                case let .unexpected(act)   : rhs = String(describing: act)
                default                     : rhs = ""
            }
            
            return lhs < rhs
        }
    }
}
