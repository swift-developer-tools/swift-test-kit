//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest
@testable import struct TestKitCore.InterceptedFailure



internal final class PropertyInterceptorTests: TestKitCase
{
    // MARK: - Initialize
    
    func testInitialState()
    {
        let interceptor = PropertyInterceptor()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertTrue(interceptor.distribution.isEmpty)
        XCTAssertTrue(interceptor.coverageRequirements.isEmpty)
        XCTAssertTrue(interceptor.tableLabels.isEmpty)
        XCTAssertTrue(interceptor.tableDistribution.isEmpty)
        XCTAssertTrue(interceptor.tableCoverageRequirements.isEmpty)
    }
    
    
    
    // MARK: - Reset
    
    func testResetClearsFailuresAndLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordFailure()
        
        interceptor.recordLabel("label")
        interceptor.recordCoverageRequirement(50, for: "req")
        interceptor.recordTableLabel("v", table: "t")
        
        XCTAssertTrue(interceptor.didFail)
        XCTAssertEqual(interceptor.failures.count, 1)
        XCTAssertEqual(interceptor.labels, ["label"])
        XCTAssertEqual(interceptor.coverageRequirements, ["req": 50])
        XCTAssertEqual(interceptor.tableLabels, ["t": ["v"]])
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.coverageRequirements, ["req": 50])
        XCTAssertTrue(interceptor.tableLabels.isEmpty)
    }
    
    
    
    func testResetPreservesDistributionAndCoverage()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(50, for: "a")
        interceptor.recordTableCoverageRequirement(20, for: "x", in: "t")
        
        interceptor.recordLabel("a")
        interceptor.recordTableLabel("x", table: "t")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("b")
        interceptor.recordTableLabel("y", table: "t")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("c")
        interceptor.recordTableLabel("z", table: "t")
        
        interceptor.recordFailure()
        
        interceptor.reset()
        
        XCTAssertFalse(interceptor.didFail)
        XCTAssertTrue(interceptor.failures.isEmpty)
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 50])
        XCTAssertEqual(interceptor.distribution, ["a": 1, "b": 1])
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.tableCoverageRequirements, ["t": ["x": 20]])
        XCTAssertEqual(interceptor.tableDistribution, ["t": ["x": 1, "y": 1]])
    }
    
    
    
    // MARK: - Labels
    
    func testRecordLabelAddsToCurrentIteration()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        
        XCTAssertEqual(interceptor.labels, ["a"])
        XCTAssertTrue(interceptor.distribution.isEmpty)
    }
    
    
    
    func testRecordMultipleLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        interceptor.recordLabel("c")
        
        XCTAssertEqual(interceptor.labels, ["a", "b", "c"])
    }
    
    
    
    func testRecordDuplicateLabelIdempotency()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        
        XCTAssertEqual(interceptor.labels, ["a"])
    }
    
    
    
    func testRecordTableLabelAddsToCurrentIteration()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("v", table: "t")
        
        XCTAssertEqual(interceptor.tableLabels, ["t": ["v"]])
        XCTAssertTrue(interceptor.tableDistribution.isEmpty)
    }
    
    
    
    func testRecordMultipleTableLabelsSameTable()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t")
        interceptor.recordTableLabel("b", table: "t")
        interceptor.recordTableLabel("c", table: "t")
        
        XCTAssertEqual(interceptor.tableLabels, ["t": ["a", "b", "c"]])
    }
    
    
    
    func testRecordTableLabelsDifferentTables()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t1")
        interceptor.recordTableLabel("b", table: "t2")
        
        XCTAssertEqual(interceptor.tableLabels, ["t1": ["a"], "t2": ["b"]])
    }
    
    
    
    func testRecordDuplicateTableLabelIdempotency()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t")
        interceptor.recordTableLabel("a", table: "t")
        interceptor.recordTableLabel("a", table: "t")
        
        XCTAssertEqual(interceptor.tableLabels, ["t": ["a"]])
    }
    
    
    
    // MARK: - Finalize iteration
    
    func testFinalizeIterationDuplicateLabelsIdempotency()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.recordLabel("a")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(interceptor.distribution, ["a": 1])
    }
    
    
    
    func testFinalizeIterationFlushesLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        
        XCTAssertEqual(interceptor.labels, ["a", "b"])
        XCTAssertTrue(interceptor.distribution.isEmpty)
        
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertEqual(interceptor.distribution, ["a": 1, "b": 1])
    }
    
    
    
    func testFinalizeIterationAccumulatesAcrossIterations()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("b")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("a")
        interceptor.recordLabel("c")
        interceptor.finalizeIteration()
        
        interceptor.recordLabel("b")
        interceptor.recordLabel("d")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(
            interceptor.distribution,
            ["a": 2, "b": 2, "c": 1, "d": 1]
        )
    }
    
    
    
    func testFinalizeIterationWithNoLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertTrue(interceptor.distribution.isEmpty)
    }
    
    
    
    func testFinalizeIterationFlushesTableLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t1")
        interceptor.recordTableLabel("b", table: "t2")
        
        XCTAssertEqual(interceptor.tableLabels, ["t1": ["a"], "t2": ["b"]])
        XCTAssertTrue(interceptor.tableDistribution.isEmpty)
        
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.tableLabels.isEmpty)
        
        XCTAssertEqual(
            interceptor.tableDistribution,
            ["t1": ["a": 1], "t2": ["b": 1]]
        )
    }
    
    
    
    func testFinalizeIterationAccumulatesTableDistribution()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t1")
        interceptor.recordTableLabel("b", table: "t2")
        interceptor.finalizeIteration()
        
        interceptor.recordTableLabel("c", table: "t1")
        interceptor.recordTableLabel("d", table: "t2")
        interceptor.finalizeIteration()
        
        interceptor.recordTableLabel("a", table: "t1")
        interceptor.recordTableLabel("b", table: "t2")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(
            interceptor.tableDistribution,
            [
                "t1": ["a": 2, "c": 1],
                "t2": ["b": 2, "d": 1]
            ]
        )
    }
    
    
    
    func testFinalizeIterationDuplicateTableLabelsCountOnce()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t")
        interceptor.recordTableLabel("a", table: "t")
        interceptor.recordTableLabel("a", table: "t")
        interceptor.finalizeIteration()
        
        XCTAssertEqual(interceptor.tableDistribution, ["t": ["a": 1]])
    }
    
    
    
    func testFinalizeIterationFlushesBothFlatAndTableLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.recordTableLabel("b", table: "t")
        interceptor.finalizeIteration()
        
        XCTAssertTrue(interceptor.labels.isEmpty)
        XCTAssertTrue(interceptor.tableLabels.isEmpty)
        XCTAssertEqual(interceptor.distribution, ["a": 1])
        XCTAssertEqual(interceptor.tableDistribution, ["t": ["b": 1]])
    }
    
    
    
    func testFinalizeIterationWithNoTableLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableLabel("a", table: "t")
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        interceptor.finalizeIteration()
        
        XCTAssertEqual(interceptor.tableDistribution, ["t": ["a": 1]])
    }
    
    
    
    // MARK: - Coverage requirements
    
    func testRecordCoverageRequirement()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 5])
    }
    
    
    
    func testRecordCoverageRequirementMaxOverrides()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        interceptor.recordCoverageRequirement(10, for: "a")
        interceptor.recordCoverageRequirement(2, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 10])
    }
    
    
    
    func testRecordCoverageRequirementMultipleLabels()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        interceptor.recordCoverageRequirement(10, for: "b")
        interceptor.recordCoverageRequirement(2, for: "c")
        
        XCTAssertEqual(
            interceptor.coverageRequirements,
            ["a": 5, "b": 10, "c": 2]
        )
    }
    
    
    
    func testRecordCoverageRequirementClampsAbove()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(150, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 100])
    }
    
    
    
    func testRecordCoverageRequirementClampsBelow()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(-150, for: "a")
        
        XCTAssertEqual(interceptor.coverageRequirements, ["a": 0])
    }
    
    
    
    func testRecordTableCoverageRequirement()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(5, for: "a", in: "t")
        
        XCTAssertEqual(
            interceptor.tableCoverageRequirements,
            ["t": ["a": 5]]
        )
    }
    
    
    
    func testRecordTableCoverageRequirementMaxOverrides()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(5, for: "a", in: "t")
        interceptor.recordTableCoverageRequirement(10, for: "a", in: "t")
        interceptor.recordTableCoverageRequirement(2, for: "a", in: "t")
        
        XCTAssertEqual(
            interceptor.tableCoverageRequirements,
            ["t": ["a": 10]]
        )
    }
    
    
    
    func testRecordTableCoverageRequirementMultipleLabelsAndTables()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(5, for: "a", in: "t1")
        interceptor.recordTableCoverageRequirement(10, for: "b", in: "t1")
        interceptor.recordTableCoverageRequirement(20, for: "a", in: "t2")
        
        XCTAssertEqual(
            interceptor.tableCoverageRequirements,
            [
                "t1": ["a": 5, "b": 10],
                "t2": ["a": 20]
            ]
        )
    }
    
    
    
    func testRecordTableCoverageRequirementClampsAbove()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(150, for: "a", in: "t")

        
        XCTAssertEqual(
            interceptor.tableCoverageRequirements,
            ["t": ["a": 100]]
        )
    }
    
    
    
    func testRecordTableCoverageRequirementClampsBelow()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(-150, for: "a", in: "t")

        
        XCTAssertEqual(
            interceptor.tableCoverageRequirements,
            ["t": ["a": 0]]
        )
    }
    
    
    
    // MARK: - Check coverage
    
    func testCheckCoverageReturnsEmptyWhenMet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(10, for: "a")
        
        for index in 0..<100
        {
            if index < 20
            {
                interceptor.recordLabel("a")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageReturnsUnmetRequirements()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(50, for: "a")
        interceptor.recordCoverageRequirement(10, for: "b")
        
        for index in 0..<100
        {
            if index < 10
            {
                interceptor.recordLabel("a")
            }
            else if index < 40
            {
                interceptor.recordLabel("b")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 50)
        XCTAssertEqual(unmet[0].actual, 10)
        XCTAssertNil(unmet[0].table)
    }
    
    
    
    func testCheckCoverageWithZeroPercentageAlwaysMet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(0, for: "a")
        
        for _ in 0..<100
        {
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageExactlyAtThreshold()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(10, for: "a")
        
        for index in 0..<100
        {
            /// Exactly 10%.
            if index < 10
            {
                interceptor.recordLabel("a")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageWithNoRequirements()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordLabel("a")
        interceptor.finalizeIteration()
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 1)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckCoverageUnrecordedLabelWithRequirement()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(5, for: "a")
        
        for _ in 0..<100
        {
            interceptor.recordLabel("b")
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 5)
        XCTAssertEqual(unmet[0].actual, 0)
        XCTAssertNil(unmet[0].table)
    }
    
    
    
    func testCheckTableCoverageReturnsEmptyWhenMet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(10, for: "a", in: "t")
        
        for index in 0..<100
        {
            if index < 20
            {
                interceptor.recordTableLabel("a", table: "t")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckTableCoverageReturnsUnmetRequirements()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(50, for: "a", in: "t")
        
        for index in 0..<100
        {
            if index < 10
            {
                interceptor.recordTableLabel("a", table: "t")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 50)
        XCTAssertEqual(unmet[0].actual, 10)
        XCTAssertEqual(unmet[0].table, "t")
    }
    
    
    
    func testCheckTableCoverageUnrecordedLabelWithRequirement()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(5, for: "a", in: "t")
        
        for _ in 0..<100
        {
            interceptor.recordTableLabel("b", table: "t")
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 5)
        XCTAssertEqual(unmet[0].actual, 0)
        XCTAssertEqual(unmet[0].table, "t")
    }
    
    
    
    func testCheckTableCoverageMixesFlatAndTableUnmet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordCoverageRequirement(50, for: "x")
        interceptor.recordTableCoverageRequirement(50, for: "a", in: "t")
        
        for index in 0..<100
        {
            if index < 10
            {
                interceptor.recordLabel("x")
                interceptor.recordTableLabel("a", table: "t")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 2)
        
        let flat    : UnmetCoverage?    = unmet.first { $0.table == nil }
        let table   : UnmetCoverage?    = unmet.first { $0.table != nil }
        
        XCTAssertNotNil(flat)
        XCTAssertNotNil(table)
        
        XCTAssertEqual(flat?.label, "x")
        XCTAssertEqual(flat?.actual, 10)
        XCTAssertNil(flat?.table)
        
        XCTAssertEqual(table?.label, "a")
        XCTAssertEqual(table?.actual, 10)
        XCTAssertEqual(table?.table, "t")
    }
    
    
    
    func testCheckTableCoverageExactlyAtThreshold()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(10, for: "a", in: "t")
        
        for index in 0..<100
        {
            if index < 10
            {
                interceptor.recordTableLabel("a", table: "t")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckTableCoverageZeroPercentageVacuouslyPasses()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(0, for: "a", in: "t")
        
        for _ in 0..<100
        {
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
    }
    
    
    
    func testCheckTableCoverageSameLabelDifferentTables()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(50, for: "a", in: "t1")
        interceptor.recordTableCoverageRequirement(10, for: "a", in: "t2")
        
        for index in 0..<100
        {
            if index < 20
            {
                interceptor.recordTableLabel("a", table: "t1")
            }
            
            interceptor.recordTableLabel("a", table: "t2")
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 50)
        XCTAssertEqual(unmet[0].actual, 20)
        XCTAssertEqual(unmet[0].table, "t1")
    }
    
    
    
    func testCheckTableCoverageNoRequirementsWithLabels()
    {
        let interceptor = PropertyInterceptor()
        
        for _ in 0..<100
        {
            interceptor.recordTableLabel("a", table: "t")
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertTrue(unmet.isEmpty)
        XCTAssertEqual(interceptor.tableDistribution, ["t": ["a": 100]])
    }
    
    
    
    func testCheckTableCoverageMultipleTablesPartiallyUnmet()
    {
        let interceptor = PropertyInterceptor()
        
        interceptor.recordTableCoverageRequirement(30, for: "a", in: "t1")
        interceptor.recordTableCoverageRequirement(30, for: "b", in: "t1")
        interceptor.recordTableCoverageRequirement(30, for: "a", in: "t2")
        
        for index in 0..<100
        {
            if index < 40
            {
                interceptor.recordTableLabel("a", table: "t1")
            }
            else
            {
                interceptor.recordTableLabel("b", table: "t1")
            }
            
            if index < 10
            {
                interceptor.recordTableLabel("a", table: "t2")
            }
            
            interceptor.finalizeIteration()
        }
        
        let unmet: [UnmetCoverage] = interceptor.checkCoverage(iterations: 100)
        
        XCTAssertEqual(unmet.count, 1)
        XCTAssertEqual(unmet[0].label, "a")
        XCTAssertEqual(unmet[0].required, 30)
        XCTAssertEqual(unmet[0].actual, 10)
        XCTAssertEqual(unmet[0].table, "t2")
    }
}
