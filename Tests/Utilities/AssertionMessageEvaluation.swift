//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit



// TODO: Remove
private func notImplemented(
    _ kind: AssertionKind
)
{
    XCTFail("\(kind.name) not implemented")
}



/// Asserts that the message of the specified assertion is not evaluated
/// when the assertion succeeds.
/// - Parameter kind: The assertion to use.
func testAssertionMessageNotEvaluatedOnSuccess(
    _ kind: AssertionKind
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    switch kind
    {
        case .assert:
            
            XCTKAssert(true, message())
            
        case .equal:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .equalWithAccuracy:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .identical:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .notIdentical:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .greaterThan:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .greaterThanOrEqual:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .lessThan:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .lessThanOrEqual:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .notEqual:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .notEqualWithAccuracy:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .nil:
            
            XCTKAssertNil(nil, message())
            
        case .notNil:
            
            XCTKAssertNotNil(Optional<Int>(1), message())
            
        case .unwrap:
            
            _ = try? XCTKUnwrap(Optional<Int>(1), message())
            
        case .true:
            
            XCTKAssertTrue(true, message())
            
        case .false:
            
            XCTKAssertFalse(false, message())
            
        case .fail:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .throwsError:
            
            // TODO: Implement.
            notImplemented(kind)
            
        case .noThrow:
            
            // TODO: Implement.
            notImplemented(kind)
    }
    
    XCTAssertEqual(count, 0)
}



/// Asserts that the message of the specified assertion is evaluated only
/// once when the assertion fails.
/// - Parameter kind: The assertion to use.
func testAssertionMessageEvaluatedOnceOnFailure(
    _ kind: AssertionKind
)
{
    var count   : Int           = 0
    let message : () -> String  = { count += 1; return "msg" }
    
    XCTExpectFailure()
    {
        switch kind
        {
            case .assert:
                
                XCTKAssert(false, message())
                
            case .equal:
                
                // TODO: Implement.
                return
                
            case .equalWithAccuracy:
                
                // TODO: Implement.
                return
                
            case .identical:
                
                // TODO: Implement.
                return
                
            case .notIdentical:
                
                // TODO: Implement.
                return
                
            case .greaterThan:
                
                // TODO: Implement.
                return
                
            case .greaterThanOrEqual:
                
                // TODO: Implement.
                return
                
            case .lessThan:
                
                // TODO: Implement.
                return
                
            case .lessThanOrEqual:
                
                // TODO: Implement.
                return
                
            case .notEqual:
                
                // TODO: Implement.
                return
                
            case .notEqualWithAccuracy:
                
                // TODO: Implement.
                return
                
            case .nil:
                
                XCTKAssertNil(1, message())
                
            case .notNil:
                
                XCTKAssertNotNil(nil, message())
                
            case .unwrap:
                
                _ = try? XCTKUnwrap(Optional<Int>(nil), message())
                
            case .true:
                
                XCTKAssertTrue(false, message())
                
            case .false:
                
                XCTKAssertFalse(true, message())
                
            case .fail:
                
                // TODO: Implement.
                return
                
            case .throwsError:
                
                // TODO: Implement.
                return
                
            case .noThrow:
                
                // TODO: Implement.
                return
        }
    }
    
    XCTAssertEqual(count, 1)
}
