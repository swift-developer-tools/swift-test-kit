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



// MARK: - BoundInt

/// A wrapper around `Int` that provides controllable shrinking.
///
/// This is different from `Int: Arbitrary` since `Int.arbitrary(using:)`
/// generates values in the range `-context.size...context.size`, which
/// makes it harder to reason about value distributions in tests. This
/// wrapper always generates values in the range `0...context.size`.
internal struct BoundInt: Arbitrary, Equatable, CustomStringConvertible
{
    let value: Int
    
    init(
        _ value: Int
    )
    {
        self.value = value
    }
    
    var description: String
    {
        return "BoundInt: \(value)"
    }
    
    static func arbitrary(
        using context: GenerationContext
    ) -> BoundInt
    {
        return BoundInt(context.random(in: 0...max(1, context.size)))
    }
    
    func shrink() -> [BoundInt]
    {
        return value.shrinkTowardZero().map { BoundInt($0) }
    }
}



// MARK: - BoundIntNoShrink

/// A wrapper around `Int` that does not shrink.
///
/// See ``BoundInt`` for more information regarding the range of values.
internal struct BoundIntNoShrink:
    Arbitrary, Equatable, CustomStringConvertible
{
    let value: Int
    
    var description: String
    {
        return "BoundIntNoShrink - \(value)"
    }
    
    static func arbitrary(
        using context: GenerationContext
    ) -> BoundIntNoShrink
    {
        return BoundIntNoShrink(value:
            context.random(in: 0...max(1, context.size))
        )
    }
}



// MARK: - SizeCapture

/// Captures the generation size directly for testing size progression.
internal struct SizeCapture: Arbitrary, Equatable
{
    let size: Int
    
    static func arbitrary(
        using context: GenerationContext
    ) -> SizeCapture
    {
        return SizeCapture(size: context.size)
    }
}
