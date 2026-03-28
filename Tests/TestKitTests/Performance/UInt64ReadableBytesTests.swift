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



internal final class UInt64ReadableBytesTests: TestKitCase
{
    func testZero()
    {
        XCTAssertEqual("0 B", UInt64(0).readableBytes)
    }
    
    
    
    func testOne()
    {
        XCTAssertEqual("1 B", UInt64(1).readableBytes)
    }
    
    
    
    func testJustBelowKB()
    {
        XCTAssertEqual("1023 B", UInt64(1023).readableBytes)
    }
    
    
    
    func testExactlyOneKB()
    {
        XCTAssertEqual("1 KB", UInt64(1024).readableBytes)
    }
    
    
    
    func testFractionalKB()
    {
        XCTAssertEqual("1.5 KB", UInt64(1536).readableBytes)
    }
    
    
    
    func testJustBelowMB()
    {
        XCTAssertEqual("1024 KB", UInt64(1_048_575).readableBytes)
    }
    
    
    
    func testExactlyOneMB()
    {
        XCTAssertEqual("1 MB", UInt64(1_048_576).readableBytes)
    }
    
    
    
    func testFractionalMB()
    {
        XCTAssertEqual("2.3 MB", UInt64(2_411_724).readableBytes)
    }
    
    
    
    func testJustBelowGB()
    {
        XCTAssertEqual("1024 MB", UInt64(1_073_741_823).readableBytes)
    }
    
    
    
    func testExactlyOneGB()
    {
        XCTAssertEqual("1 GB", UInt64(1_073_741_824).readableBytes)
    }
    
    
    
    func testFractionalGB()
    {
        XCTAssertEqual("1.1 GB", UInt64(1_181_116_006).readableBytes)
    }
    
    
    
    func testLargeGB()
    {
        XCTAssertEqual("16 GB", UInt64(17_179_869_184).readableBytes)
    }
}
