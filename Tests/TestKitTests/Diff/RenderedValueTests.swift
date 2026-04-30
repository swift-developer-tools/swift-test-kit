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



internal final class RenderedValueTests: TestKitCase
{
    // MARK: - String-like
    
    func testStringValue()
    {
        let value       : String            = "hello"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("hello", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("String", rendered.typeName)
    }
    
    
    
    func testNSStringBridgesToString()
    {
        let value       : NSString          = "hello"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("hello", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("String", rendered.typeName)
    }
    
    
    
    func testSubstringValue()
    {
        let value       : Substring         = "hello".dropLast()
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("hell", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("Substring", rendered.typeName)
    }
    
    
    
    func testCharacterValue()
    {
        let value       : Character         = "a"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("a", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("Character", rendered.typeName)
    }
    
    
    
    func testUnicodeScalarValue()
    {
        let value       : Unicode.Scalar    = "a"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("a", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("Scalar", rendered.typeName)
    }
    
    
    
    // MARK: - Escaping
    
    func testStringWithNewlineEscaped()
    {
        let value       : String            = "line1\nline2"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("line1\\nline2", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("String", rendered.typeName)
    }
    
    
    
    func testStringWithMultipleSpecialCharactersEscaped()
    {
        let value       : String            = "a\\b\"c\nd\te\rf"
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("a\\\\b\\\"c\\nd\\te\\rf", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("String", rendered.typeName)
    }
    
    
    
    // MARK: - CustomDiffStringConvertible
    
    func testCustomDiffStringConvertible()
    {
        struct Custom: CustomDiffStringConvertible
        {
            var diffDescription: String
            {
                return "custom"
            }
        }
        
        let rendered = RenderedValue(Custom())
        
        XCTAssertEqual("custom", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Custom", rendered.typeName)
    }
    
    
    
    func testCustomDiffStringConvertibleWithNewlinesCollapsed()
    {
        struct Custom: CustomDiffStringConvertible
        {
            var diffDescription: String
            {
                return "line1\nline2"
            }
        }
        
        let rendered = RenderedValue(Custom())
        
        /// ``CustomDiffStringConvertible`` output is collapsed, not escaped.
        XCTAssertEqual("line1 line2", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Custom", rendered.typeName)
    }
    
    
    
    // MARK: - RawRepresentable
    
    func testRawRepresentableStructWithStringRawValue()
    {
        struct UserID: RawRepresentable, Equatable
        {
            let rawValue: String
        }
        
        let rendered = RenderedValue(UserID(rawValue: "abc"))
        
        XCTAssertEqual("abc", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("UserID", rendered.typeName)
    }
    
    
    
    func testRawRepresentableStructWithStringRawValueEscaped()
    {
        struct UserID: RawRepresentable, Equatable
        {
            let rawValue: String
        }
        
        let rendered = RenderedValue(UserID(rawValue: "line1\nline2"))
        
        /// String-like raw values are escaped, not collapsed.
        XCTAssertEqual("line1\\nline2", rendered.description)
        XCTAssertEqual(.string, rendered.kind)
        XCTAssertEqual("UserID", rendered.typeName)
    }
    
    
    
    func testRawRepresentableStructWithIntRawValue()
    {
        struct UserID: RawRepresentable, Equatable
        {
            let rawValue: Int
        }
        
        let rendered = RenderedValue(UserID(rawValue: 50))
        
        XCTAssertEqual("50", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("UserID", rendered.typeName)
    }
    
    
    
    func testRawRepresentableEnumNotFlattened()
    {
        enum Color: Int, Equatable
        {
            case red    = 1
            case blue   = 2
        }
        
        let rendered = RenderedValue(Color.blue)
        
        /// Enums are excluded from the `RawRepresentable` leaf path, so the
        /// case name is rendered, not the raw value.
        XCTAssertEqual("blue", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Color", rendered.typeName)
    }
    
    
    
    // MARK: - Fallthrough
    
    func testStructValue()
    {
        struct Point
        {
            let x   : Int
            let y   : Int
        }
        
        let rendered = RenderedValue(Point(x: 1, y: 2))
        
        XCTAssertEqual("Point(x: 1, y: 2)", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Point", rendered.typeName)
    }
    
    
    
    func testStructValueWithNewlinesCollapsed()
    {
        struct Multiline: CustomStringConvertible
        {
            var description: String
            {
                return "line1\nline2"
            }
        }
        
        let rendered = RenderedValue(Multiline())
        
        /// Fallthrough values are collapsed, not escaped.
        XCTAssertEqual("line1 line2", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Multiline", rendered.typeName)
    }
    
    
    
    // MARK: - typeName
    
    func testGenericTypeName()
    {
        let value       : [String]          = ["a", "b"]
        let rendered    : RenderedValue     = .init(value)
        
        XCTAssertEqual("[\"a\", \"b\"]", rendered.description)
        XCTAssertEqual(.other, rendered.kind)
        XCTAssertEqual("Array<String>", rendered.typeName)
    }
}
