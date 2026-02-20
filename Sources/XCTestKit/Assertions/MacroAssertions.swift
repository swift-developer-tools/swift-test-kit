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
public func _XCTKAssertMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    TKAssertMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertTrueMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    TKAssertTrueMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertFalseMacro(
    result          : Bool,
    exprText        : String,
    evaluated       : [BooleanExpr],
    notEvaluated    : Int,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
)
{
    TKAssertFalseMacro(
        result:         result,
        exprText:       exprText,
        evaluated:      evaluated,
        notEvaluated:   notEvaluated,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        context:        failureContext
    )
}



// MARK: - Nil and non-nil

@_documentation(visibility: package)
public func _XCTKAssertNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    TKAssertNilMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNotNilMacro(
    expr        : @autoclosure () throws -> Any?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    TKAssertNotNilMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKUnwrapMacro<T>(
    expr        : @autoclosure () throws -> T?,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) throws -> T
{
    return try TKUnwrapMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Equality and inequality

@_documentation(visibility: package)
public func _XCTKAssertEqualMacro<T>(
    expected        : @autoclosure () throws -> T,
    actual          : @autoclosure () throws -> T,
    expectedText    : String,
    actualText      : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where T : Equatable
{
    TKAssertEqualMacro(
        expected:       expected,
        actual:         actual,
        expectedText:   expectedText,
        actualText:     actualText,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Equatable
{
    TKAssertNotEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    TKAssertIdenticalMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNotIdenticalMacro(
    expr1       : @autoclosure () throws -> AnyObject?,
    expr2       : @autoclosure () throws -> AnyObject?,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    TKAssertNotIdenticalMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
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
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
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
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
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
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNotEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    accuracy    : T,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
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
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Comparable

@_documentation(visibility: package)
public func _XCTKAssertGreaterThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertGreaterThanMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertGreaterThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertGreaterThanOrEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertLessThanOrEqualMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertLessThanOrEqualMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertLessThanMacro<T>(
    expr1       : @autoclosure () throws -> T,
    expr2       : @autoclosure () throws -> T,
    expr1Text   : String,
    expr2Text   : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
) where T : Comparable
{
    TKAssertLessThanMacro(
        expr1:      expr1,
        expr2:      expr2,
        expr1Text:  expr1Text,
        expr2Text:  expr2Text,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Error

@_documentation(visibility: package)
public func _XCTKAssertThrowsErrorMacro<T>(
    expr            : () throws -> T,
    exprText        : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?,
    errorHandler    : (any Error) -> Void
)
{
    TKAssertThrowsErrorMacro(
        expr:           expr,
        exprText:       exprText,
        message:        message,
        file:           file,
        line:           line,
        options:        options ?? XCTKConfig.global,
        errorHandler:   errorHandler,
        context:        failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNoThrowMacro<T>(
    expr        : () throws -> T,
    exprText    : String,
    message     : @autoclosure () -> String,
    file        : StaticString,
    line        : UInt,
    options     : TestOptions?
)
{
    TKAssertNoThrowMacro(
        expr:       expr,
        exprText:   exprText,
        message:    message,
        file:       file,
        line:       line,
        options:    options ?? XCTKConfig.global,
        context:    failureContext
    )
}



// MARK: - Fail

@_documentation(visibility: package)
public func _XCTKFailMacro(
    message : String,
    file    : StaticString,
    line    : UInt
)
{
    TKFailMacro(
        message:    message,
        file:       file,
        line:       line,
        context:    failureContext
    )
}



// MARK: - Predicate

@_documentation(visibility: package)
public func _XCTKAssertAllSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertAllSatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertAnySatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertAnySatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertNoneSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertNoneSatisfyMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atLeast         : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
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
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    atMost          : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
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
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertSatisfyMacro<C>(
    collection      : @autoclosure () throws -> C,
    range           : ClosedRange<Int>,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
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
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertExactlyMacro<C>(
    collection      : @autoclosure () throws -> C,
    count           : Int,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
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
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertExactlyOneMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection
{
    TKAssertExactlyOneMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertSortedMacro<C>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element, C.Element) throws -> Bool,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?        
) where C : Collection
{
    TKAssertSortedMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertUniqueMacro<C>(
    collection      : @autoclosure () throws -> C,
    collectionText  : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection, C.Element : Hashable
{
    TKAssertUniqueMacro(
        collection:         collection,
        collectionText:     collectionText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}



@_documentation(visibility: package)
public func _XCTKAssertUniqueMacro<C, K>(
    collection      : @autoclosure () throws -> C,
    predicate       : (C.Element) throws -> K,
    collectionText  : String,
    predicateText   : String,
    message         : @autoclosure () -> String,
    file            : StaticString,
    line            : UInt,
    options         : TestOptions?
) where C : Collection, K : Hashable
{
    TKAssertUniqueMacro(
        collection:         collection,
        predicate:          predicate,
        collectionText:     collectionText,
        predicateText:      predicateText,
        message:            message,
        file:               file,
        line:               line,
        options:            options ?? XCTKConfig.global,
        context:            failureContext
    )
}
