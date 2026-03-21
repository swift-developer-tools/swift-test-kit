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



internal final class ByteCountTests: TestKitCase
{
    // MARK: - Bytes
    
    func testBytesInteger()
    {
        XCTAssertEqual(50, ByteCount.bytes(50).rawValue)
    }
    
    
    
    // MARK: - Kilobytes
    
    func testKilobytesInteger()
    {
        XCTAssertEqual(1024, ByteCount.kilobytes(1).rawValue)
    }
    
    
    
    func testKilobytesDouble()
    {
        XCTAssertEqual(1536, ByteCount.kilobytes(1.5).rawValue)
    }
    
    
    
    // MARK: - Megabytes
    
    func testMegabytesInteger()
    {
        XCTAssertEqual(1_048_576, ByteCount.megabytes(1).rawValue)
    }
    
    
    
    func testMegabytesDouble()
    {
        XCTAssertEqual(2_621_440, ByteCount.megabytes(2.5).rawValue)
    }
    
    
    
    // MARK: - Gigabytes
    
    func testGigabytesInteger()
    {
        let count = ByteCount.gigabytes(1)
        
        XCTAssertEqual(1_073_741_824, count.rawValue)
    }
    
    
    
    func testGigabytesDouble()
    {
        XCTAssertEqual(536_870_912, ByteCount.gigabytes(0.5).rawValue)
    }
    
    
    
    // MARK: - Zero
    
    func testZeroFactory()
    {
        XCTAssertEqual(0, ByteCount.zero.rawValue)
        XCTAssertEqual(ByteCount.bytes(0), ByteCount.zero)
    }
    
    
    
    func testBytesIntegerZero()
    {
        XCTAssertEqual(0, ByteCount.bytes(0).rawValue)
    }
    
    
    
    func testKilobytesIntegerZero()
    {
        XCTAssertEqual(0, ByteCount.kilobytes(0).rawValue)
    }
    
    
    
    func testKilobytesDoubleZero()
    {
        XCTAssertEqual(0, ByteCount.kilobytes(0.0).rawValue)
    }
    
    
    
    func testMegabytesIntegerZero()
    {
        XCTAssertEqual(0, ByteCount.megabytes(0).rawValue)
    }
    
    
    
    func testMegabytesDoubleZero()
    {
        XCTAssertEqual(0, ByteCount.megabytes(0.0).rawValue)
    }
    
    
    
    func testGigabytesIntegerZero()
    {
        XCTAssertEqual(0, ByteCount.gigabytes(0).rawValue)
    }
    
    
    
    func testGigabytesDoubleZero()
    {
        XCTAssertEqual(0, ByteCount.gigabytes(0.0).rawValue)
    }
    
    
    
    // MARK: - Maximum
    
    func testBytesMaximum()
    {
        XCTAssertEqual(UInt64.max, ByteCount.bytes(UInt64.max).rawValue)
    }
    
    
    
    func testKilobytesMaximum()
    {
        let max: UInt64 = UInt64.max / 1024
        
        XCTAssertEqual(max * 1024, ByteCount.kilobytes(max).rawValue)
    }
    
    
    
    func testMegabytesMaximum()
    {
        let max: UInt64 = UInt64.max / 1_048_576
        
        XCTAssertEqual(max * 1_048_576, ByteCount.megabytes(max).rawValue)
    }
    
    
    
    func testGigabytesMaximum()
    {
        let max: UInt64 = UInt64.max / 1_073_741_824
        
        XCTAssertEqual(max * 1_073_741_824, ByteCount.gigabytes(max).rawValue)
    }
    
    
    
    // MARK: - Comparable
    
    func testLessThanAcrossScales()
    {
        XCTAssertTrue(ByteCount.bytes(100) < .kilobytes(1))
    }
    
    
    
    func testGreaterThanAcrossScales()
    {
        XCTAssertTrue(ByteCount.megabytes(1) > .kilobytes(1))
    }
    
    
    
    func testNotLessThanEqual()
    {
        XCTAssertFalse(ByteCount.kilobytes(1) < .kilobytes(1))
    }
    
    
    
    // MARK: - Equatable
    
    func testEqualAcrossFactories()
    {
        XCTAssertEqual(ByteCount.bytes(1024), .kilobytes(1))
    }
    
    
    
    // MARK: - Hashable
    
    func testHashableConsistency()
    {
        XCTAssertEqual(
            ByteCount.kilobytes(1).hashValue,
            ByteCount.bytes(1024).hashValue
        )
    }
    
    
    
    // MARK: - Description
    
    func testDescriptionZero()
    {
        XCTAssertEqual("0 B", ByteCount.zero.description)
    }
    
    
    
    func testDescriptionBytes()
    {
        XCTAssertEqual("512 B", ByteCount.bytes(512).description)
    }
    
    
    
    func testDescriptionKilobytes()
    {
        XCTAssertEqual("1 KB", ByteCount.kilobytes(1).description)
    }
    
    
    
    func testDescriptionMegabytes()
    {
        XCTAssertEqual("2 MB", ByteCount.megabytes(2).description)
    }
    
    
    
    func testDescriptionGigabytes()
    {
        XCTAssertEqual("1 GB", ByteCount.gigabytes(1).description)
    }
    
    
    
    func testDescriptionFractional()
    {
        XCTAssertEqual("1.5 MB", ByteCount.megabytes(1.5).description)
    }
    
    
    
    // MARK: - Arithmetic
    
    func testAddition()
    {
        let result: ByteCount = .bytes(100) + .bytes(200)
        
        XCTAssertEqual(300, result.rawValue)
    }
    
    
    
    func testAdditionZeroLHS()
    {
        let result: ByteCount = .zero + .kilobytes(1)
        
        XCTAssertEqual(1024, result.rawValue)
    }
    
    
    
    func testAdditionZeroRHS()
    {
        let result: ByteCount = .kilobytes(1) + .zero
        
        XCTAssertEqual(1024, result.rawValue)
    }
    
    
    
    func testAdditionCrossScale()
    {
        let result: ByteCount = .bytes(512) + .kilobytes(1)
        
        XCTAssertEqual(1536, result.rawValue)
    }
    
    
    
    func testAdditionMaximumBoundary()
    {
        let result: ByteCount = .bytes(UInt64.max) + .zero
        
        XCTAssertEqual(UInt64.max, result.rawValue)
    }
    
    
    
    func testSubtraction()
    {
        let result: ByteCount = .bytes(300) - .bytes(100)
        
        XCTAssertEqual(200, result.rawValue)
    }
    
    
    
    func testSubtractionToZero()
    {
        let result: ByteCount = .kilobytes(1) - .kilobytes(1)
        
        XCTAssertEqual(0, result.rawValue)
    }
    
    
    
    func testSubtractionZeroRHS()
    {
        let result: ByteCount = .megabytes(1) - .zero
        
        XCTAssertEqual(1_048_576, result.rawValue)
    }
    
    
    
    func testSubtractionCrossScale()
    {
        let result: ByteCount = .kilobytes(1) - .bytes(512)
        
        XCTAssertEqual(512, result.rawValue)
    }
    
    
    
    func testAdditionCompoundAssignment()
    {
        var result: ByteCount = .bytes(100)
        
        result += .bytes(50)
        
        XCTAssertEqual(150, result.rawValue)
    }
    
    
    
    func testSubtractionCompoundAssignment()
    {
        var result: ByteCount = .bytes(100)
        
        result -= .bytes(30)
        
        XCTAssertEqual(70, result.rawValue)
    }
    
    
    
    func testUnaryPlus()
    {
        let result: ByteCount = .bytes(50)
        
        XCTAssertEqual(50, (+result).rawValue)
    }
}
