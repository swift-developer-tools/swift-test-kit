//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension String
{
    /// The string with newlines collapsed to a single space.
    package func collapseLines() -> String
    {
        return self
            .replacingOccurrences(of: "\r\n",   with: " ")
            .replacingOccurrences(of: "\n",     with: " ")
            .replacingOccurrences(of: "\r",     with: " ")
    }
}
