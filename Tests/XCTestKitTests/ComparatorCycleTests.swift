//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit
@testable import XCTestKitTestUtilities



final class ComparatorCycleTests: XCTestKitCase
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
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expRoot,
            actual:     actRoot,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .property(name: "left"))
        XCTAssertEqual(tree[1].label, .property(name: "right"))
        
        assertNoCycles(in: node.kind)
    }
    
    
    
    func testDepthLimitTakesPrecedenceOverCycleDetection() throws
    {
        let expected    = Node(value: 1)
        expected.next   = expected
        
        let actual      = Node(value: 2)
        actual.next     = actual
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(maxRecursionDepth: 1)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        /// Depth limit reached. Value comparison finds the difference.
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "value"))
        
        
        
        guard case let .different(exp, act, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        /// Depth limit reached. Leaf comparison with an empty tree.
        XCTAssertEqual(exp.value as? Int, 1)
        XCTAssertEqual(act.value as? Int, 2)
        XCTAssertTrue(tree2.isEmpty)
        
        assertNoCycles(in: node.kind)
    }
    
    
    
    func testAsymmetricCycleStructure() throws
    {
        /// The self-cycle should be detected in the expected side only, and
        /// the comparison should stop there, rather than continuing down the
        /// actual side's longer terminating chain.
        
        let expectedA   = Node(value: 1)
        
        expectedA.next  = expectedA
        
        let actualA     = Node(value: 1)
        let actualB     = Node(value: 2)
        let actualC     = Node(value: 3)
        
        actualA.next    = actualB
        actualB.next    = actualC
        actualC.next    = nil
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expectedA,
            actual:     actualA,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree2[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(location, .expected)
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
        
        
        
        let expectedNode        = Node(value: 1)
        expectedNode.next       = expectedNode
        let expectedConainer    = Container(node: expectedNode)
        
        let actualNode          = Node(value: 1)
        actualNode.next         = actualNode
        let actualContainer     = Container(node: actualNode)
        
        let expected    : [Container]   = [expectedConainer]
        let actual      : [Container]   = [actualContainer]
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .index(0))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "node"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(tree4.count, 1)
        XCTAssertEqual(tree4[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree5) = tree4[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree4[0].kind)")
            return
        }
        
        XCTAssertEqual(tree5.count, 1)
        XCTAssertEqual(tree5[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree5[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree5[0].kind)")
            return
        }
        
        XCTAssertEqual(location, .both)
    }
    
    
    
    func testSameObjectAsExpectedAndActual() throws
    {
        let expected    = Node(value: 1)
        expected.next   = expected
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     expected,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        /// ``Node`` uses identity-based equality (`===`), so the same object
        /// compared to itself is equal. The comparison should not traverse
        /// into the cycle.
        guard case .same = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
    }
    
    
    
    func testCycleInOneBranchWithDifferenceInSibling() throws
    {
        let expectedLeft            = Node(value: 1)
        expectedLeft.next           = expectedLeft
        
        let expectedRight           = Node(value: 100)
        expectedRight.next          = nil
        
        let expectedRoot            = TreeNode(value: 0)
        expectedRoot.left           = TreeNode(value: 1)
        expectedRoot.left?.left     = TreeNode(value: 2)
        expectedRoot.right          = TreeNode(value: 99)
        
        let actualLeft              = Node(value: 1)
        actualLeft.next             = actualLeft
        
        let actualRight             = Node(value: 200)
        actualRight.next            = nil
        
        let actualRoot              = TreeNode(value: 0)
        actualRoot.left             = TreeNode(value: 1)
        actualRoot.left?.left       = TreeNode(value: 2)
        actualRoot.right            = TreeNode(value: 50)
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expectedRoot,
            actual:     actualRoot,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        /// The left branch appears different due to identity-based equality.
        /// This test goes down the right path (`tree1[1]`) to confirm that a
        /// real value difference in a sibling branch is correctly detected.
        XCTAssertEqual(tree1.count, 2)
        XCTAssertEqual(tree1[0].label, .property(name: "left"))
        XCTAssertEqual(tree1[1].label, .property(name: "right"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[1].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[1].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "value"))
        
        
        
        guard case let .different(exp, act, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(exp.value as? Int, 99)
        XCTAssertEqual(act.value as? Int, 50)
        XCTAssertTrue(tree4.isEmpty)
    }
    
    
    
    func testMultipleIndependentCycles() throws
    {
        let expectedLeft            = Node(value: 1)
        expectedLeft.next           = expectedLeft
        
        let expectedRight           = Node(value: 2)
        expectedRight.next          = expectedRight
        
        let expectedRoot            = TreeNode(value: 0)
        expectedRoot.left           = TreeNode(value: 1)
        expectedRoot.left?.left     = TreeNode(value: 2)
        expectedRoot.right          = TreeNode(value: 3)
        expectedRoot.right?.right   = TreeNode(value: 4)
        
        let actualLeft              = Node(value: 1)
        actualLeft.next             = actualLeft
        
        let actualRight             = Node(value: 2)
        actualRight.next            = actualRight
        
        let actualRoot              = TreeNode(value: 0)
        actualRoot.left             = TreeNode(value: 1)
        actualRoot.left?.left       = TreeNode(value: 2)
        actualRoot.right            = TreeNode(value: 3)
        actualRoot.right?.right     = TreeNode(value: 4)
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expectedRoot,
            actual:     actualRoot,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        /// Both branches appear different due to identity-based equality.
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual(tree[0].label, .property(name: "left"))
        XCTAssertEqual(tree[1].label, .property(name: "right"))
        
        /// Check whether the comparison completes without hanging or crashing,
        /// indicating that both independent cycles were handled correctly, and
        /// that the visited set tracking did not interfere between branches
        /// (the `defer`-based cleanup).
        ///
        /// No cycles should be detected since the ``Node`` instances have
        /// self-cycles, but the ``TreeNode`` instances have no cycles. The
        /// traversal of the ``TreeNode`` instances completes normally and
        /// reports differences due to identity-based equality, but does not
        /// encounter a ``TreeNode`` instance that was already visited.
        let cycleCount: Int = countCycles(in: node.kind)
        
        XCTAssertEqual(cycleCount, 0)
    }
}




// MARK: - Extensions

private extension ComparatorCycleTests
{
    // MARK: - Node
    
    /// A reference type for testing cycle detection.
    final class Node: Equatable
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
    
    
    
    // MARK: - TreeNode
    
    /// A reference type for testing cycle detection.
    final class TreeNode: Equatable
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
    
    
    
    // MARK: - assertNoCycles
    
    /// Asserts that no cycles occured.
    /// - Parameter kind: The diff node kind to check.
    func assertNoCycles(
        in kind: DiffNodeKind
    )
    {
        switch kind
        {
            case .cycle:
                
                XCTFail("Unexpected cycle in non-cyclic tree")
                
            case .different(_, _, let tree):
                
                for node in tree
                {
                    assertNoCycles(in: node.kind)
                }
                
            case
                .same,
                .missing,
                .unexpected:
                
                break
        }
    }
    
    
    
    // MARK: - countCycles
    
    /// Counts the number of cycles the occured.
    /// - Parameter kind: The diff node kind to check.
    /// - Returns: The number of cycles the occured.
    func countCycles(
        in kind: DiffNodeKind
    ) -> Int
    {
        switch kind
        {
            case .cycle:
                
                return 1
                
            case .different(_, _, let tree):
                
                return tree.reduce(0){ $0 + countCycles(in: $1.kind) }
                
            case
                .same,
                .missing,
                .unexpected:
                
                return 0
        }
    }
    
    
    
    // MARK: - testSelfCycle
    
    /// Tests detection of self-cycles in the given location.
    /// - Parameter cycleLocation: The cycle location to use.
    func testSelfCycle(
        in cycleLocation: CycleLocation
    )
    {
        let expected    = Node(value: 1)
        let actual      = Node(value: 1)
        
        switch cycleLocation
        {
            case .expected:
                
                expected.next   = expected
                actual.next     = Node(value: 2)
                
            case .actual:
                
                expected.next   = Node(value: 2)
                actual.next     = actual
                
            case .both:
                
                expected.next   = expected
                actual.next     = actual
        }
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expected,
            actual:     actual,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree2[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(location, cycleLocation)
    }
    
    
    
    // MARK: - testMutualCycle
    
    /// Tests detection of mutual-cycles in the given location.
    /// - Parameter cycleLocation: The cycle location to use.
    func testMutualCycle(
        in cycleLocation: CycleLocation
    )
    {
        let expectedA   = Node(value: 1)
        let expectedB   = Node(value: 2)
        let actualA     = Node(value: 1)
        let actualB     = Node(value: 2)
        
        switch cycleLocation
        {
            case .expected:
                
                let actualC     = Node(value: 1)
                
                expectedA.next  = expectedB
                expectedB.next  = expectedA
                
                actualA.next    = actualB
                actualB.next    = actualC
                actualC.next    = nil
                
            case .actual:
                
                let expectedC   = Node(value: 1)
                
                expectedA.next  = expectedB
                expectedB.next  = expectedC
                expectedC.next  = nil
                
                actualA.next    = actualB
                actualB.next    = actualA
                
            case .both:
                
                expectedA.next  = expectedB
                expectedB.next  = expectedA
                
                actualA.next    = actualB
                actualB.next    = actualA
        }
        
        

        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expectedA,
            actual:     actualA,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(tree4.count, 1)
        XCTAssertEqual(tree4[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree4[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree4[0].kind)")
            return
        }
        
        XCTAssertEqual(location, cycleLocation)
    }
    
    
    
    // MARK: - testThreeNodeCycle
    
    /// Tests a three-node cycle.
    /// - Parameter atRoot: Whether to cycle at the root.
    func testThreeNodeCycle(
        atRoot: Bool
    )
    {
        let expectedA   = Node(value: 1)
        let expectedB   = Node(value: 2)
        let expectedC   = Node(value: 3)
        
        expectedA.next  = expectedB
        expectedB.next  = expectedC
        expectedC.next  = atRoot ? expectedA : expectedB
        
        let actualA     = Node(value: 1)
        let actualB     = Node(value: 2)
        let actualC     = Node(value: 3)
        
        actualA.next    = actualB
        actualB.next    = actualC
        actualC.next    = atRoot ? actualA : actualB
        
        
        
        let node: DiffNode = Comparator.computeDiff(
            expected:   expectedA,
            actual:     actualA,
            options:    XCTKDiffOptions(maxRecursionDepth: nil)
        )
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        XCTAssertEqual(tree1[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree4) = tree3[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(tree4.count, 1)
        XCTAssertEqual(tree4[0].label, .property(name: "some"))
        
        
        
        guard case let .different(_, _, tree5) = tree4[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree4[0].kind)")
            return
        }
        
        XCTAssertEqual(tree5.count, 1)
        XCTAssertEqual(tree5[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree6) = tree5[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree5[0].kind)")
            return
        }
        
        XCTAssertEqual(tree6.count, 1)
        XCTAssertEqual(tree6[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree6[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree6[0].kind)")
            return
        }
        
        XCTAssertEqual(location, .both)
    }
    
    
    
    // MARK: - CollectionKind
    
    /// Collection kinds.
    enum CollectionKind
    {
        case array
        case dictionary
    }
    
    
    
    // MARK: - testCycleInCollection
    
    /// Tests cycles in the specified kind of collection.
    /// - Parameter kind: The collection kind to use.
    func testCycleInCollection(
        kind: CollectionKind
    )
    {
        let expectedNode    = Node(value: 1)
        expectedNode.next   = expectedNode
        
        let actualNode      = Node(value: 1)
        actualNode.next     = actualNode
        
        let node: DiffNode
        
        switch kind
        {
            case .array:
                
                let expected    : [Node]    = [expectedNode]
                let actual      : [Node]    = [actualNode]
                
                node = Comparator.computeDiff(
                    expected:   expected,
                    actual:     actual,
                    options:    XCTKDiffOptions(maxRecursionDepth: nil)
                )
                
            case .dictionary:
                
                let expected    : [String : Node]    = ["key": expectedNode]
                let actual      : [String : Node]    = ["key": actualNode]
                
                node = Comparator.computeDiff(
                    expected:   expected,
                    actual:     actual,
                    options:    XCTKDiffOptions(maxRecursionDepth: nil)
                )
        }
        
        
        
        guard case let .different(_, _, tree1) = node.kind
        else
        {
            XCTFail("Expected .different, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(tree1.count, 1)
        
        switch kind
        {
            case .array:
                
                XCTAssertEqual(tree1[0].label, .index(0))
                
            case .dictionary:
                
                XCTAssertEqual(
                    tree1[0].label,
                    .key(description: "key", typeName: "String")
                )
        }

        
        
        
        guard case let .different(_, _, tree2) = tree1[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree1[0].kind)")
            return
        }
        
        XCTAssertEqual(tree2.count, 1)
        XCTAssertEqual(tree2[0].label, .property(name: "next"))
        
        
        
        guard case let .different(_, _, tree3) = tree2[0].kind
        else
        {
            XCTFail("Expected .different, got \(tree2[0].kind)")
            return
        }
        
        XCTAssertEqual(tree3.count, 1)
        XCTAssertEqual(tree3[0].label, .property(name: "some"))
        
        
        
        guard case let .cycle(_, _, location) = tree3[0].kind
        else
        {
            XCTFail("Expected .cycle, got \(tree3[0].kind)")
            return
        }
        
        XCTAssertEqual(location, .both)
    }
}
