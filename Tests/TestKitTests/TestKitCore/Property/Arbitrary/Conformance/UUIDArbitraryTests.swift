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



internal final class UUIDArbitraryTests: TestKitCase
{
    // MARK: - Generation
    
    func testGenerationDeterminism()
    {
        assertArbitraryDeterminism(of: UUID.self)
    }
    
    
    
    func testGenerationVersion4()
    {
        for _ in 0..<1000
        {
            let uuid = UUID.arbitrary(using: .random)
            
            /// Byte 6 upper nibble must be `0100`, indicating version 4.
            let version: UInt8 = uuid.uuid.6 >> 4
            
            XCTAssertEqual(version, 4)
        }
    }
    
    
    
    func testGenerationVariant1()
    {
        for _ in 0..<1000
        {
            let uuid = UUID.arbitrary(using: .random)
            
            /// Byte 8 upper two bits must be `10`, indicating variant 1.
            let variant: UInt8 = uuid.uuid.8 >> 6
            
            XCTAssertEqual(variant, 0b10)
        }
    }
    
    
    
    func testGenerationStringFormat() throws
    {
        let pattern: String
            = #"^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$"#
        
        let regex = try NSRegularExpression(pattern: pattern)
        
        for _ in 0..<1000
        {
            let string: String = UUID.arbitrary(using: .random).uuidString
            
            let range: NSRange = .init(
                string.startIndex...,
                in: string
            )
            
            let matches: Int = regex.numberOfMatches(
                in:     string,
                range:  range
            )
            
            XCTAssertEqual(matches, 1)
        }
    }
    
    
    
    func testGenerationUniqueness()
    {
        var seen: Set<UUID> = []
        
        for _ in 0..<1000
        {
            let uuid = UUID.arbitrary(using: .randomSeed(size: Int(UInt8.max)))
            
            XCTAssertFalse(seen.contains(uuid))
            
            seen.insert(uuid)
        }
    }
    
    
    
    func testGenerationByteVariety()
    {
        var uniquePerPosition: [Set<UInt8>] = Array(
            repeating:  [],
            count:      16
        )
        
        for _ in 0..<10_000
        {
            let uuid = UUID.arbitrary(using: .randomSeed(size: Int(UInt8.max)))
            
            let bytes: [UInt8] = Mirror(reflecting: uuid.uuid).children.map
            {
                return $0.value as! UInt8
            }
            
            for (index, byte) in bytes.enumerated()
            {
                uniquePerPosition[index].insert(byte)
            }
        }
        
        for (index, unique) in uniquePerPosition.enumerated()
        {
            if index == 6
            {
                /// Byte 6: the upper nibble is fixed (`0x4_`), only the lower
                /// nibble varies. There are at most 16 distinct values.
                XCTAssertGreaterThan(unique.count, 1)
                XCTAssertLessThanOrEqual(unique.count, 16)
            }
            else if index == 8
            {
                /// Byte 8: the upper two bits are fixed (`10xxxxxx`), so the
                /// values range from `0x80` to `0xBF`. There are at most 64
                /// distinct values.
                XCTAssertGreaterThan(unique.count, 1)
                XCTAssertLessThanOrEqual(unique.count, 64)
                
                for value in unique
                {
                    XCTAssertGreaterThanOrEqual(value, 0x80)
                    XCTAssertLessThanOrEqual(value, 0xBF)
                }
            }
            else
            {
                let expected = Int(Double(Int(UInt8.max) + 1) * 0.95)
                
                XCTAssertGreaterThan(unique.count, expected)
            }
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingReturnsEmpty()
    {
        for _ in 0..<1000
        {
            let uuid = UUID.arbitrary(using: .random)
            
            XCTAssertEqual(uuid.shrink(), [])
        }
    }
}
