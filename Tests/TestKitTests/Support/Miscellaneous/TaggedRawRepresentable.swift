//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A `String` `RawRepresentable` type with a `let tag: Int` property that
/// is part of its `Equatable` conformance.
internal struct TaggedRawRepresentable: RawRepresentable, Equatable
{
    let rawValue    : String
    let tag         : Int
    
    init?(
        rawValue: String
    )
    {
        self.rawValue   = rawValue
        self.tag        = 0
    }
    
    init(
        rawValue    : String,
        tag         : Int
    )
    {
        self.rawValue   = rawValue
        self.tag        = tag
    }
    
    /// An explicit `==` implementation is required. The standard library
    /// provides a default `==` on `RawRepresentable` types with `Equatable`
    /// raw values that compares only `rawValue` and takes precedence over
    /// `Equatable` synthesis, so the `tag` difference would otherwise be
    /// ignored.
    static func == (
        lhs : TaggedRawRepresentable,
        rhs : TaggedRawRepresentable
    ) -> Bool
    {
        return lhs.rawValue == rhs.rawValue
            && lhs.tag == rhs.tag
    }
}
