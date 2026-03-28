//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// An unmet coverage requirement.
internal struct UnmetCoverage: Equatable, Sendable
{
    /// The label that did not meet its coverage requirement.
    internal let label      : String
    
    /// The required percentage in the range `0...100`.
    internal let required   : Double
    
    /// The actual percentage achieved.
    internal let actual     : Double
    
    /// The table name, if the requirement came from a tabulated
    /// classifiction, or `nil` otherwise.
    internal let table      : String?
    
    
    
    /// Initializes an ``UnmetCoverage`` instance from the given values.
    ///
    /// ``required`` is clamped to the range `0.0...100.0`
    internal init(
        label       : String,
        required    : Double,
        actual      : Double,
        table       : String?
    )
    {
        self.label      = label
        self.required   = required.clamped(to: 0.0...100.0)
        self.actual     = actual
        self.table      = table
    }
}
