//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class PackIndexTests: TestKitCase
{
    func testSingleNextCall()
    {
        let packIndex = PackIndex()
        
        XCTAssertEqual(packIndex.next(), 0)
    }
    
    
    
    func testSequentialFromZero()
    {
        let packIndex = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex.next(), index)
        }
    }
    
    
    
    func testNewInstanceStartsAtZero()
    {
        let packIndex1 = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex1.next(), index)
        }
        
        let packIndex2 = PackIndex()
        
        for index in 0..<1000
        {
            XCTAssertEqual(packIndex2.next(), index)
        }
    }
}
