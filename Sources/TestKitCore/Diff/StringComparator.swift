//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Computes diffs between strings.
public struct StringComparator
{
    /// The options for computing diffs.
    private let options: TKDiffOptions
    
    
    
    /// Compares the given strings.
    ///
    /// If neither of the given strings contains newlines, this performs a
    /// leaf comparison. Otherwise, it performs line-level and character-level
    /// comparison.
    ///
    /// - Parameters:
    ///   - expected: The expected string.
    ///   - actual: The actual string.
    ///   - options: The diff options to use. The default value is a default-
    ///   initialized ``TKDiffOptions`` instance.
    /// - Returns: The diff node kind.
    public static func compare(
        expected    : String,
        actual      : String,
        options     : TKDiffOptions     = .init()
    ) -> DiffNodeKind
    {
        let comp = StringComparator(options: options)
        
        let normalizedExpected  : String    = comp.normalizeNewlines(expected)
        let normalizedActual    : String    = comp.normalizeNewlines(actual)
        let expectedHasNewline  : Bool      = normalizedExpected.contains("\n")
        let actualHasNewline    : Bool      = normalizedActual.contains("\n")
        
        guard
            expectedHasNewline
            || actualHasNewline
        else
        {
            return comp.compareSingleLine(
                expected:   expected,
                actual:     actual
            )
        }
        
        return comp.compareMultiLine(
            expected:               expected,
            actual:                 actual,
            normalizedExpected:     normalizedExpected,
            normalizedActual:       normalizedActual
        )
    }
    
    
    
    // MARK: - Core comparison
    
    /// Compares the given single-line strings.
    /// - Parameters:
    ///   - expected: The expected string.
    ///   - actual: The actual string.
    /// - Returns: The diff node kind.
    private func compareSingleLine(
        expected    : String,
        actual      : String
    ) -> DiffNodeKind
    {
        guard expected != actual
        else
        {
            return .same
        }
        
        let tree: [DiffNode] = compareCharacters(
            expected:   expected,
            actual:     actual
        )
        
        return .different(
            expected:   DiffValue(expected),
            actual:     DiffValue(actual),
            tree:       tree
        )
    }
    
    
    
    /// Compares the given multi-line strings.
    /// - Parameters:
    ///   - expected: The expected string.
    ///   - actual: The actual string.
    ///   - normalizedExpected: The normalized expected string.
    ///   - normalizedActual: The normalized actual string.
    /// - Returns: The diff node kind.
    private func compareMultiLine(
        expected            : String,
        actual              : String,
        normalizedExpected  : String,
        normalizedActual    : String
    ) -> DiffNodeKind
    {
        let expectedLines   : [String]  = splitIntoLines(normalizedExpected)
        let actualLines     : [String]  = splitIntoLines(normalizedActual)
        
        let tree: [DiffNode] = compareLines(
            expected:   expectedLines,
            actual:     actualLines
        )
        
        guard !tree.isEmpty
        else
        {
            return .same
        }
        
        return .different(
            expected:   DiffValue(normalizedExpected),
            actual:     DiffValue(normalizedActual),
            tree:       tree
        )
    }
    
    
    
    // MARK: - Line comparison
    
    /// Compares the given arrays of lines.
    /// - Parameters:
    ///   - expected: The expected lines.
    ///   - actual: The actual lines.
    /// - Returns: The diff tree.
    private func compareLines(
        expected    : [String],
        actual      : [String]
    ) -> [DiffNode]
    {
        let diff: CollectionDifference<String>
            = actual.difference(from: expected)
        
        var removals    : [Int : String]    = [:]
        var insertions  : [Int : String]    = [:]
        
        for change in diff
        {
            switch change
            {
                case let .remove(offset, _, _):
                    
                    removals[offset] = expected[offset]
                    
                case let .insert(offset, _, _):
                    
                    insertions[offset] = actual[offset]
            }
        }
        
        
        
        let allOffsets: [Int] = Set(removals.keys)
            .union(insertions.keys)
            .sorted()
        
        var tree: [DiffNode] = []
        
        tree.reserveCapacity(allOffsets.count)
        
        for offset in allOffsets
        {
            let kind: DiffNodeKind
            
            let removal     : String?   = removals[offset]
            let insertion   : String?   = insertions[offset]
            
            if
                let removal,
                let insertion
            {
                /// Modified line.
                if removal == insertion
                {
                    continue
                }
                
                let characterNodes: [DiffNode] = compareCharacters(
                    expected:   removal,
                    actual:     insertion
                )
                
                kind = .different(
                    expected:   DiffValue(removal),
                    actual:     DiffValue(insertion),
                    tree:       characterNodes
                )
            }
            else if let removal
            {
                kind = .missing(DiffValue(removal))
            }
            else if let insertion
            {
                kind = .unexpected(DiffValue(insertion))
            }
            else
            {
                continue
            }
            
            
            
            let node = DiffNode(
                label:  .line(offset),
                kind:   kind
            )
            
            tree.append(node)
        }
        
        
        
        return tree
    }
    
    
    
    // MARK: - Character comparison
    
    /// Compares the characters of the given single-line strings.
    /// - Parameters:
    ///   - expected: The expected line.
    ///   - actual: The actual line.
    /// - Returns: The diff tree.
    private func compareCharacters(
        expected    : String,
        actual      : String
    ) -> [DiffNode]
    {
        let diff: CollectionDifference<Character>
            = actual.difference(from: expected)
        
        guard !diff.isEmpty
        else
        {
            return []
        }
        
        
        
        if let threshold: Double = options.characterDiffThreshold
        {
            let unchangedCount: Int = expected.count - diff.removals.count
            
            let maxLength: Int = max(
                expected.count,
                actual.count
            )
            
            guard maxLength > 0
            else
            {
                return []
            }
            
            let unchangedRatio = Double(unchangedCount) / Double(maxLength)
            
            if unchangedRatio < (1.0 - threshold)
            {
                /// Too much has changed. Perform a leaf comparison.
                return []
            }
        }
        
        
        
        return coalesceCharacterChanges(
            of:         diff,
            expected:   expected,
            actual:     actual
        )
    }
    
    
    
    /// Coalesces adjacent character-level changes of the given diff into
    /// ranges.
    ///
    /// This walks both strings in parallel, using the given diff's removal
    /// and insertion offsets as markers. Specifically, this will:
    ///
    /// 1. Build sets of removed offsets (positions in `expected`) and inserted
    /// offsets (positions in `actual`).
    /// 2. Maintain two indices, `expectedIndex` and `actualIndex`.
    /// 3. Skip any characters where neither index is at a marked position,
    /// according to the diff. These characters are unchanged.
    /// 4. When a marked position is found, accumulate consecutive removals
    /// from `expected` and consecutive insertions into `actual`.
    /// 5. Emit a diff node for the coalesced change region. The reported
    /// position is `expectedIndex` (the position in `expected`).
    /// 6. Repeat until both indices reach the end.
    ///
    /// For example, when comparing an expected string `abcdef` against the
    /// actual string `aXXcYYf`:
    ///
    /// - The diff produces: remove `{1, 3, 4}`, insert `{1, 2, 4, 5}`.
    ///
    /// - `e = 0`, `a = 0`: Neither position is marked. The character is
    /// unchanged. Advance each index to `1`.
    ///
    /// - `e = 1`, `a = 1`: Both positions are marked. Accumulate.
    ///     - Removed: `b`, since `e = 1` is marked. Advance to `e = 2`, which
    ///     is not marked. Stop.
    ///     - Inserted: `XX`, since `a = 1` and `a = 2` are marked. Advance to
    ///     `a = 3`, which is not marked. Stop.
    ///     - Emit: position `1`, removed `b`, inserted `XX`.
    ///
    /// - `e = 2`, `a = 3`: Neither position is marked. Advance each index.
    ///
    /// - `e = 3`, `a = 4`: Both positions are marked. Accumulate.
    ///     - Removed: `de`, since `e = 3` and `e = 4` are marked.
    ///     - Inserted: `YY`, since `a = 4` and `a = 5` are marked.
    ///     - Emit: position `3`, removed `de`, inserted `YY`.
    ///
    /// - `e = 5`, `a = 6`: Neither position is marked. Advance each index.
    ///
    /// - `e = 6`, `a = 7`: Done.
    ///
    /// - Parameters:
    ///   - diff: The character-level diff to coalesce.
    ///   - expected: The expected line.
    ///   - actual: The actual line.
    /// - Returns: The coalesced diff tree.
    private func coalesceCharacterChanges(
        of diff     : CollectionDifference<Character>,
        expected    : String,
        actual      : String
    ) -> [DiffNode]
    {
        var removedOffsets  : Set<Int>  = []
        var insertedOffsets : Set<Int>  = []
        
        for change in diff
        {
            switch change
            {
                case let .remove(offset, _, _):
                    
                    removedOffsets.insert(offset)
                    
                case let .insert(offset, _, _):
                    
                    insertedOffsets.insert(offset)
            }
        }
        
        
        
        let expectedChars   : [Character]   = Array(expected)
        let actualChars     : [Character]   = Array(actual)
        var expectedIndex   : Int           = 0
        var actualIndex     : Int           = 0
        var tree            : [DiffNode]    = []
        
        while
            expectedIndex < expectedChars.count
            || actualIndex < actualChars.count
        {
            while
                expectedIndex < expectedChars.count,
                actualIndex < actualChars.count,
                !removedOffsets.contains(expectedIndex),
                !insertedOffsets.contains(actualIndex)
            {
                /// Skip unchanged characters.
                expectedIndex   += 1
                actualIndex     += 1
            }
            
            if
                expectedIndex >= expectedChars.count,
                actualIndex >= actualChars.count
            {
                break
            }
            
            
            
            let changePosition  : Int           = expectedIndex
            var removedChars    : [Character]   = []
            var insertedChars   : [Character]   = []
            
            while
                expectedIndex < expectedChars.count,
                removedOffsets.contains(expectedIndex)
            {
                removedChars.append(expectedChars[expectedIndex])
                
                expectedIndex += 1
            }
            
            while
                actualIndex < actualChars.count,
                insertedOffsets.contains(actualIndex)
            {
                insertedChars.append(actualChars[actualIndex])
                
                actualIndex += 1
            }
            
            
            
            let count   : Int
            let kind    : DiffNodeKind
            
            if
                !removedChars.isEmpty,
                !insertedChars.isEmpty
            {
                count = removedChars.count
                
                kind = .different(
                    expected:   DiffValue(String(removedChars)),
                    actual:     DiffValue(String(insertedChars)),
                    tree:       []
                )
            }
            else if !removedChars.isEmpty
            {
                count   = removedChars.count
                kind    = .missing(DiffValue(String(removedChars)))
            }
            else if !insertedChars.isEmpty
            {
                count   = insertedChars.count
                kind    = .unexpected(DiffValue(String(insertedChars)))
            }
            else
            {
                /// Guard against an infinite loop. This branch should not be
                /// reachable if `CollectionDifference` is well-formed.
                if expectedIndex < expectedChars.count
                {
                    expectedIndex += 1
                }
                
                if actualIndex < actualChars.count
                {
                    actualIndex += 1
                }
                
                continue
            }
            
            
            
            let label = DiffNodeLabel.character(
                index:  changePosition,
                count:  count
            )
            
            let node = DiffNode(
                label:  label,
                kind:   kind
            )
            
            tree.append(node)
        }
        
        
        
        return tree
    }
    
    
    
    // MARK: - Support
    
    /// Normalizes all newlines to be `\n`.
    /// - Parameter string: The string to normalize.
    /// - Returns: The normalized string.
    private func normalizeNewlines(
        _ string: String
    ) -> String
    {
        return string
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }
    
    
    
    /// Splits the given string into lines.
    ///
    /// - Note: This preserves trailing empty lines. For example, the string
    /// `a\nb\n` produces `["a", "b", ""]`. Trailing empty lines are preserved
    /// since they are often meaningful (for example, in Git).
    ///
    /// - Parameter string: The string to split.
    /// - Returns: The lines.
    private func splitIntoLines(
        _ string: String
    ) -> [String]
    {
        return string.components(separatedBy: "\n")
    }
}
