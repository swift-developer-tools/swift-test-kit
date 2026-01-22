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
@testable import XCTestKitTestUtilities



final class NilFunctionAssertionTests: XCTestKitCase
{
    typealias AK = AssertionKind
    
    
    
    // MARK: - Nil
    
    func testAssertNilWithNilExpr() throws
    {
        XCTKAssertNil(nil)
        XCTKAssertNil(Optional<Int>(nil))
    }
    
    
    
    func testAssertNilWithNonNilExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertNil(false)
    }
    
    
    
    func testAssertNilFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.`nil`.name) failed")
        }
        
        XCTKAssertNil(false)
    }
    
    
    
    func testAssertNilFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.`nil`.name) failed - \(message)"
            )
        }
        
        XCTKAssertNil(false, message)
    }
    
    
    
    func testAssertNilWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            issue in
            
            return issue.type == .assertionFailure
                && issue.compactDescription.contains("threw error")
        }
        
        XCTKAssertNil(try TestError.throwError())
    }
    
    
    
    func testAssertNilMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.`nil`)
    }
    
    
    
    func testAssertNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.`nil`)
    }
    
    
    
    // MARK: - Not nil
    
    func testAssertNotNilWithNonNilExpr() throws
    {
        XCTKAssertNotNil(true)
        XCTKAssertNotNil(false)
        XCTKAssertNotNil(0)
    }
    
    
    
    func testAssertNotNilWithNilExpr() throws
    {
        XCTExpectFailure()
        XCTKAssertNotNil(nil)
    }
    
    
    
    func testAssertNotNilFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.notNil.name) failed")
        }
        
        XCTKAssertNotNil(nil)
    }
    
    
    
    func testAssertNotNilFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.notNil.name) failed - \(message)"
            )
        }
        
        XCTKAssertNotNil(nil, message)
    }
    
    
    
    func testAssertNotNilWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            issue in
            
            return issue.type == .assertionFailure
                && issue.compactDescription.contains("threw error")
        }
        
        XCTKAssertNotNil(try TestError.throwError())
    }
    
    
    
    func testAssertNotNilMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.notNil)
    }
    
    
    
    func testAssertNotNilMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.notNil)
    }
    
    
    
    // MARK: - Unwrap
    
    func testUnwrapWithNilExpr() throws
    {
        XCTExpectFailure()
        _ = try XCTKUnwrap(Optional<Int>(nil))
    }
    
    
    
    func testUnwrapWithNonNilExpr() throws
    {
        XCTAssertTrue(try XCTKUnwrap(true))
        XCTAssertFalse(try XCTKUnwrap(false))
        XCTAssertNotNil(try XCTKUnwrap(Optional<Int>(1)))
    }
    
    
    
    func testUnwrapFailureFormat() throws
    {
        XCTExpectFailure
        {
            return $0.compactDescription.contains("\(AK.unwrap.name) failed")
        }
        
        _ = try XCTKUnwrap(Optional<Int>(nil))
    }
    
    
    
    func testUnwrapFailureFormatWithMessage() throws
    {
        let message: String = "hello world"
        
        XCTExpectFailure
        {
            return $0.compactDescription.contains(
                "\(AK.unwrap.name) failed - \(message)"
            )
        }
        
        _ = try XCTKUnwrap(Optional<Int>(nil), message)
    }
    
    
    
    func testUnwrapWithThrowingExpr() throws
    {
        XCTExpectFailure
        {
            issue in
            
            return issue.type == .assertionFailure
                && issue.compactDescription.contains("threw error")
        }
        
        _ = try XCTKUnwrap(try TestError.throwError())
    }
    
    
    
    func testUnwrapThrowsXCTKUnwrapErrorOnNil() throws
    {
        XCTExpectFailure()
        
        do
        {
            _ = try XCTKUnwrap(Optional<Int>(nil))
            
            XCTFail("Expected XCTKUnwrapError to be thrown")
        }
        catch is XCTKUnwrapError
        {
            /// Expected.
        }
        catch
        {
            XCTFail("Expected XCTKUnwrapError, got \(type(of: error))")
        }
    }
    
    
    
    func testUnwrapRethrowsOriginalError() throws
    {
        XCTExpectFailure()
        
        do
        {
            _ = try XCTKUnwrap(try TestError.throwError())
            
            XCTFail("Expected TestError to be thrown")
        }
        catch is TestError
        {
            /// Expected.
        }
        catch
        {
            XCTFail("Expected TestError, got \(type(of: error))")
        }
    }
    
    
    
    func testUnwrapMessageNotEvaluatedOnSuccess() throws
    {
        testAssertionMessageNotEvaluatedOnSuccess(.unwrap)
    }
    
    
    
    func testUnwrapMessageEvaluatedOnlyOnceOnFailure() throws
    {
        testAssertionMessageEvaluatedOnceOnFailure(.unwrap)
    }
}
