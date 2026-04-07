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
        XCTAssertEqual("0 ns", Duration.zero.readable)
    }
    
    
    
    func testOneNanosecond()
    {
        XCTAssertEqual("1 ns", Duration.nanoseconds(1).readable)
    }
    
    
    
    func testOneMicrosecond()
    {
        XCTAssertEqual("1 μs", Duration.microseconds(1).readable)
    }
    
    
    
    func testOneMillisecond()
    {
        XCTAssertEqual("1 ms", Duration.milliseconds(1).readable)
    }
    
    
    
    func testOneSecond()
    {
        XCTAssertEqual("1 sec", Duration.seconds(1).readable)
    }
    
    
    
    func testNanosecondsBelowMicrosecondThreshold()
    {
        XCTAssertEqual("999 ns", Duration.nanoseconds(999).readable)
    }
    
    
    
    func testMicrosecondsBelowMillisecondThreshold()
    {
        XCTAssertEqual("999 μs", Duration.microseconds(999).readable)
    }
    
    
    
    func testMillisecondsBelowSecondsThreshold()
    {
        XCTAssertEqual("999 ms", Duration.milliseconds(999).readable)
    }
    
    
    
    func testNanosecondMicrosecondExactBoundary()
    {
        XCTAssertEqual("1 μs", Duration.nanoseconds(1000).readable)
    }
    
    
    
    func testMicrosecondMillisecondExactBoundary()
    {
        XCTAssertEqual("1 ms", Duration.microseconds(1000).readable)
    }
    
    
    
    func testMillisecondSecondExactBoundary()
    {
        XCTAssertEqual("1 sec", Duration.milliseconds(1000).readable)
    }
    
    
    
    func testFractionalMicroseconds()
    {
        XCTAssertEqual("1.5 μs", Duration.nanoseconds(1500).readable)
    }
    
    
    
    func testFractionalMilliseconds()
    {
        XCTAssertEqual("1.5 ms", Duration.microseconds(1500).readable)
    }
    
    
    
    func testFractionalSeconds()
    {
        XCTAssertEqual("1.5 sec", Duration.milliseconds(1500).readable)
    }
    
    
    
    func testFractionalRoundsToNearestOrEven()
    {
        XCTAssertEqual("1.2 ms", Duration.microseconds(1250).readable)
    }
    
    
    
    func testMiddleMilliseconds()
    {
        XCTAssertEqual("50 ms", Duration.milliseconds(50).readable)
    }
    
    
    
    func testLargerSeconds()
    {
        XCTAssertEqual("3,600 sec", Duration.seconds(3600).readable)
    }
}
