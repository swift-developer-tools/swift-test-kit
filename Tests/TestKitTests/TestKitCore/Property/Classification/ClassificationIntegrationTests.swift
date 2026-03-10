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



internal final class ClassificationIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    func testClassificationOutsidePropertyBodyIsNoOp()
    {
        TKTarget(50.0)
        TKClassify("label", when: true)
        TKCover(50, "label", when: true)
        TKLabel("label")
        TKCollect(50)
        TKTabulate("table", "label")
        TKCoverTable("table", (50, "label"))
        
        do
        {
            try TKAssume(false)
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
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKCover(100, "positive", when: n > 0)
        }
    }
    
    
    
    @Reasync
    func testCoverageNotMetProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so cover never executes.
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
            }
        }
    }
    
    
    
    @Reasync
    func testClassifyFalseConditionDoesNotFail() async
    {
        /// All values are `5`, so cover never executes, but there is no
        /// coverage requirement.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKClassify("negative", when: n < 0)
        }
    }
    
    
    
    @Reasync
    func testLabelWithCoverageReqMet() async
    {
        /// The label is recorded unconditionally, so cover executes every
        /// iteration.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async in
            
            TKLabel("tracked")
            TKCover(100, "tracked", when: true)
        }
    }
    
    
    
    @Reasync
    func testCollectWithCoverageReqMet() async
    {
        /// Collect records the string representation of the value, which
        /// is always `5`, and cover executes every iteration.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKCollect(n)
            TKCover(100, "5", when: true)
        }
    }
    
    
    
    @Reasync
    func testMultipleCoverSameLabelTakesMaximum() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so cover never executes.
            /// The higher cover percentage overrides the lower one.
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKCover(10, "negative", when: n < 0)
                TKCover(100, "negative", when: n < 0)
            }
        }
    }
    
    
    
    @Reasync
    func testCoverageMetWithPrecondition() async
    {
        /// The precondition leaves only even numbers, so cover
        /// executes every iteration.
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            where:      { $0 % 2 == 0 },
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKCover(100, "even", when: n % 2 == 0)
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
        
        await TKForAll(
            using:      generator,
            options:    options
        )
        {
            (n: Int) async in
            
            TKClassify("small", when: n < 50)
            TKClassify("large", when: n >= 50)
        }
    }
    
    
    
    @Reasync
    func testCoverageMetMultipleGenerators() async
    {
        await TKForAll(
            using:      Generator<Int>.constant(1),
                        Generator<Int>.constant(2),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (a: Int, b: Int) async in
            
            TKCover(100, "a < b", when: a < b)
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKLabel("first")
                TKCover(100, "negative", when: n < 0)
            }
        }
        
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKLabel("second")
            TKCover(100, "second", when: true)
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKClassify("small", when: n < 0)
                TKClassify("large", when: n >= 0)
                TKAssertEqual(1, 2)
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
            await TKForAll(
                options: .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                TKLabel("before")
                TKAssertTrue(false)
                TKLabel("after")
            }
        }
    }
    
    
    
    @Reasync
    func testTabulateWithoutCoverTableIsInformational() async
    {
        /// No coverage means no failure.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKTabulate("sign", n > 0 ? "positive" : "negative")
        }
    }
    
    
    
    @Reasync
    func testCoverTableWithoutTabulateProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// Requirements are registered, but no labels are recorded, so
            /// there is no coverage.
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                TKCoverTable("sign", (50, "positive"), (50, "negative"))
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "positive" : "negative")
                TKCoverTable("sign", (10, "negative"))
                TKCoverTable("sign", (100, "negative"))
            }
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetPasses() async
    {
        /// All values are `5`, so `positive` is recorded every iteration.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKTabulate("sign", n > 0 ? "positive" : "negative")
            TKCoverTable("sign", (100, "positive"))
        }
    }
    
    
    
    @Reasync
    func testTableCoverageNotMetProducesOneFailure() async
    {
        await withOneExpectedFailure
        {
            /// All values are `5`, so `negative` is never recorded.
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "positive" : "negative")
                TKCoverTable("sign", (100, "negative"))
            }
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetWithPrecondition() async
    {
        /// The precondition leaves only even numbers, so `even` is recorded
        /// every iteration.
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            where:      { $0 % 2 == 0 },
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKTabulate("parity", n % 2 == 0 ? "even" : "odd")
            TKCoverTable("parity", (100, "even"))
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
        
        await TKForAll(
            using:      generator,
            options:    options
        )
        {
            (n: Int) async in
            
            TKTabulate("size", n < 50 ? "small" : "large")
        }
    }
    
    
    
    @Reasync
    func testTableCoverageMetWithMultipleGenerators() async
    {
        await TKForAll(
            using:      Generator<Int>.constant(1),
                        Generator<Int>.constant(2),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (a: Int, b: Int) async in
            
            TKTabulate("comparison", a < b ? "a < b" : "a >= b")
            TKCoverTable("comparison", (100, "a < b"))
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", "positive")
                TKCoverTable("sign", (100, "negative"))
            }
        }
        
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKTabulate("kind", "second")
            TKCoverTable("kind", (100, "second"))
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "postive" : "negative")
                TKAssertEqual(1, 2)
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
            await TKForAll(
                options: .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async in
                
                TKTabulate("position", "before")
                TKAssertTrue(false)
                TKTabulate("position", "after")
            }
        }
    }
    
    
    
    @Reasync
    func testMixedFlatAndTableClassification() async
    {
        /// Flat labels and table labels exist in the same property body.
        /// Both coverage requirements must be met independently.
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async in
            
            TKCover(100, "positive", when: n > 0)
            TKTabulate("sign", n > 0 ? "positive" : "negative")
            TKCoverTable("sign", (100, "positive"))
        }
    }
    
    
    
    @Reasync
    func testAssumeTruePassesThrough() async
    {
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try TKAssume(true)
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async throws in
                
                try TKAssume(false)
            }
        }
    }
    
    
    
    @Reasync
    func testAssumeWithDerivedConditionPasses() async
    {
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try TKAssume(n % 2 == 0)
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
            await TKForAll(
                using:      Generator<Int>.integer(in: 0...100),
                where:      { $0 % 2 == 0 },
                options:    options
            )
            {
                (_: Int) async throws in
                
                try TKAssume(false)
            }
        }
    }
    
    
    
    @Reasync
    func testAssumeDoesNotInterfereWithInterception() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    .propertyOptions(iterations: 10, seed: 1)
            )
            {
                (_: Int) async throws in
                
                try TKAssume(true)
                TKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    @Reasync
    func testClassificationContinuesAfterPassingAssume() async
    {
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try TKAssume(true)
            TKCover(100, "after-assume", when: true)
        }
    }
    
    
    
    @Reasync
    func testAssumeWithCoverageCountsOnlyAccepted() async
    {
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try TKAssume(n % 2 == 0)
            TKCover(100, "even", when: n % 2 == 0)
        }
    }
    
    
    
    @Reasync
    func testAssumeWithTableCoverageCountsOnlyAccepted() async
    {
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (n: Int) async throws in
            
            try TKAssume(n % 2 == 0)
            TKTabulate("parity", "even")
            TKCoverTable("parity", (100, "even"))
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async throws in
                
                try TKAssume(false)
            }
        }
        
        await TKForAll(
            using:      Generator<Int>.constant(5),
            options:    .propertyOptions(iterations: 10, seed: 1)
        )
        {
            (_: Int) async throws in
            
            try TKAssume(true)
            TKCover(100, "always", when: true)
        }
    }
    
    
    
    @Reasync
    func testTargetPassesThroughForAll() async
    {
        await TKForAll(
            using:      Generator<Int>.integer(in: 0...100),
            options:    .propertyOptions(iterations: 50, seed: 1)
        )
        {
            (n: Int) async throws in
            
            TKTarget(Double(n))
        }
    }
    
    
    
    @Reasync
    func testTargetFailureThroughForAll() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.integer(in: 0...100),
                options:    .propertyOptions(iterations: 100, seed: 1)
            )
            {
                (n: Int) async throws in
                
                TKTarget(Double(n))
                
                if n > 50
                {
                    TKAssertTrue(false)
                }
            }
        }
    }
    
    
    
    @Reasync
    func testTargetedConvergenceOnPartitionImbalance() async
    {
        /// This test verifies that targeted property-based testing produces
        /// values that are on average 50% higher than those produced by an
        /// identical non-targeted run.
        ///
        /// The underlying test was run 5,000 times with random seeds, passing
        /// 4,999 times (99.98%). The same test passes about 99.7% of the time
        /// when the expectation is that targeted runs produce values that are
        /// on average 100% higher than the same non-targeted run.
        ///
        /// Some seeds produce baseline distributions that yield moderately
        /// adversarial arrays by chance. In these cases, targeted property-
        /// based testing still improves the result, but not necessarily by
        /// 50%. Rather than rely on non-deterministic results, this test uses
        /// three seeds with varying baseline characteristics:
        ///
        /// | Seed                 | Baseline | Targeted | Ratio |
        /// |----------------------|----------|----------|-------|
        /// | 13333452750707912999 | 6.64     | 50.29    | 7.57  |
        /// | 1060906943278724082  | 8.46     | 53.56    | 6.33  |
        /// | 2426678483484296804  | 10.94    | 45.35    | 4.15  |
        ///
        /// The seeds represent low, medium, and high baselines. This also has
        /// the benefit of making test failures reproducible, similar to other
        /// tests that do not use random seeds.
        
        let seeds: [UInt64] =
        [
            13333452750707912999,
            1060906943278724082,
            2426678483484296804
        ]
        
        for seed in seeds
        {
            await validateTargetedConvergenceOnPartitionImbalance(seed: seed)
        }
    }
}



// MARK: - Support

extension ClassificationIntegrationTests
{
    /// Validates that targeted property-based testing produces values that
    /// are, on average, 50% larger in the last quarter of the run than in
    /// an identical non-targeted run.
    /// - Parameter seed: The seed used to initialize the random number
    /// generator.
    @Reasync
    private func validateTargetedConvergenceOnPartitionImbalance(
        seed: UInt64
    ) async
    {
        var baselineImbalances  : [Int]     = []
        var targetedImbalances  : [Int]     = []
        
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 1...100),
            count:  5...15
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     500,
            seed:           seed
        )
        
        await TKForAll(
            using:      generator,
            options:    options
        )
        {
            (numbers: [Int]) async throws in
            
            let imbalance: Int = greedyPartitionImbalance(of: numbers)
            
            baselineImbalances.append(imbalance)
        }
        
        await TKForAll(
            using:      generator,
            options:    options
        )
        {
            (numbers: [Int]) async throws in
            
            let imbalance: Int = greedyPartitionImbalance(of: numbers)
            
            targetedImbalances.append(imbalance)

            TKTarget(Double(imbalance))
        }
        
        let baselineLastQuarter: ArraySlice<Int>
            = baselineImbalances.suffix(baselineImbalances.count / 4)
        
        let targetedLastQuarter: ArraySlice<Int>
            = targetedImbalances.suffix(targetedImbalances.count / 4)
        
        let baselineAverage: Double
            = Double(baselineLastQuarter.reduce(0, +))
            / Double(baselineLastQuarter.count)
        
        let targetedAverage: Double
            = Double(targetedLastQuarter.reduce(0, +))
            / Double(targetedLastQuarter.count)
        
        XCTAssertGreaterThan(targetedAverage, baselineAverage * 1.5)
    }
    
    
    
    /// Computes the imbalance of a greedy partition of the given array.
    ///
    /// The greedy algorithm assigns each number (largest first) to the
    /// partition with the smaller current sum. The imbalance is computed as
    /// the absolute difference between the two partition sums.
    ///
    /// This is a candidate for targeted property-based testing since random
    /// values generally do not produce a high imbalance, but targeted
    /// property-based testing can be used to converge toward adversarial
    /// values that maximize the imbalance and stress test the algorithm.
    ///
    /// - Parameter numbers: The array to evaluate.
    /// - Returns: The imbalance of a greedy partition of the given array.
    private func greedyPartitionImbalance(
        of numbers: [Int]
    ) -> Int
    {
        var sumA    : Int   = 0
        var sumB    : Int   = 0
        
        for number in numbers.sorted(by: >)
        {
            if sumA <= sumB
            {
                sumA += number
            }
            else
            {
                sumB += number
            }
        }
        
        return abs(sumA - sumB)
    }
}
