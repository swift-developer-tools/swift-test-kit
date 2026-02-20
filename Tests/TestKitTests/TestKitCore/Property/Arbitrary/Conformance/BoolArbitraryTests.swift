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



internal final class BoolArbitraryTests: TestKitCase
{
    // MARK: - Generation
    
    func testArbitraryProducesBothValues()
    {
        var hasTrue     : Bool  = false
        var hasFalse    : Bool  = false
        
        for _ in 0..<1000
        {
            let value: Bool = .arbitrary(using: .random)
            
            if value
            {
                hasTrue = true
            }
            else
            {
                hasFalse = true
            }
            
            if
                hasTrue,
                hasFalse
            {
                break
            }
        }
        
        XCTAssertTrue(hasTrue)
        XCTAssertTrue(hasFalse)
    }
    
    
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: Bool.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkTrue()
    {
        XCTAssertEqual(true.shrink(), [false])
    }
    
    
    
    func testShrinkFalse()
    {
        XCTAssertEqual(false.shrink(), [])
    }
}
