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



internal final class DurationReadableTests: TestKitCase
{
    func testZero()
    {
        XCTAssertEqual("0ms", Duration.zero.readable)
    }
    
    
    
    func testSubMillisecondTruncatesToZero()
    {
        XCTAssertEqual("0ms", Duration.microseconds(999).readable)
    }
    
    
    
    func testOneMillisecond()
    {
        XCTAssertEqual("1ms", Duration.milliseconds(1).readable)
    }
    
    
    
    func testMiddleMilliseconds()
    {
        XCTAssertEqual("50ms", Duration.milliseconds(50).readable)
    }
    
    
    
    func testMillisecondsBelowSecondsThreshold()
    {
        XCTAssertEqual("999ms", Duration.milliseconds(999).readable)
    }
    
    
    
    func testOneSecond()
    {
        XCTAssertEqual("1.0s", Duration.seconds(1).readable)
    }
    
    
    
    func testFractionalSeconds()
    {
        XCTAssertEqual("1.5s", Duration.milliseconds(1500).readable)
    }
    
    
    
    func testLargerSeconds()
    {
        XCTAssertEqual("10.0s", Duration.seconds(10).readable)
    }
}
