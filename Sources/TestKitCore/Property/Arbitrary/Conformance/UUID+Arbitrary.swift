//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension UUID: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary RFC 4122 v4 UUID.
    public static func arbitrary(
        using context: GenerationContext
    ) -> UUID
    {
        var bytes: (
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8
        ) = (
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context),
            .arbitrary(using: context), .arbitrary(using: context)
        )
        
        bytes.6 = (bytes.6 & 0x0F) | 0x40 /// Version 4.
        bytes.8 = (bytes.8 & 0x3F) | 0x80 /// Variant 1.
        
        return UUID(uuid: bytes)
    }
    
    
    
    /// UUID uses the default shrinking implementation of returning an empty
    /// array to indicate that no shrinking should occur. UUIDs are opaque
    /// identifiers without meaningful ordering. The method is not implemented
    /// here to silence the duplication warning.
}
