//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension UInt64
{
    /// The value formatted as memory.
    ///
    /// `ByteCountFormatStyle.format(_:)` cannot be used since it accepts
    /// only `Int64`.
    internal var readableBytes: String
    {
        let units: [(String, UInt64)] =
        [
            ("GB", 1_073_741_824),
            ("MB", 1_048_576),
            ("KB", 1_024)
        ]
        
        for (suffix, threshold) in units
        {
            guard self >= threshold
            else
            {
                continue
            }
            
            let value   = Double(self) / Double(threshold)
            var result  = String(format: "%.1f", value)
            
            if result.hasSuffix(".0")
            {
                result = String(result.dropLast(2))
            }
            
            return "\(result) \(suffix)"
        }
        
        return "\(self) B"
    }
}
