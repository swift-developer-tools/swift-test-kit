//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxMacros



// MARK: Generation

/// Arbitrary generation method kinds.
internal enum EnumGenerationKind
{
    /// Generate for ``Arbitrary/arbitrary(using:)``.
    case arbitrary
    
    /// Generate for ``Stateful/arbitrary(using:model:)``, without weights.
    case statefulWeightless
    
    /// Generate for ``Stateful/arbitrary(using:model:)``, with weights.
    /// - Parameter weights: The command weights to use.
    case statefulWeighted(
        weights: [Int]
    )
    
    
    
    /// Initializes an ``EnumGenerationKind`` instance from the given cases.
    /// - Parameter cases: The enum cases. Pass `nil` for ``arbitrary``.
    /// Otherwise, if any case has an explicit weight that is not `1`, this
    /// returns ``statefulWeighted(weights:)``.
    init(
        cases: [EnumCase]?
    )
    {
        guard let cases
        else
        {
            self = .arbitrary
            return
        }
        
        let weights: [Int] = cases.map { $0.weight ?? 1 }
        
        if weights.contains(where: { $0 != 1 })
        {
            self = .statefulWeighted(weights: weights)
        }
        else
        {
            self = .statefulWeightless
        }
    }
}



/// Generates the ``Arbitrary/arbitrary(using:)`` or
/// ``Stateful/arbitrary(using:model:)`` method for an enum.
///
/// Cases are partitioned into base cases (no associated values) and
/// payload cases (associated value). The generated shrink method uses
/// size-away generation to ensure termination for recursive types.
///
/// - Base cases only: A case is selected uniformly at random with no
/// size reduction.
///
/// - Base cases and payload cases: At size zero, only base cases are
/// selected, which guarantees termination for directly recursive and
/// mutually recursive types. At a size greater than zero, all cases are
/// eligible, but payload cases generate their associated values inside
/// ``GenerationContext/withReducedSize(by:_:)``, halving the size for
/// each level of recursion.
///
/// - Payload cases only: All cases are eligible at any size, with
/// associated values generated inside similarly as the mixed base/payload
/// variant. There is no size-zero guard, since there are no base cases
/// to act as fallbacks. For non-recursive types, this has no impact.
/// For mutually recursive types, this ensures size decreases on every
/// step through the cycle, so a partner type with base cases can terminate.
///
/// This logic is applied universally rather than only when self-references
/// are detected, since mutual recursion (`A` → `B` → `A`) cannot be
/// detected by the macro at the syntax level. The macro sees only one
/// declaration at a time.
///
/// - Parameters:
///   - kind: The generation kind.
///   - cases: The enum cases.
///   - typeName: The enum name.
///   - accessLevel: The access level.
/// - Returns: The method expansion.
internal func makeEnumArbitrary(
    kind        : EnumGenerationKind,
    cases       : [EnumCase],
    typeName    : String,
    accessLevel : String
) -> String
{
    let isStateful  : Bool
    let weights     : [Int]?
    
    switch kind
    {
        case .arbitrary:
            
            isStateful  = false
            weights     = nil
            
        case .statefulWeightless:
            
            isStateful  = true
            weights     = nil
            
        case let .statefulWeighted(w):
            
            isStateful  = true
            weights     = w
    }
    
    
    
    var lines: [String] = []
    
    lines.append(indent(1, "\(accessLevel)static func arbitrary("))
    
    if isStateful
    {
        lines.append(indent(2, "using context: GenerationContext,"))
        lines.append(indent(2, "model: Model"))
    }
    else
    {
        lines.append(indent(2, "using context: GenerationContext"))
    }
    
    lines.append(indent(1, ") -> \(typeName)"))
    lines.append(indent(1, "{"))
    
    
    
    var baseCases       : [EnumCase]    = []
    var payloadCases    : [EnumCase]    = []
    
    for enumCase in cases
    {
        if enumCase.associatedValues.isEmpty
        {
            baseCases.append(enumCase)
        }
        else
        {
            payloadCases.append(enumCase)
        }
    }
    
    if payloadCases.isEmpty
    {
        /// All cases are base cases (no associated values). Emit a direct
        /// `return` statement.
        appendCaseSelection(
            cases:          cases,
            weights:        weights,
            wrapPayload:    false,
            baseIndent:     2,
            lines:          &lines
        )
    }
    else
    {
        /// At least one case has associated values.
        
        if !baseCases.isEmpty
        {
            /// Emit a size guard that selects only base cases at size
            /// zero to ensure termination for recursive types.
            lines.append(indent(2, "if context.size <= 0"))
            lines.append(indent(2, "{"))
            
            appendCaseSelection(
                cases:          baseCases,
                weights:        weights,
                wrapPayload:    false,
                baseIndent:     3,
                lines:          &lines
            )
            
            lines.append(indent(2, "}"))
            lines.append("")
        }
        
        /// Select from all cases and wrap payload cases in
        /// ``GenerationContext/withReducedSize(by:_:)``.
        appendCaseSelection(
            cases:          cases,
            weights:        weights,
            wrapPayload:    true,
            baseIndent:     2,
            lines:          &lines
        )
    }
    
    lines.append(indent(1, "}"))
    
    return lines.joined(separator: "\n")
}



// MARK: - Shrinking

/// Generates the ``Arbitrary/shrink()`` or ``Stateful/shrink()`` method for
/// an enum.
///
/// Cases without associated values return an empty array, since no
/// shrinking is possible. Cases with associated values use one of the
/// following strategies.
///
/// ## Structural Shrinking
///
/// Structural shrinking is applied to associated values whoes type is the
/// enum itself (direct self-references). Each self-referencing value is
/// appended directly as a shrink candidate, since it is type-correct and
/// structurally smaller. These candidates appear first in the array of
/// candidates, which allows shrinking to collapse recursive structures
/// toward the base cases.
///
/// Without structural shrinking, recursive types could not shrink. The
/// one-at-a-time pattern at base cases would return an empty array and
/// propagate through every level.
///
/// Self-referencing is determined by ``isSelfReference(_:enumName:)``, by
/// checking an `IdentifierTypeSyntax` against the enum's name.
///
/// Mutually recursive types (`A` → `B` → `A`) do not benefit from
/// structural shrinking, since neither type's associated values match its
/// own name. The macro cannot perform cross-type structural analysis.
/// For these cases, shrinking is limited to each type's shrinking method.
///
/// ## One-at-a-Time Shrinking
///
/// One-at-a-time shrinking follows the structural candidates. Each
/// associated value is shrunk independently while the others are held
/// constant.
///
/// - Parameters:
///   - cases: The enum cases.
///   - typeName: The enum name.
///   - accessLevel: The access level.
/// - Returns: The method expansion.
internal func makeEnumShrink(
    cases       : [EnumCase],
    typeName    : String,
    accessLevel : String
) -> String
{
    var lines: [String] = []
    
    lines.append(indent(1, "\(accessLevel)func shrink() -> [\(typeName)]"))
    lines.append(indent(1, "{"))
    
    
    
    let hasAssociatedValues: Bool = cases.contains
    {
        return !$0.associatedValues.isEmpty
    }
    
    if !hasAssociatedValues
    {
        lines.append(indent(2, "return []"))
        lines.append(indent(1, "}"))
        
        return lines.joined(separator: "\n")
    }
    
    lines.append(indent(2, "switch self"))
    lines.append(indent(2, "{"))
    
    
    
    for (caseIndex, enumCase) in cases.enumerated()
    {
        if enumCase.associatedValues.isEmpty
        {
            lines.append(indent(3, "case .\(enumCase.name):"))
            lines.append("")
            lines.append(indent(4, "return []"))
        }
        else
        {
            let bindings: [String] = makeBindingNames(
                for: enumCase.associatedValues
            )
            
            let patternArgs: String = bindings.joined(separator: ", ")
            
            let reconstructionArgs: String = makeReconstructionArgs(
                for:        enumCase.associatedValues,
                bindings:   bindings
            )
            
            let text1: String
                = "case let .\(enumCase.name)(\(patternArgs)):"
            
            lines.append(indent(3, text1))
            lines.append("")
            lines.append(indent(4, "var _$results: [\(typeName)] = []"))
            
            
            
            /// Structual candidates. For associated values whose type is
            /// the enum itself, append the value directly to enable
            /// shrinking for recursive types where the one-at-a-time
            /// pattern would otherwise produce no shrink candidates.
            for (valueIndex, value) in
                    enumCase.associatedValues.enumerated()
            {
                let isSelfRef: Bool = isSelfReference(
                    value.typeSyntax,
                    enumName: typeName
                )
                
                if isSelfRef
                {
                    lines.append("")
                    
                    let appendText: String =
                        "_$results.append(\(bindings[valueIndex]))"
                    
                    lines.append(indent(4, appendText))
                }
            }
            
            
            
            for (valueIndex, _) in enumCase.associatedValues.enumerated()
            {
                let binding: String = bindings[valueIndex]
                
                lines.append("")
                
                let text2: String = "for \(binding) in \(binding).shrink()"
                
                lines.append(indent(4, text2))
                lines.append(indent(4, "{"))
                
                let text3: String = "_$results.append(.\(enumCase.name)"
                    + "(\(reconstructionArgs)))"
                
                lines.append(indent(5, text3))
                lines.append(indent(4, "}"))
            }
            
            
            
            lines.append("")
            lines.append(indent(4, "return _$results"))
        }
        
        
        
        if caseIndex < cases.count - 1
        {
            lines.append("")
        }
    }
    
    
    
    lines.append(indent(2, "}"))
    lines.append(indent(1, "}"))
    
    return lines.joined(separator: "\n")
}



// MARK: - Support

/// Indents the given text by the given amount.
/// - Parameters:
///   - level: The amount by which to indent the given text.
///   - text: The text to indent.
/// - Returns: The indented text.
internal func indent(
    _ level : Int,
    _ text  : String
) -> String
{
    return String(repeating: "    ", count: level) + text
}



/// Creates a prefix string representing the effective access level of
/// the given declaration.
///
/// The effective access level of a declaration is the most restrictive
/// access level of the declaration or any enclosing type.
///
/// - Parameters:
///   - decl: The declaration.
///   - context: The context in which the declaration appears.
/// - Returns: The prefix string representing the effective access level
/// of the given declaration.
internal func makeAccessPrefix(
    for     decl    : some DeclGroupSyntax,
    in      context : some MacroExpansionContext
) -> String
{
    var accessLevel: String? = decl.accessLevel
    
    for enclosing in context.lexicalContext
    {
        let enclosingLevel: String?
        
        if let declaration = enclosing.as(ClassDeclSyntax.self)
        {
            enclosingLevel = declaration.accessLevel
        }
        else if let declaration = enclosing.as(EnumDeclSyntax.self)
        {
            enclosingLevel = declaration.accessLevel
        }
        else if let declaration = enclosing.as(StructDeclSyntax.self)
        {
            enclosingLevel = declaration.accessLevel
        }
        else
        {
            continue
        }
        
        accessLevel = moreRestrictive(accessLevel, enclosingLevel)
    }
    
    switch accessLevel
    {
        case "public"       : return "public "
        case "package"      : return "package "
        case "private"      : return "fileprivate "
        case "fileprivate"  : return "fileprivate "
        default             : return "internal "
    }
}



/// Returns the more restrictive of the given access levels.
/// - Parameters:
///   - lhs: The first access level.
///   - rhs: The second access level.
/// - Returns: The more restrictive of the given access levels.
internal func moreRestrictive(
    _   lhs : String?,
    _   rhs : String?
) -> String?
{
    func rank(
        _ level: String?
    ) -> Int
    {
        switch level
        {
            case "private"      : return 0
            case "fileprivate"  : return 1
            case "internal"     : return 2
            case "package"      : return 3
            case "public"       : return 4
            default             : return 2
        }
    }
    
    return rank(lhs) <= rank(rhs)
        ? lhs
        : rhs
}



/// Creates enum case strings for the given enum case.
/// - Parameter enumCase: The enum case.
/// - Returns: The enum case string.
internal func makeCaseConstruction(
    _ enumCase: EnumCase
) -> String
{
    if enumCase.associatedValues.isEmpty
    {
        return ".\(enumCase.name)"
    }
    
    let args: String = enumCase.associatedValues.map
    {
        value in
        
        let generation: String
            = "\(value.typeName).arbitrary(using: context)"
        
        if let label: String = value.label
        {
            return "\(label): \(generation)"
        }
        
        return generation
    }.joined(separator: ", ")
    
    return ".\(enumCase.name)(\(args))"
}



/// Creates binding name strings for the given enum associated values.
/// - Parameter values: The enum associated values.
/// - Returns: The binding name strings.
internal func makeBindingNames(
    for values: [EnumAssociatedValue]
) -> [String]
{
    var unlabeledCounter: Int = 0
    
    return values.map
    {
        value in
        
        if let label: String = value.label
        {
            return label
        }
        
        let name: String = "_$v\(unlabeledCounter)"
        
        unlabeledCounter += 1
        
        return name
    }
}



/// Creates reconstruction arguments for the given enum associated values.
/// - Parameters:
///   - values: The enum associated values.
///   - bindings: The binding name strings.
/// - Returns: The reconstruction arguments.
internal func makeReconstructionArgs(
    for values  : [EnumAssociatedValue],
    bindings    : [String]
) -> String
{
    return zip(values, bindings).map
    {
        (value, binding) in
        
        if let label: String = value.label
        {
            return "\(label): \(binding)"
        }
        
        return binding
    }.joined(separator: ", ")
}



/// Creates a `where` clause constraining referenced generic parameters
/// to ``Arbitrary``.
/// - Parameters:
///   - parameterClause: The generic parameter clause of the declaration.
///   - typeSyntaxes: The type syntax nodes to scan for references.
/// - Returns: The `where` clause string including the leading space, or
/// an empty string if the declaration has no generic parameters, or none
/// of the parameters appear in the given type syntax nodes.
internal func makeWhereClause(
    parameterClause : GenericParameterClauseSyntax?,
    typeSyntaxes    : [TypeSyntax]
) -> String
{
    guard let parameterClause
    else
    {
        return ""
    }
    
    let genericNames: [String] = parameterClause.parameters.map
    {
        return $0.name.text
    }
    
    
    
    let walker = TypeSyntaxWalker()
    
    for typeSyntax in typeSyntaxes
    {
        walker.walk(typeSyntax)
    }
    
    
    
    let referenced: [String] = genericNames.filter
    {
        return walker.identifiers.contains($0)
    }
    
    if referenced.isEmpty
    {
        return ""
    }
    
    
    
    let constraints: String = referenced
        .map { "\($0) : Arbitrary" }
        .joined(separator: ", ")
    
    return " where \(constraints)"
}



/// Appends a case selection block to the given lines.
///
/// For a single case, this appends a direct `return` statement. For
/// multiple cases, this appends a `switch` statement over a random index.
/// For multiple cases with weights, this appends a weighted selection using
/// ``GenerationContext/randomElement(of:weightedBy:)``.
///
/// - Parameters:
///   - cases: The cases from which to select.
///   - weights: The per-case weights, or `nil` for uniform selection. When
///   non-`nil`, the count must equal the count of all cases in the enclosing
///   enum. Cases not present in `cases` (for example, payload cases excluded
///   from a base-case-only block) are skipped by index.
///   - wrapPayload: Whether to wrap payload cases (cases with associated
///   values) in ``GenerationContext/withReducedSize(by:_:)``.
///   - baseIndent: The base indentation level.
///   - lines: The lines to which to append.
internal func appendCaseSelection(
    cases       : [EnumCase],
    weights     : [Int]?,
    wrapPayload : Bool,
    baseIndent  : Int,
    lines       : inout [String]
)
{
    if cases.count == 1
    {
        appendCaseReturn(
            enumCase:       cases[0],
            wrapPayload:    wrapPayload,
            baseIndent:     baseIndent,
            lines:          &lines
        )
        
        return
    }
    
    
    let switchText          : String
    let effectiveWeights    : [Int]     = cases.map { $0.weight ?? 1 }
    
    let isWeighted: Bool = weights != nil
        && effectiveWeights.contains(where: { $0 != 1 })
    
    if isWeighted
    {
        let variableName: String = "_$selection"
        
        switchText = "switch \(variableName)"
        
        var tuples: [String] = []
        
        for (index, weight) in effectiveWeights.enumerated()
        {
            tuples.append("(\(weight), \(index))")
        }
        
        lines.append(
            indent(baseIndent, "let \(variableName) = context.randomElement(")
        )
        
        lines.append(
            indent(baseIndent + 1, "of: [\(tuples.joined(separator: ", "))],")
        )
        
        lines.append(indent(baseIndent + 1, "weightedBy: { $0.0 }"))
        lines.append(indent(baseIndent, ")!.1"))
        lines.append("")
    }
    else
    {
        switchText = "switch context.random(in: 0..<\(cases.count))"
    }
    
    lines.append(indent(baseIndent, switchText))
    lines.append(indent(baseIndent, "{"))
    
    for (index, enumCase) in cases.enumerated()
    {
        let patternText: String = index < cases.count - 1
            ? "case \(index):"
            : "default:"
        
        lines.append(indent(baseIndent + 1, patternText))
        
        appendCaseReturn(
            enumCase:       enumCase,
            wrapPayload:    wrapPayload,
            baseIndent:     baseIndent + 2,
            lines:          &lines
        )
        
        if index < cases.count - 1
        {
            lines.append("")
        }
    }
    
    lines.append(indent(baseIndent, "}"))
}



/// Appends a `return` statement for the given enum case.
/// - Parameters:
///   - enumCase: The enum case.
///   - wrapPayload: Whether to wrap payload cases (cases with associated
///   values) in ``GenerationContext/withReducedSize(by:_:)``.
///   - baseIndent: The base indentation level.
///   - lines: The lines to which to append.
private func appendCaseReturn(
    enumCase    : EnumCase,
    wrapPayload : Bool,
    baseIndent  : Int,
    lines       : inout [String]
)
{
    if
        wrapPayload,
        !enumCase.associatedValues.isEmpty
    {
        lines.append(
            indent(baseIndent, "return context.withReducedSize")
        )
        
        lines.append(indent(baseIndent, "{"))
        
        let caseText: String
            = "return \(makeCaseConstruction(enumCase))"
        
        lines.append(indent(baseIndent + 1, caseText))
        lines.append(indent(baseIndent, "}"))
    }
    else
    {
        let caseText: String
            = "return \(makeCaseConstruction(enumCase))"
        
        lines.append(indent(baseIndent, caseText))
    }
}



/// Whether the given type syntax is a direct self-reference.
///
/// A direct self-reference is an `IdentifierTypeSyntax` whose name matches
/// the enum's base identifier.
///
/// Types that contain the enum indirectly, such as `Optional<T>`
/// (`OptionalTypeSyntax`), `Array<T>` (`ArrayTypeSyntax`), or `(T, Int)`
/// (`TupleTypeSyntax`), do not match this condition, since their
/// outermost syntax node is not `IdentifierTypeSyntax`. These types shrink
/// through their own shrinking methods, rather than through structural
/// shrinking.
///
/// - Parameters:
///   - typeSyntax: The type syntax to check.
///   - enumName: The enum's base identifier name.
/// - Returns: Whether the given type syntax is a direct self-reference.
internal func isSelfReference(
    _ typeSyntax    : TypeSyntax,
    enumName        : String
) -> Bool
{
    guard let identifier = typeSyntax.as(IdentifierTypeSyntax.self)
    else
    {
        return false
    }
    
    return identifier.name.text == enumName
}
