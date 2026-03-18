//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



// MARK: - Boolean

@_documentation(visibility: package)
public func _STKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
)
{
    TKAssertMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertTrueMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
)
{
    TKAssertTrueMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertFalseMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
)
{
    TKAssertFalseMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        context:        failureContext
    )
}



// MARK: - Nil and non-nil

@_documentation(visibility: package)
public func _STKAssertNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
)
{
    TKAssertNilMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNotNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
)
{
    TKAssertNotNilMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKUnwrapMacro<T>(
    expr        : @autoclosure () throws -> T?,
    exprText    : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) throws -> T
{
    return try TKUnwrapMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



// MARK: - Equality and inequality

@_documentation(visibility: package)
public func _STKAssertEqualMacro<T>(
    expected        : @autoclosure () throws -> T,
    actual          : @autoclosure () throws -> T,
    expectedText    : String,
    actualText      : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where T : Equatable
{
    TKAssertEqualMacro(
        expected:       expected,
        actual:         actual,
        expectedText:   expectedText,
        actualText:     actualText,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Equatable
{
    TKAssertNotEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
)
{
    TKAssertIdenticalMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNotIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
)
{
    TKAssertNotIdenticalMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : FloatingPoint
{
    TKAssertEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Numeric
{
    TKAssertEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : FloatingPoint
{
    TKAssertNotEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Numeric
{
    TKAssertNotEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        accuracy:   accuracy,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



// MARK: - Comparable

@_documentation(visibility: package)
public func _STKAssertGreaterThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertGreaterThanMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertGreaterThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertGreaterThanOrEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertLessThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertLessThanOrEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertLessThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertLessThanMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



// MARK: - Error

@_documentation(visibility: package)
public func _STKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?,
    errorHandler    : (any Error) -> Void
)
{
    TKAssertThrowsErrorMacro(
        expr:           expr,
        exprText:       exprText,
        message:        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        errorHandler:   errorHandler,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNoThrowMacro<T>(
    expr        : () throws -> T,
    exprText    : String,
    message     : @autoclosure () -> String,
    fileID      : StaticString,
    file        : StaticString,
    line        : UInt,
    column      : UInt,
    options     : TestOptions?
)
{
    TKAssertNoThrowMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.current,
        context:    failureContext
    )
}



// MARK: - Fail

@_documentation(visibility: package)
public func _STKFailMacro(
    message : String,
    fileID  : StaticString,
    file    : StaticString,
    line    : UInt,
    column  : UInt
)
{
    TKFailMacro(
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        context:    failureContext
    )
}



// MARK: - Predicate

@_documentation(visibility: package)
public func _STKAssertAllSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertAllSatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertAnySatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertAnySatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertNoneSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertNoneSatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atLeast         : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertSatisfyMacro(
        collection:         collection,
        atLeast:            atLeast,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atMost          : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertSatisfyMacro(
        collection:         collection,
        atMost:             atMost,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertSatisfyMacro(
        collection:         collection,
        range:              range,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertExactlyMacro<C>(
    collection      : @autoclosure () throws -> C,
    count           : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertExactlyMacro(
        collection:         collection,
        count:              count,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertExactlyOneMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertExactlyOneMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertSortedMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element, C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertSortedMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertUniqueMacro<C>(
    collection      : @autoclosure () throws -> C,
    collectionText  : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection, C.Element : Hashable
{
    TKAssertUniqueMacro(
        collection:         collection,
        collectionText:     collectionText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _STKAssertUniqueMacro<C, K>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> K,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    fileID          : StaticString,
    file            : StaticString,
    line            : UInt,
    column          : UInt,
    options         : TestOptions?
) where C : Collection, K : Hashable
{
    TKAssertUniqueMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        fileID:             fileID,
        file:               file,
        line:               line,
        column:             column,
        options:            options ?? TestConfiguration.current,
        context:            failureContext
    )
}
