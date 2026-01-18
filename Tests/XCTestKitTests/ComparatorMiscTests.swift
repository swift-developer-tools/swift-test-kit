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



final class ComparatorMiscTests: XCTestKitCase
{
    func testPrimitiveEqualValues() throws
    {
        let node: DiffNode = Comparator.computeDiff(
            expected:   10,
            actual:     10
        )
        
        XCTAssertEqual(node.label, .root)
        
        guard case let .same(exp) = node.kind
        else
        {
            XCTFail("Expected .same, got \(node.kind)")
            return
        }
        
        XCTAssertEqual(exp as? Int, 10)
    }
}
