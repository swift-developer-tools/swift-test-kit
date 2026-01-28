//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKitCore



// MARK: - FormattedLine

/// A formatted diff line.
internal struct FormattedLine
{
    /// The indentation level.
    let indent  : Int
    
    /// The text content.
    let text    : String
}



// MARK: - Formatter

/// Formats diffs.
///
/// ## Truncation
///
/// Paths are truncated in the middle of the line by ``emitPath()``.
/// Values are truncated at the end of the line by ``renderText(_:)``.
///
/// Both truncation methods can produce visually imperfect output in certain
/// cases. For example:
///
/// - Paths: `.l2.l3.l4.l....l9.l10.val` has four consecutive dots, since
/// the split occured at a segment boundary (truncating `l5`).
/// - Arrays: `[1, 2, 3, 4, 5, 6...]` is missing a closing bracket.
/// - Nested structures: May contain unbalanced delimiters.
///
/// Potential improvements were considered, including:
///
/// - Backing up to segment boundaries for paths. This requires arbitrary
/// backtracking limits, and does not help when segments are long.
/// - Appending closing delimiters for collections. This requires tracking
/// nesting depth across braces, brackets, parentheses, and quotes.
///
/// A comprehensive solution would require a Swift expression parser, but
/// this adds disproportionate complexity and benefits only truncation.
///
/// Currently, a closing quote is added to truncated strings by
/// ``renderText(_:)``, since that implementation is trivial. Other
/// behavior is acceptable and may be avoided by increasing the limit
/// specified by ``XCTKFormatOptions/maxLineLength``.
internal struct Formatter
{
    /// The context for tracking state across recursive formatting calls.
    private let context: FormatterContext
    
    
    
    /// Formats the given root diff node into a string.
    /// - Parameters:
    ///   - node: The root diff node to format.
    ///   - options: The formatting options to use. The default value is a
    ///   default-initialized ``XCTKFormatOptions`` instance.
    /// - Returns: The formatting string.
    static func format(
        _ node  : DiffNode,
        options : XCTKFormatOptions     = .init()
    ) -> String
    {
        let context = FormatterContext(
            node:       node,
            options:    options
        )
        
        let formatter = Formatter(context: context)
        
        formatter.visit(node)
        formatter.emitTruncationMessage()
        
        return formatter.render()
    }
    
    
    
    /// Formats the decomposition of a boolean expression.
    /// - Parameters:
    ///   - exprText: The expression source text.
    ///   - evaluated: The evaluated boolean expressions.
    ///   - notEvaluated: The number of unevaluated boolean expressions.
    ///   - expectedValue: The value expected by the assertion.
    ///   - options: The formatting options to use. The default value is a
    ///   default-initialized ``XCTKFormatOptions`` instance.
    /// - Returns: The formatted decomposition.
    static func formatBooleanExpr(
        exprText        : String,
        evaluated       : [XCTKBooleanExpr],
        notEvaluated    : Int,
        expectedValue   : Bool,
        options         : XCTKFormatOptions     = .init()
    ) -> String
    {
        let exprsToShow: [XCTKBooleanExpr] = options.showAllEvaluated
            ? evaluated
            : evaluated.filter { $0.value != expectedValue }
        
        let totalDiffCount: Int? = options.countDiffs
            ? exprsToShow.count
            : nil
        
        let context = FormatterContext(
            options:            options,
            totalDiffCount:     totalDiffCount
        )
        
        let formatter = Formatter(context: context)
        
        formatter.emitBooleanDecomposition(
            exprText:       exprText,
            exprsToShow:    exprsToShow,
            notEvaluated:   notEvaluated,
            expectedValue:  expectedValue
        )
        
        return formatter.render()
    }
    
    
    
    // MARK: - Core
    
    /// Visits the given node, accumulating the path and emitting output at
    /// leaf nodes.
    /// - Parameter node: The node to visit.
    private func visit(
        _ node: DiffNode
    )
    {
        let isRoot: Bool = node.label.isRoot
        
        if !isRoot
        {
            guard !context.isAtMaxDiffs
            else
            {
                context.isTruncated = true
                return
            }
            
            context.currentPath.append(node.label)
        }
        
        defer
        {
            if !isRoot
            {
                context.currentPath.removeLast()
            }
        }
        
        
        
        switch node.kind
        {
            case let .cycle(_, _, location):
                
                emitCycle(at: location)
                
            case .same:
                
                break
                
            case let .different(exp, act, tree):
                
                if
                    node.label.isLine,
                    !tree.isEmpty
                {
                    emitLineDiff(
                        expected:       exp,
                        actual:         act,
                        characterTree:  tree
                    )
                }
                else if tree.isEmpty
                {
                    emitDifferent(
                        expected:   exp,
                        actual:     act
                    )
                }
                else
                {
                    if isRoot
                    {
                        emitHeader(
                            typeName:   exp.rendered.typeName,
                            isSetTree:  tree.isSetTree
                        )
                    }
                    
                    if tree.isSetTree
                    {
                        emitSetDiff(tree: tree)
                    }
                    else
                    {
                        for node in tree
                        {
                            visit(node)
                        }
                    }
                }
                
            case let .missing(exp):
                
                emitMissing(exp)
                
            case let .unexpected(act):
                
                emitUnexpected(act)
        }
    }
    
    
    
    /// Renders the formatted lines into the final string.
    /// - Returns: The rendered string.
    private func render() -> String
    {
        var lines: [String] = []
        
        lines.reserveCapacity(context.lines.count)
        
        for line in context.lines
        {
            if line.text.isEmpty
            {
                lines.append("")
            }
            else
            {
                let indent: String = String(
                    repeating:  " ",
                    count:      line.indent * context.options.indentationSpaces
                )
                
                lines.append("\(indent)\(line.text)")
            }
        }
        
        while lines.last == ""
        {
            /// Remove trailing empty lines.
            lines.removeLast()
        }
        
        return lines.joined(separator: "\n")
    }
    
    
    
    /// Renders the given value for display.
    /// - Parameter rendered: The value to render for display.
    /// - Returns: The rendered string.
    private func renderText(
        _ rendered: RenderedValue
    ) -> String
    {
        let displayText: String = Self.truncateText(
            rendered.description,
            maxLength: computeAvailableWidth()
        )
        
        return rendered.kind == .string
            ? quote(displayText)
            : displayText
    }
    
    
    
    // MARK: - Emission
    
    /// Emits a line with the given indentation level and text content.
    /// - Parameters:
    ///   - text: The text content to use.
    ///   - indent: The indentation level to use. Defaults to the current
    ///   indentation level.
    private func emitLine(
        _   text    : String,
        _   indent  : Int?      = nil
    )
    {
        let line = FormattedLine(
            indent:     indent ?? context.currentIndent,
            text:       text
        )
        
        context.lines.append(line)
    }
    
    
    
    /// Emits a blank line.
    ///
    /// This calls ``emitLine(_:_:)`` with an empty string as the text content
    /// and an indentation level of `0`. These will be converted to newline
    /// characters in ``render()`` when the string components are joined.
    private func emitBlankLine()
    {
        emitLine("", 0)
    }
    
    
    
    /// Builds a path string from the current path, and emits it as a line if
    /// it is not empty.
    ///
    /// This rebuilds the entire path from ``FormatterContext/currentPath``.
    /// An incremental approach could maintain a running path string, appending
    /// segments on descent and removing segments on ascent. However, this is
    /// not necessarily more efficient.
    ///
    /// `String` is UTF-8 backed with grapheme cluster indexing, so truncation
    /// operations like `prefix(_:)` and `dropLast(_:)` require traversing the
    /// length of the string. Similarly, maintaining an array of path segments
    /// and calling `joined()` when emitting still requires traversal, while
    /// also adding state synchronization complexity.
    ///
    /// Since path depth is generally not excessive (and is potentially
    /// limited by ``XCTKDiffOptions/maxRecursionDepth``), and this method is
    /// called only once per leaf, the simpler approach is preferred.
    ///
    /// - Returns: The indentation level of the path, or `0` if it is empty.
    @discardableResult
    private func emitPath() -> Int
    {
        var path: String = ""
        
        for label in context.currentPath
        {
            switch label
            {
                case
                    .root,
                    .member:
                    
                    continue
                    
                case let .property(name):
                    
                    path += ".\(name)"
                    
                case let .index(index):
                    
                    path += "[\(index)]"
                    
                case let .key(description, _):
                    
                    path += "[\(quote(description))]"
                    
                case let .line(index):
                    
                    if !path.isEmpty
                    {
                        path += ", "
                    }
                    
                    path += "line \(index + 1)"
                    
                case let .character(index, count):
                    
                    if !path.isEmpty
                    {
                        path += ", "
                    }
                    
                    if count == 1
                    {
                        path += "character \(index + 1)"
                    }
                    else
                    {
                        path += "characters \(index + 1)-\(index + count)"
                    }
            }
        }
        
        
        
        let indent: Int = path.isEmpty ? 0 : 2
        
        context.currentIndent = indent
        
        guard !path.isEmpty
        else
        {
            return indent
        }
        
        
        
        /// The path is emitted with one level of indentation and no label.
        /// Compute the available width to potentially truncate the path if
        /// it exceeds ``XCTKFormatOptions/maxLineLength``.
        let availableWidth: Int = computeAvailableWidth(
            indent:         1,
            labelWidth:     0
        )
        
        if path.count > availableWidth
        {
            /// Middle-truncate the path, since the end of the path provides
            /// useful information. Subtract 3 to account for the ellipsis.
            let half    : Int       = (availableWidth - 3) / 2
            let start   : String    = String(path.prefix(half))
            let end     : String    = String(path.suffix(half))
            
            path = "\(start)...\(end)"
        }
        
        emitLine(path, 1)
        
        return indent
    }
    
    
    
    /// Emits the diff header for structural diffs.
    /// - Parameter typeName: The type name to include in the header.
    private func emitHeader(
        typeName    : String,
        isSetTree   : Bool
    )
    {
        emitLine("\(typeName) differs\(isSetTree ? ":" : " at:")", 0)
        emitBlankLine()
    }
    
    
    
    /// Emits a cycle indicator.
    /// - Parameter location: The location where the cycle was detected.
    private func emitCycle(
        at location: CycleLocation
    )
    {
        emitPath()
        emitLine(location.description)
        emitBlankLine()
        
        context.emittedDiffCount += 1
    }
    
    
    
    /// Emits an Expected/Actual pair for leaf differences.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    private func emitDifferent(
        expected    : DiffValue,
        actual      : DiffValue
    )
    {
        emitPath()
        emitLine(makeLabel(.expected, renderText(expected.rendered)))
        emitLine(makeLabel(.actual, renderText(actual.rendered)))
        emitBlankLine()
        
        context.emittedDiffCount += 1
    }
    
    
    
    /// Emits a Missing line.
    /// - Parameter missing: The missing value.
    private func emitMissing(
        _ missing: DiffValue
    )
    {
        emitPath()
        emitLine(makeLabel(.missing, renderText(missing.rendered)))
        emitBlankLine()
        
        context.emittedDiffCount += 1
    }
    
    
    
    /// Emits an Unexpected line.
    /// - Parameter unexpected: The unexpected value.
    private func emitUnexpected(
        _ unexpected: DiffValue
    )
    {
        emitPath()
        emitLine(makeLabel(.unexpected, renderText(unexpected.rendered)))
        emitBlankLine()
        
        context.emittedDiffCount += 1
    }
    
    
    
    /// Emits a line diff with inline character summary.
    /// - Parameters:
    ///   - expected: The expected value.
    ///   - actual: The actual value.
    ///   - characterTree: The character-level diff tree.
    private func emitLineDiff(
        expected        : DiffValue,
        actual          : DiffValue,
        characterTree   : [DiffNode]
    )
    {
        emitPath()
        emitLine(makeLabel(.expected, renderText(expected.rendered)))
        emitLine(makeLabel(.actual, renderText(actual.rendered)))
        
        
        
        for node in characterTree
        {
            guard case let .character(index, count) = node.label
            else
            {
                continue
            }
            
            var position: String = count == 1
                ? "character \(index + 1)"
                : "characters \(index + 1)-\(index + count)"
            
            switch node.kind
            {
                case
                    .cycle,
                    .same:
                    
                    break
                    
                case let .different(charExp, charAct, _):
                    
                    let exp     : String    = renderText(charExp.rendered)
                    let act     : String    = renderText(charAct.rendered)
                    let text    : String    = "\(position) (\(exp) → \(act))"
                    
                    emitLine(makeLabel(.changed, text))
                    
                case let .missing(charExp):
                    
                    let exp     : String    = renderText(charExp.rendered)
                    let text    : String    = "\(position) \(exp)"
                    
                    emitLine(makeLabel(.missing, text))
                    
                case let .unexpected(charAct):
                    
                    if count != 1
                    {
                        position
                            = "\(count) characters at position \(index + 1)"
                    }
                    
                    let act     : String    = renderText(charAct.rendered)
                    let text    : String    = "\(position) \(act)"
                    
                    emitLine(makeLabel(.unexpected, text))
            }
        }
        
        
        
        emitBlankLine()
        
        context.emittedDiffCount += 1
    }
    
    
    
    /// Emits a set diff.
    /// - Parameter tree: The set tree.
    private func emitSetDiff(
        tree: [DiffNode]
    )
    {
        /// Root-level set members need at least one level of indentation.
        context.currentIndent = max(emitPath(), 1)
        
        for node in tree
        {
            guard !context.isAtMaxDiffs
            else
            {
                context.isTruncated = true
                
                break
            }
            
            switch node.kind
            {
                case
                    .cycle,
                    .same,
                    .different:
                    
                    break
                    
                case let .missing(exp):
                    
                    emitLine(makeLabel(.missing, renderText(exp.rendered)))
                    
                    context.emittedDiffCount += 1
                    
                case let .unexpected(act):
                    
                    emitLine(makeLabel(.unexpected, renderText(act.rendered)))
                    
                    context.emittedDiffCount += 1
            }
        }
        
        emitBlankLine()
    }
    
    
    
    /// Emits a message if a diff was truncated.
    /// - Parameter forBooleanDecomposition: Whether the truncation message is
    /// for boolean decomposition.
    private func emitTruncationMessage(
        forBooleanDecomposition: Bool = false
    )
    {
        guard context.isTruncated
        else
        {
            return
        }
        
        
        
        let noun: String = forBooleanDecomposition
            ? "expression"
            : "difference"
        
        let message: String
        
        if let totalDiffCount: Int = context.totalDiffCount
        {
            let remaining: Int = totalDiffCount - context.emittedDiffCount
            
            message = "... and \(remaining) more"
                    + " \(noun)\(remaining == 1 ? "" : "s")"
        }
        else if let maxDiffs: Int = context.options.maxDiffs
        {
            message = "... and more \(noun)s (limit: \(maxDiffs))"
        }
        else
        {
            message = "... and more \(noun)s"
        }
        
        
        
        if forBooleanDecomposition
        {
            emitBlankLine()
        }
        
        emitLine(message, 1)
    }
    
    
    
    /// Emits a decomposed boolean expression.
    /// - Parameters:
    ///   - exprText: The expression source text.
    ///   - exprsToShow: The boolean expressions to show in the output.
    ///   - notEvaluated: The number of unevaluated boolean expressions.
    ///   - expectedValue: The expression value expected for the boolean
    ///   assertion to succeed.
    private func emitBooleanDecomposition(
        exprText        : String,
        exprsToShow     : [XCTKBooleanExpr],
        notEvaluated    : Int,
        expectedValue   : Bool
    )
    {
        let headerPrefix: String = "Expression: "
        
        let availableWidth: Int = computeAvailableWidth(
            indent:         0,
            labelWidth:     headerPrefix.count
        )
        
        let truncatedExprText: String = Self.truncateText(
            exprText,
            maxLength: availableWidth
        )
        
        emitLine("\(headerPrefix)\(truncatedExprText)", 0)
        emitBlankLine()
        
        
        
        let limit: Int = context.options.maxDiffs ?? exprsToShow.count
        
        for expr in exprsToShow.prefix(limit)
        {
            let marker  : String    = expr.value != expectedValue ? " ←" : ""
            let suffix  : String    = " = \(expr.value)\(marker)"
            
            let availableWidth: Int = computeAvailableWidth(
                indent:         1,
                labelWidth:     suffix.count
            )
            
            let truncatedText: String = Self.truncateText(
                expr.text,
                maxLength: availableWidth
            )
            
            emitLine("\(truncatedText)\(suffix)", 1)
            
            context.emittedDiffCount += 1
        }
        
        
        
        if exprsToShow.count > limit
        {
            context.isTruncated = true
        }
        
        emitTruncationMessage(forBooleanDecomposition: true)
        
        
        
        if
            context.options.showNotEvaluatedCount,
            notEvaluated > 0
        {
            emitBlankLine()
            
            let noun: String = notEvaluated == 1
                ? "expression"
                : "expressions"
            
            emitLine("(\(notEvaluated) \(noun) not evaluated)", 1)
        }
    }
    
    
    
    // MARK: - Support
    
    /// The label kind.
    enum LabelKind: String, CaseIterable
    {
        case expected       = "Expected:   "
        case actual         = "Actual:     "
        case changed        = "Changed:    "
        case missing        = "Missing:    "
        case unexpected     = "Unexpected: "
        
        
        
        /// The length of each label.
        ///
        /// Labels use trailing padding to align the labeled content, so
        /// all labels have the same number of characters.
        static let length: Int =
        {
            let lengths: [Int] = LabelKind.allCases.map { $0.rawValue.count }
            
            precondition(
                lengths.allSatisfy { $0 == lengths[0] },
                "All LabelKind cases must have equal length for alignment"
            )
            
            return lengths[0]
        }()
    }
    
    
    
    /// Creates a label from the given label kind and value.
    /// - Parameters:
    ///   - kind: The label kind to use.
    ///   - text: The text content to use.
    /// - Returns: The created label.
    private func makeLabel(
        _   kind    : LabelKind,
        _   text    : String
    ) -> String
    {
        return "\(kind.rawValue)\(text)"
    }
    
    
    
    /// Computes the available width for the non-label text content of line.
    /// - Parameters:
    ///   - indent: The indentation level of the line. Defaults to
    ///   ``FormatterContext/currentIndent``.
    ///   - labelWidth: The label length. Defaults to ``LabelKind/length``.
    /// - Returns: The available width for the non-label text content of line,
    /// with a minimum of `20` characters to ensure readable values.
    private func computeAvailableWidth(
        indent      : Int?  = nil,
        labelWidth  : Int   = LabelKind.length
    ) -> Int
    {
        let indentWidth: Int =
            (indent ?? context.currentIndent)
            * context.options.indentationSpaces
        
        let availableWidth: Int =
            context.options.maxLineLength
            - indentWidth
            - labelWidth
        
        return max(availableWidth, 20)
    }
    
    
    
    /// Truncates the given text to the given maximum length.
    /// - Parameters:
    ///   - text: The text to truncate.
    ///   - maxLength: The maximum length.
    /// - Returns: The truncated text, or the original text if no truncation
    /// is needed.
    private static func truncateText(
        _ text      : String,
        maxLength   : Int
    ) -> String
    {
        guard text.count > maxLength
        else
        {
            return text
        }
        
        var result: String = text
        
        /// Subtract 3 to account for the ellipsis.
        let endIndex: String.Index = result.index(
            result.startIndex,
            offsetBy: maxLength - 3
        )
        
        result = String(result[..<endIndex]) + "..."
        
        return result
    }
}
