//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax



/// A syntax visitor that collects all type identifier names references with
/// an AST.
package final class TypeSyntaxWalker: SyntaxVisitor
{
    /// The collected type identifier names.
    package private(set) var identifiers: Set<String> = []
    
    
    
    /// Initializes a ``TypeSyntaxWalker`` instance.
    package init()
    {
        super.init(viewMode: .sourceAccurate)
    }
    
    
    
    /// Visits the given node.
    /// - Parameter node: The node to visit.
    /// - Returns: Always `SyntaxVisitorContinueKind.visitChildren`, indicating
    /// that the visitor should visit the descendants of the given node.
    override package func visit(
        _ node: IdentifierTypeSyntax
    ) -> SyntaxVisitorContinueKind
    {
        identifiers.insert(node.name.text)
        
        return .visitChildren
    }
}
