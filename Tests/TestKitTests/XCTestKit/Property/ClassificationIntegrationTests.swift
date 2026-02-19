//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class ClassificationIntegrationTests: XCTestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    func testClassificationOutsidePropertyBodyIsNoOp()
    {
        XCTKClassify("label", when: true)
        XCTKCover(50, "label", when: true)
        XCTKLabel("label")
        XCTKCollect(50)
        XCTKTabulate("table", "label")
        XCTKCoverTable("table", (50, "label"))
        
        do
        {
            try XCTKAssume(false)
        }
        catch
        {
            XCTFail("Expected no error to be thrown from assumption")
        }
    }
    
    
    
    @Reasync
    func testCoverageMetPasses() async
    {
        /// All values are `5`, so cover executes every iteration.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKCover(100, "positive", when: n > 0)
        }
    }
    
    
    
    @Reasync
    func testCoverageNotMetProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so cover never executes.
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKCover(100, "negative", when: n < 0)
            }
        }
    }
    
    
    
    @Reasync
    func testClassifyFalseConditionDoesNotFail() async
    {
        /// All values are `5`, so cover never executes, but there is no
        /// coverage requirement.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKClassify("negative", when: n < 0)
        }
    }
    
    
    
    @Reasync
    func testLabelWithCoverageReqMet() async
    {
        /// The label is recorded unconditionally, so cover executes every
        /// iteration.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async in
            
            XCTKLabel("tracked")
            XCTKCover(100, "tracked", when: true)
        }
    }
    
    
    
    @Reasync
    func testCollectWithCoverageReqMet() async
    {
        /// Collect records the string representation of the value, which
        /// is always `5`, and cover executes every iteration.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKCollect(n)
            XCTKCover(100, "5", when: true)
        }
    }
    
    
    
    @Reasync
    func testMultipleCoverSameLabelTakesMaximum() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so cover never executes.
            /// The higher cover percentage overrides the lower one.
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKCover(10, "negative", when: n < 0)
                XCTKCover(100, "negative", when: n < 0)
            }
        }
    }
    
    
    
    @Reasync
    func testCoverageMetWithPrecondition() async
    {
        /// The precondition leaves only even numbers, so cover
        /// executes every iteration.
        await XCTKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            where:      { $0 % 2 == 0 },
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKCover(100, "even", when: n % 2 == 0)
        }
    }
    
    
    
    @Reasync
    func testCoverageMetWithCustomGenerator() async
    {
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        100,
            seed:           1
        )
        
        await XCTKForAll(
            using:      generator,
            options:    options
        )
        {
            (n: Int) async in
            
            XCTKClassify("small", when: n < 50)
            XCTKClassify("large", when: n >= 50)
        }
    }
    
    
    
    @Reasync
    func testCoverageMetMultipleGenerators() async
    {
        await XCTKForAll(
            using:      Generator<Int>.constant(1),
                        Generator<Int>.constant(2),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (a: Int, b: Int) async in
            
            XCTKCover(100, "a < b", when: a < b)
        }
    }
    
    
    
    @Reasync
    func testSequentialPropertiesDoNotLeakClassificationState() async
    {
        /// The first property records `first` and has an unmet requirement.
        /// The second property records `second` with a met requirement.
        /// If classification state leaks, `first` would appear in the second
        /// property's distribution.
        
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKLabel("first")
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKLabel("second")
            XCTKCover(100, "second", when: true)
        }
    }
    
    
    
    @Reasync
    func testClassificationDoesNotInterfereWithInterception() async
    {
        /// Classification and assertion interception share the same
        /// interceptor. Classification calls must not cause assertion
        /// failures to leak as separate failures.
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKClassify("small", when: n < 0)
                XCTKClassify("large", when: n >= 0)
                XCTKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    @Reasync
    func testClassificationContinuesAfterFailingAssertion() async
    {
        /// Classification calls and assertion failures share the same
        /// interceptor. Any labels placed after a non-throwing assertion
        /// continue to execute normally.
        await withOneExpectedFailure
        {
            await XCTKForAll(
                options: .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                XCTKLabel("before")
                XCTKAssertTrue(false)
                XCTKLabel("after")
            }
        }
    }
    
    
    
    @Reasync
    func testTabulateWithoutCoverTableIsInformational() async
    {
        /// No coverage means no failure.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKTabulate("sign", n > 0 ? "positive" : "negative")
        }
    }
    
    
    
    @Reasync
    func testCoverTableWithoutTabulateProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// Requirements are registered, but no labels are recorded, so
            /// there is no coverage.
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                XCTKCoverTable("sign", (50, "positive"), (50, "negative"))
            }
        }
    }
    
    
    
    @Reasync
    func testCoverTableSameLabelTakesMaximum() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so `negative` is never recorded. The
            /// higher cover percentage overrides the lower one.
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKTabulate("sign", n > 0 ? "positive" : "negative")
                XCTKCoverTable("sign", (10, "negative"))
                XCTKCoverTable("sign", (100, "negative"))
            }
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetPasses() async
    {
        /// All values are `5`, so `positive` is recorded every iteration.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKTabulate("sign", n > 0 ? "positive" : "negative")
            XCTKCoverTable("sign", (100, "positive"))
        }
    }
    
    
    
    @Reasync
    func testTableCoverageNotMetProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so `negative` is never recorded.
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKTabulate("sign", n > 0 ? "positive" : "negative")
                XCTKCoverTable("sign", (100, "negative"))
            }
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetWithPrecondition() async
    {
        /// The precondition leaves only even numbers, so `even` is recorded
        /// every iteration.
        await XCTKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            where:      { $0 % 2 == 0 },
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKTabulate("parity", n % 2 == 0 ? "even" : "odd")
            XCTKCoverTable("parity", (100, "even"))
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetWithCustomGenerator() async
    {
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        100,
            seed:           1
        )
        
        await XCTKForAll(
            using:      generator,
            options:    options
        )
        {
            (n: Int) async in
            
            XCTKTabulate("size", n < 50 ? "small" : "large")
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetWithMultipleGenerators() async
    {
        await XCTKForAll(
            using:      Generator<Int>.constant(1),
                        Generator<Int>.constant(2),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (a: Int, b: Int) async in
            
            XCTKTabulate("comparison", a < b ? "a < b" : "a >= b")
            XCTKCoverTable("comparison", (100, "a < b"))
        }
    }
    
    
    
    @Reasync
    func testSequentialPropertiesDoNotLeakTableClassificationState() async
    {
        /// The first property records labels and has an unmet requirement.
        /// The second property records different labels with a met requirement.
        /// If classification state leaks, the first propert's labels would
        /// appear in the second property's distribution.
        
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKTabulate("sign", "positive")
                XCTKCoverTable("sign", (100, "negative"))
            }
        }
        
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKTabulate("kind", "second")
            XCTKCoverTable("kind", (100, "second"))
        }
    }
    
    
    
    @Reasync
    func testTableClassificationDoesNotInterfereWithInterception() async
    {
        /// Classification and assertion interception share the same
        /// interceptor. Classification calls must not cause assertion
        /// failures to leak as separate failures.
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                XCTKTabulate("sign", n > 0 ? "postive" : "negative")
                XCTKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    @Reasync
    func testTableClassificationContinuesAfterFailingAssertion() async
    {
        /// Classification calls and assertion failures share the same
        /// interceptor. Any labels placed after a non-throwing assertion
        /// continue to execute normally.
        await withOneExpectedFailure
        {
            await XCTKForAll(
                options: .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                XCTKTabulate("position", "before")
                XCTKAssertTrue(false)
                XCTKTabulate("position", "after")
            }
        }
    }
    
    
    
    @Reasync
    func testMixedFlatAndTableClassification() async
    {
        /// Flat labels and table labels exist in the same property body.
        /// Both coverage requirements must be met independently.
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            XCTKCover(100, "positive", when: n > 0)
            XCTKTabulate("sign", n > 0 ? "positive" : "negative")
            XCTKCoverTable("sign", (100, "positive"))
        }
    }
    
    
    
    @Reasync
    func testAssumeTruePassesThrough() async
    {
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try XCTKAssume(true)
        }
    }
    
    
    
    @Reasync
    func testAssumeFalseExhausts() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    1,
            seed:               1
        )
        
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async throws in
                
                try XCTKAssume(false)
            }
        }
    }
    
    
    
    @Reasync
    func testAssumeWithDerivedConditionPasses() async
    {
        await XCTKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try XCTKAssume(n % 2 == 0)
        }
    }
    
    
    
    @Reasync
    func testAssumeWithPreconditionBothFilter() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    1,
            seed:               1
        )
        
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.integer(in: 0...100),
                where:      { $0 % 2 == 0 },
                options:    options
            )
            {
                (_: Int) async throws in
                
                try XCTKAssume(false)
            }
        }
    }
    
    
    
    @Reasync
    func testAssumeDoesNotInterfereWithInterception() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async throws in
                
                try XCTKAssume(true)
                XCTKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    @Reasync
    func testClassificationContinuesAfterPassingAssume() async
    {
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try XCTKAssume(true)
            XCTKCover(100, "after-assume", when: true)
        }
    }
    
    
    
    @Reasync
    func testAssumeWithCoverageCountsOnlyAccepted() async
    {
        await XCTKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try XCTKAssume(n % 2 == 0)
            XCTKCover(100, "even", when: n % 2 == 0)
        }
    }
    
    
    
    @Reasync
    func testAssumeWithTableCoverageCountsOnlyAccepted() async
    {
        await XCTKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try XCTKAssume(n % 2 == 0)
            XCTKTabulate("parity", "even")
            XCTKCoverTable("parity", (100, "even"))
        }
    }
    
    
    
    @Reasync
    func testSequentialPropertiesDoNotLeakAssumeState() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    1,
            seed:               1
        )
        
        /// The first property exhausts by assumption. The second property
        /// passes normally. If the state leaks, the second property would
        /// be affected by the first property's discards.
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async throws in
                
                try XCTKAssume(false)
            }
        }
        
        await XCTKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try XCTKAssume(true)
            XCTKCover(100, "always", when: true)
        }
    }
}
