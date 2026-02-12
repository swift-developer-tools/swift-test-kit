//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class ComparatorCycleTests: XCTestCaseStopOnFail
{
    func testSelfCycleInExpected() throws
    {
        testSelfCycle(in: .expected)
    }
    
    
    
    func testSelfCycleInActual() throws
    {
        testSelfCycle(in: .actual)
    }
    
    
    
    func testSelfCycleInBoth() throws
    {
        testSelfCycle(in: .both)
    }
    
    
    
    func testMutualCycleInExpected() throws
    {
        testMutualCycle(in: .expected)
    }
    
    
    
    func testMutualCycleInActual() throws
    {
        testMutualCycle(in: .actual)
    }
    
    
    
    func testMutualCycleInBoth() throws
    {
        testMutualCycle(in: .both)
    }
    
    
    
    func testThreeNodeCycleAtRoot() throws
    {
        testThreeNodeCycle(atRoot: true)
    }
    
    
    
    func testThreeNodeCycleNotAtRoot() throws
    {
        testThreeNodeCycle(atRoot: false)
    }
    
    
    
    func testCycleInArray() throws
    {
        testCycleInCollection(kind: .array)
    }
    
    
    
    func testCycleInDictionary() throws
    {
        testCycleInCollection(kind: .dictionary)
    }
    
    
    
    func testSharedRefWithDifferentValues() throws
    {
        let expA        = TreeNode(value: 99)
        let expB        = TreeNode(value: 1,    left: nil,      right: expA)
        let expC        = TreeNode(value: 2,    left: expA,     right: nil)
        let expRoot     = TreeNode(value: 0,    left: expB,     right: expC)
        
        let actA        = TreeNode(value: 100)
        let actB        = TreeNode(value: 1,    left: nil,      right: actA)
        let actC        = TreeNode(value: 2,    left: actA,     right: nil)
        let actRoot     = TreeNode(value: 0,    left: actB,     right: actC)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expRoot,
            actual:     actRoot,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expRoot),
            expected:   expRoot,
            actual:     actRoot,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "left"),
                    expected:   expRoot.left,
                    actual:     actRoot.left,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expB,
                            actual:     actB,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "right"),
                                    expected:   expB.right,
                                    actual:     actB.right,
                                    tree:
                                    [
                                        .makeStructural(
                                            label:      .property(name: "some"),
                                            expected:   expA,
                                            actual:     actA,
                                            tree:
                                            [
                                                .makeLeaf(
                                                    label:      .property(name:
                                                                    "value"),
                                                    expected:   expA.value,
                                                    actual:     actA.value
                                                )
                                            ]
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .property(name: "right"),
                    expected:   expRoot.right,
                    actual:     actRoot.right,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expC,
                            actual:     actC,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "left"),
                                    expected:   expC.left,
                                    actual:     actC.left,
                                    tree:
                                    [
                                        .makeStructural(
                                            label:      .property(name: "some"),
                                            expected:   expA,
                                            actual:     actA,
                                            tree:
                                            [
                                                .makeLeaf(
                                                    label:      .property(name:
                                                                    "value"),
                                                    expected:   expA.value,
                                                    actual:     actA.value
                                                )
                                            ]
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDepthLimitTakesPrecedenceOverCycleDetection() throws
    {
        let exp     = Node(value: 1)
        exp.next    = exp
        
        let act     = Node(value: 2)
        act.next    = act
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: 1)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "value"),
                    expected:   exp.value,
                    actual:     act.value
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAsymmetricCycleStructure() throws
    {
        /// The self-cycle should be detected in the expected side only, and
        /// the comparison should stop there, rather than continuing down the
        /// actual side's longer terminating chain.
        
        let expA    = Node(value: 1)
        
        expA.next   = expA
        
        let actA    = Node(value: 1)
        let actB    = Node(value: 2)
        let actC    = Node(value: 3)
        
        actA.next   = actB
        actB.next   = actC
        actC.next   = nil
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expA,
            actual:     actA,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expA),
            expected:   expA,
            actual:     actA,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "next"),
                    expected:   expA.next,
                    actual:     actA.next,
                    tree:
                    [
                        .makeCycle(
                            label:      .property(name: "some"),
                            expected:   expA,
                            actual:     actA,
                            location:   .expected
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCycleInStructInsideArray() throws
    {
        final class Container: Equatable
        {
            var node: Node?
            
            init(
                node: Node? = nil
            )
            {
                self.node = node
            }
            
            static func == (
                lhs : Container,
                rhs : Container
            ) -> Bool
            {
                return lhs === rhs
            }
        }
        
        let expNode         = Node(value: 1)
        expNode.next        = expNode
        let expContainer    = Container(node: expNode)
        
        let actNode         = Node(value: 1)
        actNode.next        = actNode
        let actContainer    = Container(node: actNode)
        
        let exp : [Container]   = [expContainer]
        let act : [Container]   = [actContainer]
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expectedInnerTree: [DiffNode] =
        [
            .makeCycle(
                label:      .property(name: "some"),
                expected:   expNode,
                actual:     actNode,
                location:   .both
            )
        ]
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .index(0),
                    expected:   expContainer,
                    actual:     actContainer,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "node"),
                            expected:   expContainer.node,
                            actual:     actContainer.node,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "some"),
                                    expected:   expNode,
                                    actual:     actNode,
                                    tree:
                                    [
                                        .makeStructural(
                                            label:      .property(name: "next"),
                                            expected:   expNode.next,
                                            actual:     actNode.next,
                                            tree:       expectedInnerTree
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSameObjectAsExpectedAndActual() throws
    {
        let exp     = Node(value: 1)
        exp.next    = exp
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        /// ``Node`` uses identity-based equality (`===`), so the same object
        /// compared to itself is equal. The comparison should not traverse
        /// into the cycle.
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCycleInOneBranchWithDifferenceInSibling() throws
    {
        let expRoot     = TreeNode(value: 0)
        let expLeft     = TreeNode(value: 1)
        
        expRoot.left    = expLeft
        expLeft.left    = expRoot
        expRoot.right   = TreeNode(value: 99)
        
        let actRoot     = TreeNode(value: 0)
        let actLeft     = TreeNode(value: 1)
        
        actRoot.left    = actLeft
        actLeft.left    = actRoot
        actRoot.right   = TreeNode(value: 50)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expRoot,
            actual:     actRoot,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expRoot),
            expected:   expRoot,
            actual:     actRoot,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "left"),
                    expected:   expRoot.left,
                    actual:     actRoot.left,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expLeft,
                            actual:     actLeft,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "left"),
                                    expected:   expLeft.left,
                                    actual:     actLeft.left,
                                    tree:
                                    [
                                        .makeCycle(
                                            label:      .property(name: "some"),
                                            expected:   expRoot,
                                            actual:     actRoot,
                                            location:   .both
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .property(name: "right"),
                    expected:   expRoot.right,
                    actual:     actRoot.right,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expRoot.right!,
                            actual:     actRoot.right!,
                            tree:
                            [
                                .makeLeaf(
                                    label:      .property(name: "value"),
                                    expected:   expRoot.right!.value,
                                    actual:     actRoot.right!.value
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleIndependentCycles() throws
    {
        let expRoot     = TreeNode(value: 0)
        let expLeft     = TreeNode(value: 1)
        let expRight    = TreeNode(value: 2)
        
        expLeft.left    = expLeft
        expRoot.left    = expLeft
        expRight.right  = expRight
        expRoot.right   = expRight
        
        let actRoot     = TreeNode(value: 0)
        let actLeft     = TreeNode(value: 1)
        let actRight    = TreeNode(value: 2)
        
        actLeft.left    = actLeft
        actRoot.left    = actLeft
        actRight.right  = actRight
        actRoot.right   = actRight
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expRoot,
            actual:     actRoot,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expRoot),
            expected:   expRoot,
            actual:     actRoot,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "left"),
                    expected:   expRoot.left,
                    actual:     actRoot.left,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expLeft,
                            actual:     actLeft,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "left"),
                                    expected:   expLeft.left,
                                    actual:     actLeft.left,
                                    tree:
                                    [
                                        .makeCycle(
                                            label:      .property(name: "some"),
                                            expected:   expLeft,
                                            actual:     actLeft,
                                            location:   .both
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                
                .makeStructural(
                    label:      .property(name: "right"),
                    expected:   expRoot.right,
                    actual:     actRoot.right,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expRoot.right!,
                            actual:     actRoot.right!,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "right"),
                                    expected:   expRight.right,
                                    actual:     actRight.right,
                                    tree:
                                    [
                                        .makeCycle(
                                            label:      .property(name: "some"),
                                            expected:   expRight,
                                            actual:     actRight,
                                            location:   .both
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
}




// MARK: - Support

extension ComparatorCycleTests
{
    // MARK: - Node
    
    /// A reference type for testing cycle detection.
    internal final class Node: Equatable
    {
        var value   : Int
        var next    : Node?
        
        
        
        init(
            value   : Int,
            next    : Node?     = nil
        )
        {
            self.value  = value
            self.next   = next
        }
        
        
        
        static func == (
            lhs: Node,
            rhs: Node
        ) -> Bool
        {
            /// Identity-based equality to ensure that difference instances
            /// are not considered equal. This forces structural comparison
            /// where cycle detection can be tested.
            return lhs === rhs
        }
    }
}



extension ComparatorCycleTests
{
    // MARK: - TreeNode
    
    /// A reference type for testing cycle detection.
    private final class TreeNode: Equatable
    {
        var value   : Int
        var left    : TreeNode?
        var right   : TreeNode?
        
        
        
        init(
            value   : Int,
            left    : TreeNode?     = nil,
            right   : TreeNode?     = nil
        )
        {
            self.value  = value
            self.left   = left
            self.right  = right
        }
        
        
        
        static func == (
            lhs: TreeNode,
            rhs: TreeNode
        ) -> Bool
        {
            /// Identity-based equality to ensure that difference instances
            /// are not considered equal. This forces structural comparison
            /// where cycle detection can be tested.
            return lhs === rhs
        }
    }
    
    
    
    // MARK: - testSelfCycle
    
    /// Tests detection of self-cycles in the given location.
    /// - Parameter cycleLocation: The cycle location to use.
    private func testSelfCycle(
        in cycleLocation: CycleLocation
    )
    {
        let exp     = Node(value: 1)
        let act     = Node(value: 1)
        
        switch cycleLocation
        {
            case .expected:
                
                exp.next    = exp
                act.next    = Node(value: 2)
                
            case .actual:
                
                exp.next    = Node(value: 2)
                act.next    = act
                
            case .both:
                
                exp.next    = exp
                act.next    = act
        }
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "next"),
                    expected:   exp.next,
                    actual:     act.next,
                    tree:
                    [
                        .makeCycle(
                            label:      .property(name: "some"),
                            expected:   exp.next!,
                            actual:     act.next!,
                            location:   cycleLocation
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - testMutualCycle
    
    /// Tests detection of mutual-cycles in the given location.
    /// - Parameter cycleLocation: The cycle location to use.
    private func testMutualCycle(
        in cycleLocation: CycleLocation
    )
    {
        let expA    = Node(value: 1)
        let expB    = Node(value: 2)
        let actA    = Node(value: 1)
        let actB    = Node(value: 2)
        
        switch cycleLocation
        {
            case .expected:
                
                let actC    = Node(value: 1)
                
                expA.next   = expB
                expB.next   = expA
                
                actA.next   = actB
                actB.next   = actC
                actC.next   = nil
                
            case .actual:
                
                let expC    = Node(value: 1)
                
                expA.next   = expB
                expB.next   = expC
                expC.next   = nil
                
                actA.next   = actB
                actB.next   = actA
                
            case .both:
                
                expA.next   = expB
                expB.next   = expA
                
                actA.next   = actB
                actB.next   = actA
        }
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expA,
            actual:     actA,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expA),
            expected:   expA,
            actual:     actA,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "next"),
                    expected:   expA.next,
                    actual:     actA.next,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expA.next!,
                            actual:     actA.next!,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "next"),
                                    expected:   expB.next,
                                    actual:     actB.next,
                                    tree:
                                    [
                                        .makeCycle(
                                            label:      .property(name: "some"),
                                            expected:   expB.next!,
                                            actual:     actB.next!,
                                            location:   cycleLocation
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - testThreeNodeCycle
    
    /// Tests a three-node cycle.
    /// - Parameter atRoot: Whether to cycle at the root.
    private func testThreeNodeCycle(
        atRoot: Bool
    )
    {
        let expA    = Node(value: 1)
        let expB    = Node(value: 2)
        let expC    = Node(value: 3)
        
        expA.next   = expB
        expB.next   = expC
        expC.next   = atRoot ? expA : expB
        
        let actA    = Node(value: 1)
        let actB    = Node(value: 2)
        let actC    = Node(value: 3)
        
        actA.next   = actB
        actB.next   = actC
        actC.next   = atRoot ? actA : actB
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   expA,
            actual:     actA,
            options:    DiffOptions(maxRecursionDepth: nil)
        )
        
        let expectedInnerTree: [DiffNode] =
        [
            .makeStructural(
                label:      .property(name: "next"),
                expected:   expC.next,
                actual:     actC.next,
                tree:
                [
                    .makeCycle(
                        label:      .property(name: "some"),
                        expected:   expC.next!,
                        actual:     actC.next!,
                        location:   .both
                    )
                ]
            )
        ]
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: expA),
            expected:   expA,
            actual:     actA,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "next"),
                    expected:   expA.next,
                    actual:     actA.next,
                    tree:
                    [
                        .makeStructural(
                            label:      .property(name: "some"),
                            expected:   expB,
                            actual:     actB,
                            tree:
                            [
                                .makeStructural(
                                    label:      .property(name: "next"),
                                    expected:   expB.next,
                                    actual:     actB.next,
                                    tree:
                                    [
                                        .makeStructural(
                                            label:      .property(name: "some"),
                                            expected:   expC,
                                            actual:     actC,
                                            tree:       expectedInnerTree
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - CollectionKind
    
    /// Collection kinds.
    private enum CollectionKind
    {
        case array
        case dictionary
    }
    
    
    
    // MARK: - testCycleInCollection
    
    /// Tests cycles in the specified kind of collection.
    /// - Parameter kind: The collection kind to use.
    private func testCycleInCollection(
        kind: CollectionKind
    )
    {
        let expNode     = Node(value: 1)
        expNode.next    = expNode
        
        let actNode     = Node(value: 1)
        actNode.next    = actNode
        
        let actual          : DiffNode
        let rootTypeName    : String
        let collectionLabel : DiffNodeLabel
        let expCollection   : Any
        let actCollection   : Any
        
        switch kind
        {
            case .array:
                
                let exp : [Node]    = [expNode]
                let act : [Node]    = [actNode]
                
                actual = Comparator.computeDiff(
                    expected:   exp,
                    actual:     act,
                    options:    DiffOptions(maxRecursionDepth: nil)
                )
                
                rootTypeName        = typeName(of: exp)
                collectionLabel     = .index(0)
                expCollection       = exp
                actCollection       = act
                
            case .dictionary:
                
                let exp : [String : Node]   = ["key": expNode]
                let act : [String : Node]   = ["key": actNode]
                
                actual = Comparator.computeDiff(
                    expected:   exp,
                    actual:     act,
                    options:    DiffOptions(maxRecursionDepth: nil)
                )
                
                rootTypeName        = typeName(of: exp)
                collectionLabel     = .key("key", typeName: "String")
                expCollection       = exp
                actCollection       = act
        }
        
        let expected = DiffNode(
            label:  .root(typeName: rootTypeName),
            kind:   .different(
                expected:   DiffValue(expCollection),
                actual:     DiffValue(actCollection),
                tree:
                [
                    .makeStructural(
                        label:      collectionLabel,
                        expected:   expNode,
                        actual:     actNode,
                        tree:
                        [
                            .makeStructural(
                                label:      .property(name: "next"),
                                expected:   expNode.next,
                                actual:     actNode.next,
                                tree:
                                [
                                    .makeCycle(
                                        label:      .property(name: "some"),
                                        expected:   expNode,
                                        actual:     actNode,
                                        location:   .both
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        )
        
        XCTAssertEqual(expected, actual)
    }
}
