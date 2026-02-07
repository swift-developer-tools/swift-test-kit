//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitBase



internal final class BoolArbitraryTests: XCTestCase
{
    // MARK: - Generation
    
    func testArbitraryProducesBothValues() throws
    {
        let context     : GenerationContext     = .init(seed: 50)
        var hasTrue     : Bool                  = false
        var hasFalse    : Bool                  = false
        
        for _ in 0..<1000
        {
            let value: Bool = .arbitrary(using: context)
            
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
    
    
    
    func testArbitraryDeterminism() throws
    {
        let context1    = GenerationContext(seed: 40, size: 50)
        let context2    = GenerationContext(seed: 40, size: 50)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(
                Bool.arbitrary(using: context1),
                Bool.arbitrary(using: context2)
            )
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkTrue() throws
    {
        XCTAssertEqual(true.shrink(), [false])
    }
    
    
    
    func testShrinkFalse() throws
    {
        XCTAssertEqual(false.shrink(), [])
    }
}
