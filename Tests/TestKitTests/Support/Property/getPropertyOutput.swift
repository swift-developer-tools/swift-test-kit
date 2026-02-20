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



/// Extracts the property-related component of the given output, excluding
/// the embedded assertion failure message.
/// - Parameters:
///   - output: The full property evaluator output.
///   - assertion: The assertion name on which to split the given output.
/// - Returns: The property-related component of the given output.
/// - Throws: An error if the given marker is not found.
internal func getPropertyOutput(
    from    output  : String?,
    before  assertion  : AssertionKind
) throws -> String
{
    guard let output
    else
    {
        XCTFail("Expected non-nil output")
        
        throw TestError()
    }
    
    let marker: String = assertion.name
    
    guard let range: Range<String.Index> = output.range(of: "\n\(marker)")
    else
    {
        XCTFail("Expected marker \"\(marker)\" not found in output")
        
        throw TestError()
    }
    
    return String(output[..<range.lowerBound])
}
