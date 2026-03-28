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



internal final class ComparatorCustomDiffTests: TestKitCase
{
    func testCustomReprEqualValues()
    {
        let exp = Config(
            name:           "a",
            timeout:        30,
            internalID:     100
        )
        
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
    
    
    
    func testCustomReprSinglePropertyDifference()
    {
        let exp = Config(
            name:           "a",
            timeout:        30,
            internalID:     100
        )
        
        let act = Config(
            name:           "a",
            timeout:        99,
            internalID:     100
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "timeout"),
                    expected:   exp.timeout,
                    actual:     act.timeout
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprExcludesProperty()
    {
        let exp = Config(
            name:           "a",
            timeout:        30,
            internalID:     100
        )
        
        let act = Config(
            name:           "a",
            timeout:        30,
            internalID:     999
        )
        
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
    
    
    
    func testCustomReprMissingProperty()
    {
        let exp = Connection(
            host:   "abc",
            port:   123,
            error:  "timeout"
        )
        
        let act = Connection(
            host:   "abc",
            port:   123,
            error:  nil
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeMissing(
                    label:      .property(name: "error"),
                    expected:   exp.error!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprUnexpectedProperty()
    {
        let exp = Connection(
            host:   "abc",
            port:   123,
            error:  nil
        )
        
        let act = Connection(
            host:   "abc",
            port:   123,
            error:  "timeout"
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeUnexpected(
                    label:      .property(name: "error"),
                    actual:     act.error!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprMixedChanges()
    {
        let exp = Endpoint(
            host:   "abc",
            port:   123,
            error:  "timeout",
            retry:  nil
        )
        
        let act = Endpoint(
            host:   "abc",
            port:   999,
            error:  nil,
            retry:  777
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "port"),
                    expected:   exp.port,
                    actual:     act.port
                ),
                
                .makeMissing(
                    label:      .property(name: "error"),
                    expected:   exp.error!
                ),
                
                .makeUnexpected(
                    label:      .property(name: "retry"),
                    actual:     act.retry!
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprEmptyRepresentation()
    {
        struct Token: Equatable, CustomDiffRepresentable
        {
            let secret: String
            
            var diffRepresentation: DiffRepresentation
            {
                return DiffRepresentation([])
            }
        }
        
        let exp     = Token(secret: "abc")
        let act     = Token(secret: "xyz")
        
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
    
    
    
    func testCustomReprNested()
    {
        struct Wrapper: Equatable
        {
            let label   : String
            let config  : Config
        }
        
        let expConfig = Config(
            name:           "a",
            timeout:        30,
            internalID:     100
        )
        
        let actConfig = Config(
            name:           "a",
            timeout:        99,
            internalID:     100
        )
        
        let exp = Wrapper(
            label:      "abc",
            config:     expConfig
        )
        
        let act = Wrapper(
            label:      "abc",
            config:     actConfig
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "config"),
                    expected:   exp.config,
                    actual:     act.config,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "timeout"),
                            expected:   exp.config.timeout,
                            actual:     act.config.timeout
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprPropertyOrderIndependence()
    {
        struct FlippedOrder: Equatable, CustomDiffRepresentable
        {
            let a       : Int
            let b       : Int
            let flip    : Bool
            
            var diffRepresentation: DiffRepresentation
            {
                if flip
                {
                    return DiffRepresentation([
                        .init("b", b),
                        .init("a", a)
                    ])
                }
                
                return DiffRepresentation([
                    .init("a", a),
                    .init("b", b)
                ])
            }
        }
        
        let exp = FlippedOrder(
            a:      1,
            b:      2,
            flip:   false
        )
        
        let act = FlippedOrder(
            a:      1,
            b:      999,
            flip:   true
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "b"),
                    expected:   exp.b,
                    actual:     act.b
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCustomReprAtDepthLimit()
    {
        struct Outer: Equatable
        {
            let config: Config
        }
        
        let exp = Outer(config: Config(
            name:           "a",
            timeout:        30,
            internalID:     100
        ))
        
        let act = Outer(config: Config(
            name:           "b",
            timeout:        99,
            internalID:     777
        ))
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init(maxRecursionDepth: 1)
        )
        
        /// At a depth of `1`, the depth limit is reached before the custom
        /// conformance of the `Config` type is checked. The `config` property
        /// is compared by string representation, producing a leaf node with
        /// no children.
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "config"),
                    expected:   exp.config,
                    actual:     act.config
                )
            ]
        )
        
        TKAssertEqual(expected, actual)
    }
    
    
    
    func testCustomDiffStringConvertibleRendering()
    {
        struct Container: Equatable
        {
            let origin  : Point
            let target  : Point
        }
        
        let exp = Container(
            origin:     Point(x: 40.0, y: -50.0),
            target:     Point(x: 55.0, y: -0.25)
        )
        
        let act = Container(
            origin:     Point(x: 40.0, y: -50.0),
            target:     Point(x: 99.9, y: 7.77)
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeStructural(
                    label:      .property(name: "target"),
                    expected:   exp.target,
                    actual:     act.target,
                    tree:
                    [
                        .makeLeaf(
                            label:      .property(name: "x"),
                            expected:   exp.target.x,
                            actual:     act.target.x
                        ),
                        
                        .makeLeaf(
                            label:      .property(name: "y"),
                            expected:   exp.target.y,
                            actual:     act.target.y
                        )
                    ]
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
        
        let rendered = RenderedValue(exp.target)
        
        XCTAssertEqual(rendered.description, "(55.0, -0.25)")
        XCTAssertEqual(rendered.kind, .other)
    }
    
    
    
    func testBothProtocols()
    {
        struct Metric:
            Equatable, CustomDiffRepresentable, CustomDiffStringConvertible
        {
            let name        : String
            let value       : Double
            let timestamp   : Int
            
            var diffRepresentation: DiffRepresentation
            {
                return DiffRepresentation([
                    .init("name", name),
                    .init("value", value)
                ])
            }
            
            var diffDescription: String
            {
                return "\(name)=\(value)"
            }
        }
        
        let exp = Metric(
            name:       "abc",
            value:      0.5,
            timestamp:  1000
        )
        
        let act = Metric(
            name:       "abc",
            value:      99.9,
            timestamp:  7777
        )
        
        let actual: DiffNode = Comparator.computeDiff(
            expected:   exp,
            actual:     act,
            options:    .init()
        )
        
        let expected = DiffNode.makeRoot(
            typeName:   typeName(of: exp),
            expected:   exp,
            actual:     act,
            tree:
            [
                .makeLeaf(
                    label:      .property(name: "value"),
                    expected:   exp.value,
                    actual:     act.value
                )
            ]
        )
        
        XCTAssertEqual(expected, actual)
        
        let rendered = RenderedValue(exp)
        
        XCTAssertEqual(rendered.description, "abc=0.5")
        XCTAssertEqual(rendered.kind, .other)
    }
}



// MARK: - Support

private struct Config: Equatable, CustomDiffRepresentable
{
    let name        : String
    let timeout     : Int
    let internalID  : Int
    
    var diffRepresentation: DiffRepresentation
    {
        return DiffRepresentation([
            .init("name", name),
            .init("timeout", timeout)
        ])
    }
}



private struct Connection: Equatable, CustomDiffRepresentable
{
    let host    : String
    let port    : Int
    let error   : String?
    
    var diffRepresentation: DiffRepresentation
    {
        var properties: [DiffRepresentation.Property] =
        [
            .init("host", host),
            .init("post", port)
        ]
        
        if let error
        {
            properties.append(.init("error", error))
        }
        
        return DiffRepresentation(properties)
    }
}



private struct Endpoint: Equatable, CustomDiffRepresentable
{
    let host    : String
    let port    : Int
    let error   : String?
    let retry   : Int?
    
    var diffRepresentation: DiffRepresentation
    {
        var properties: [DiffRepresentation.Property] =
        [
            .init("host", host),
            .init("port", port)
        ]
        
        if let error
        {
            properties.append(.init("error", error))
        }
        
        if let retry
        {
            properties.append(.init("retry", retry))
        }
        
        return DiffRepresentation(properties)
    }
}



private struct Point: Equatable, CustomDiffStringConvertible
{
    let x   : Double
    let y   : Double
    
    var diffDescription: String
    {
        return "(\(x), \(y))"
    }
}
