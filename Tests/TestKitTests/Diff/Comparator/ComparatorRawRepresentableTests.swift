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



internal final class ComparatorRawRepresentableTests: TestKitCase
{
    // MARK: - Struct
    
    func testStructEqualValues()
    {
        struct UserID: RawRepresentable, Equatable
        {
            let rawValue: Int
        }
        
        let exp = UserID(rawValue: 50)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     exp,
            options:    .init()
        )
        
        let expected = DiffNode(
            label:  .root(typeName: typeName(of: exp)),
            kind:   .same
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStructDifferentValues()
    {
        struct UserID: RawRepresentable, Equatable
        {
            let rawValue: Int
        }
        
        let exp = UserID(rawValue: 50)
        let act = UserID(rawValue: 99)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStructWithUnequalEquatableSameRawValue()
    {
        let exp     = TaggedRawRepresentable(rawValue: "x", tag: 1)
        let act     = TaggedRawRepresentable(rawValue: "x", tag: 2)
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
        
        guard case let .different(expRendered, actRendered, _) = actual.kind
        else
        {
            XCTFail("Expected .different, got \(actual.kind)")
            return
        }
        
        XCTAssertEqual("x", expRendered.rendered.description)
        XCTAssertEqual("x", actRendered.rendered.description)
    }
    
    
    
    // MARK: - Class
    
    func testClassDifferentValues()
    {
        final class Token: RawRepresentable, Equatable
        {
            let rawValue: String
            
            init(
                rawValue: String
            )
            {
                self.rawValue = rawValue
            }
            
            static func == (
                lhs : Token,
                rhs : Token
            ) -> Bool
            {
                return lhs.rawValue == rhs.rawValue
            }
        }
        
        let exp     = Token(rawValue: "abc")
        let act     = Token(rawValue: "xyz")
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Enum
    
    func testEnumNotFlattenedToRawValue()
    {
        enum Color: Int, Equatable
        {
            case red    = 1
            case blue   = 2
        }
        
        let exp : Color     = .red
        let act : Color     = .blue
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:       []
        )
        
        XCTAssertEqual(expected, actual)
        
        guard case let .different(expRendered, actRendered, _) = actual.kind
        else
        {
            XCTFail("Expected .different, got \(actual.kind)")
            return
        }
        
        XCTAssertEqual("red", expRendered.rendered.description)
        XCTAssertEqual("blue", actRendered.rendered.description)
    }
}
